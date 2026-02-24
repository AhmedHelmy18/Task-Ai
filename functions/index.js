const {setGlobalOptions} = require("firebase-functions/v2");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {initializeApp} = require("firebase-admin/app");
const logger = require("firebase-functions/logger");

initializeApp();
const db = getFirestore();

setGlobalOptions({maxInstances: 10, region: "us-central1"});

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
