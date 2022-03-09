const functions = require("firebase-functions");
const admin = require("firebase-admin");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

admin.initializeApp();

exports.haveMatch = functions
  .region("europe-west2")
  .firestore.document("/mates/{userId}")
  .onUpdate(async (change, context) => {
    var db = admin.firestore();
    const newValue = await change.after.data();
    const users = newValue.users;

    if (newValue[users[0]] == true && newValue[users[1]] == true) {
      for (let i = 0; i < users.length; i++) {
        let snapshot = await db.collection("users").doc(users[i]).get();
        const payload = {
          notification: {
            title: "New Match",
            body: "You have a new match",
          },
          token: snapshot.data().token,
        };

        admin.messaging().send(payload);
      }
    }
  });
