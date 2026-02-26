const {setGlobalOptions} = require("firebase-functions/v2");
const {defineSecret} = require("firebase-functions/params");
const {initializeApp} = require("firebase-admin/app");

initializeApp();
setGlobalOptions({maxInstances: 10, region: "us-central1"});

const geminiApiKey = defineSecret("GEMINI_API_KEY");

// Import modular functions
const users = require("./src/users");
const chat = require("./src/chat");
const tasks = require("./src/tasks");

// Export functions
exports.createUserProfile = users.createUserProfile;
exports.chatWithAI = chat.chatWithAI(geminiApiKey);
exports.createList = chat.createList;
exports.deleteList = chat.deleteList;
exports.renameList = chat.renameList;
exports.createTask = tasks.createTask;
