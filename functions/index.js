const {setGlobalOptions} = require("firebase-functions/v2");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {initializeApp} = require("firebase-admin/app");
const logger = require("firebase-functions/logger");
const {GoogleGenerativeAI, SchemaType} = require("@google/generative-ai");

initializeApp();
const db = getFirestore();
setGlobalOptions({maxInstances: 10, region: "us-central1"});

const geminiApiKey = defineSecret("GEMINI_API_KEY");

exports.createUserProfile = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  const {name, email, uid} = request.data;

  if (!name || !email || !uid) {
    throw new HttpsError(
        "invalid-argument",
        "The function must be called with name, email, and uid.",
    );
  }

  try {
    await db.collection("users").doc(uid).set({
      userData: {
        name: name,
        email: email,
      },
      uid: uid,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    logger.info(`User profile created for UID: ${uid}`);
    return {success: true, message: "User profile created successfully"};
  } catch (error) {
    logger.error("Error creating user profile:", error);
    throw new HttpsError(
        "internal",
        "Error creating user profile in Firestore",
    );
  }
});

exports.chatWithAI = onCall({secrets: [geminiApiKey]}, async (request) => {
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  const {prompt, history} = request.data;

  if (!prompt) {
    throw new HttpsError(
        "invalid-argument",
        "The function must be called with a prompt.",
    );
  }

  const key = geminiApiKey.value();
  if (!key) {
    logger.error("GEMINI_API_KEY is empty.");
    throw new HttpsError("failed-precondition", "API Key is missing.");
  }

  logger.info(`Using API Key (masked): ${key.substring(0, 4)}...`);

  try {
    const genAI = new GoogleGenerativeAI(key);

    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash", // Corrected model name
      tools: [
        {
          functionDeclarations: [
            {
              name: "create_list",
              description: "Create a new list with a specific name",
              parameters: {
                type: SchemaType.OBJECT,
                properties: {
                  name: {
                    type: SchemaType.STRING,
                    description: "The name of the list to create",
                  },
                },
                required: ["name"],
              },
            },
          ],
        },
      ],
    });

    const chat = model.startChat({
      history: history || [],
    });

    const result = await chat.sendMessage(prompt);
    const response = result.response;
    const functionCalls = response.functionCalls();

    if (functionCalls && functionCalls.length > 0) {
      const call = functionCalls[0];

      if (call.name === "create_list") {
        const listName = call.args.name;
        logger.info(`AI requested to create a list named: ${listName}`);

        return {
          isFunctionCall: true,
          functionName: call.name,
          arguments: call.args,
          text: `I am creating a list named '${listName}' for you.`,
        };
      }
    }

    return {
      isFunctionCall: false,
      text: response.text(),
    };
  } catch (error) {
    logger.error("Detailed Chat Error:", error);

    // Better explanation for common errors
    if (error.message.includes("API_KEY_INVALID")) {
      throw new HttpsError(
          "unauthenticated",
          "The API key is invalid. If you are using the emulator, make " +
          "sure GEMINI_API_KEY is set in your .secret.local file.",
      );
    }

    throw new HttpsError("internal", `AI Error: ${error.message}`);
  }
});
