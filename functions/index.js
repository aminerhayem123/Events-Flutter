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
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.deleteOldEvents = functions.pubsub.schedule('every 24 hours').timeZone('UTC').onRun(async (context) => {
    const db = admin.firestore();
    const now = new Date();
    const threshold = new Date(now - 24 * 60 * 60 * 1000); // 24 hours ago

    const eventsRef = db.collection('events');
    const snapshot = await eventsRef.where('EventDate', '<', threshold).get();

    const batch = db.batch();
    snapshot.forEach((doc) => {
        batch.delete(doc.ref);
    });

    return batch.commit();
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
