const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.myFunction = functions.firestore
    .document("animal/{message}")
    .onCreate((snapshot, context) => {
      return admin.messaging().sendToTopic("animal", {
        data: {
          latitude: snapshot.data()["latitude"].toString(),
          longitude: snapshot.data()["longitude"].toString(),
          title: snapshot.data().username,
          body: snapshot.data().description,
          uid: snapshot.data().userId,
          animalId: snapshot.id,
        },
      });
    });

exports.commentFunction = functions.firestore
    .document("notifications/{userId}/notification/{notify}")
    .onCreate((snapshot, ctx) => {
      return admin.messaging().sendToTopic( "notifications", {
        data: {
          title: snapshot.data().userName,
          body: snapshot.data().action,
          animalId: snapshot.data().animalId,
          commentSender: snapshot.data().uid,
        },
      });
    });
