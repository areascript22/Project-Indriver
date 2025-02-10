/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require('cors');

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
admin.initializeApp();

const corsHandler = cors({
    origin: true,  // Allows all origins
  });


exports.helloWorld = functions.https.onRequest((request,respose)=>{
    console.log("-------------------------------");
    console.log("request ", request);
    console.log("response ", respose);
    console.log("Hello world");
    console.log("-------------------------------");

    respose.status(200).send("success");
});

exports.deleteUser = functions.https.onRequest((request, response) => {
  // Use CORS handler to handle preflight and normal requests
  corsHandler(request, response, () => {
    console.log("Handling request to delete user");

    const {userId} = request.body;
    
    // Add logic to delete the user here
    admin.auth().deleteUser(userId)
      .then(() => {
        response.status(200).json({
            "succes":"User deleted successfully",
        });
      })
      .catch((error) => {
        response.status(500).json({
            "failure":`Error deleting user: ${error.message} reqeuest 2: ${request.body} request params: ${request.params.userId}`,
        });
      });
  });
});
