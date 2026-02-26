const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");
const {GoogleGenerativeAI, SchemaType} = require("@google/generative-ai");

const db = getFirestore();

exports.chatWithAI = (geminiApiKey) =>
  onCall({secrets: [geminiApiKey]}, async (request) => {
    if (!request.auth) {
      throw new HttpsError(
          "unauthenticated",
          "The function must be called while authenticated.",
      );
    }

    const {prompt, history, listId} = request.data;
    const uid = request.auth.uid;

    if (!prompt) {
      throw new HttpsError(
          "invalid-argument",
          "The function must be called with a prompt.",
      );
    }

    if (listId) {
      try {
        await db.collection("lists").doc(listId)
            .collection("messages").add({
              role: "user",
              content: prompt,
              createdAt: FieldValue.serverTimestamp(),
            });
        await db.collection("lists").doc(listId).update({
          updatedAt: FieldValue.serverTimestamp(),
        });
      } catch (error) {
        logger.error("Error saving user message to Firestore:", error);
      }
    }

    const key = geminiApiKey.value();
    if (!key) {
      logger.error("GEMINI_API_KEY is empty.");
      throw new HttpsError("failed-precondition", "API Key is missing.");
    }

    try {
      const genAI = new GoogleGenerativeAI(key);
      const model = genAI.getGenerativeModel({
        model: "gemini-2.5-flash",
        systemInstruction: "You are a helpful task manager assistant. When " +
          "a user gives you a complex goal, break it down into multiple " +
          "actionable tasks. Use the create_task tool for EACH task " +
          "you identify.",
        tools: [{
          functionDeclarations: [{
            name: "create_task",
            description: "Create a new task. Call this multiple times if a " +
              "goal has multiple steps.",
            parameters: {
              type: SchemaType.OBJECT,
              properties: {
                title: {
                  type: SchemaType.STRING,
                  description: "The title of the task to create",
                },
                status: {
                  type: SchemaType.STRING,
                  description: "The status of the task (todo or completed)",
                  enum: ["todo", "completed"],
                },
                priority: {
                  type: SchemaType.STRING,
                  description: "The priority of the task (Low, Medium, High)",
                  enum: ["Low", "Medium", "High"],
                },
              },
              required: ["title"],
            },
          }],
        }],
      });

      const chat = model.startChat({history: history || []});
      const result = await chat.sendMessage(prompt);
      const response = result.response;
      const functionCalls = response.functionCalls();

      let aiText = "";
      try {
        aiText = response.text();
      } catch (e) {
        aiText = "";
      }

      let isFunctionCall = false;
      let functionName = null;
      let functionArgs = null;
      const createdTasks = [];

      if (functionCalls && functionCalls.length > 0) {
        isFunctionCall = true;
        for (const call of functionCalls) {
          if (call.name === "create_task") {
            const {title, status, priority} = call.args;
            logger.info(`AI requested to create a task: ${title}`);
            await db.collection("tasks").add({
              userId: uid,
              listId: listId || null,
              title: title,
              status: status || "todo",
              priority: priority || "Medium",
              createdAt: FieldValue.serverTimestamp(),
              updatedAt: FieldValue.serverTimestamp(),
            });
            createdTasks.push(title);
            functionName = "create_task";
            functionArgs = call.args;
          }
        }
        if (createdTasks.length > 1) {
          aiText = `I've created ${createdTasks.length} tasks for you: ` +
              `${createdTasks.join(", ")}.`;
        } else if (createdTasks.length === 1) {
          aiText = `I've created the task "${createdTasks[0]}" for you.`;
        }
      }

      if (listId) {
        try {
          await db.collection("lists").doc(listId)
              .collection("messages").add({
                role: "model",
                content: aiText,
                createdAt: FieldValue.serverTimestamp(),
              });
        } catch (error) {
          logger.error("Error saving AI response to Firestore:", error);
        }
      }

      return {
        isFunctionCall,
        functionName,
        arguments: functionArgs,
        text: aiText,
      };
    } catch (error) {
      logger.error("Detailed Chat Error:", error);
      throw new HttpsError(
          "internal",
          `AI Error: ${error.message}`,
      );
    }
  });

exports.createList = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const {title} = request.data;
  const uid = request.auth.uid;
  try {
    const listRef = await db.collection("lists").add({
      userId: uid,
      title: title || "New List",
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    return {success: true, listId: listRef.id};
  } catch (error) {
    logger.error("Error creating list:", error);
    throw new HttpsError("internal", "Error creating list");
  }
});

exports.deleteList = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const {listId} = request.data;
  if (!listId) {
    throw new HttpsError("invalid-argument", "List ID is required.");
  }
  try {
    const messages = await db.collection("lists").doc(listId)
        .collection("messages").get();
    const tasks = await db.collection("tasks")
        .where("listId", "==", listId).get();
    const batch = db.batch();
    messages.forEach((doc) => batch.delete(doc.ref));
    tasks.forEach((doc) => batch.delete(doc.ref));
    batch.delete(db.collection("lists").doc(listId));
    await batch.commit();
    return {success: true};
  } catch (error) {
    logger.error("Error deleting list:", error);
    throw new HttpsError("internal", "Error deleting list");
  }
});

exports.renameList = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const {listId, title} = request.data;
  if (!listId || !title) {
    throw new HttpsError(
        "invalid-argument",
        "List ID and title are required.",
    );
  }
  try {
    await db.collection("lists").doc(listId).update({
      title: title,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return {success: true};
  } catch (error) {
    logger.error("Error renaming list:", error);
    throw new HttpsError("internal", "Error renaming list");
  }
});


