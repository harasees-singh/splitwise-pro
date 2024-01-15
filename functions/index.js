// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// const nodemailer = require("nodemailer");
// // require("dotenv").config();

// admin.initializeApp();

// // Cloud Firestore triggers ref: https://firebase.google.com/docs/functions/firestore-events
// exports.myFunction = functions.firestore
//   .document("logs-dev/{logsId}")
//   .onUpdate((snapshot, context) => {
//     // Return this function's promise, so this ensures the firebase function
//     // will keep running, until the notification is scheduled.

//     return admin.messaging().sendToTopic(context.params.userEmail, {
//       // Sending a notification message.
//       notification: {
//         title: 'expenses updated',
//         body: 'someone updated the expenses',
//         clickAction: "FLUTTER_NOTIFICATION_CLICK",
//       },
//     });
//   });