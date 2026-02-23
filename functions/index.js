/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {initializeApp} = require("firebase-admin/app");
const logger = require("firebase-functions/logger");

initializeApp();
const db = getFirestore();

setGlobalOptions({maxInstances: 10});

exports.createUserProfile = onCall(async (request) => {
  // Ensure user is authenticated
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
    );
  }

  const {name, email, uid} = request.data;

  // Validate input
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

