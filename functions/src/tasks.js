const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const logger = require("firebase-functions/logger");

const db = getFirestore();

exports.createTask = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  const {
    title, description, status, listId, reminderTime, recurring, sound,
  } = request.data;
  const uid = request.auth.uid;

  if (!title) {
    throw new HttpsError("invalid-argument", "Task title is required.");
  }

  try {
    const taskData = {
      userId: uid,
      listId: listId || null,
      title: title,
      description: description || "",
      status: status || "todo",
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      recurring: recurring || "None",
      sound: sound || "Crystal",
    };

    if (reminderTime) {
      taskData.reminderTime = new Date(reminderTime);
    }

    const taskRef = await db.collection("tasks").add(taskData);
    return {success: true, taskId: taskRef.id};
  } catch (error) {
    logger.error("Error creating task:", error);
    throw new HttpsError("internal", "Error creating task");
  }
});
