import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:woof/models/my_notification.dart';

class Notifications with ChangeNotifier {
  List<MyNotification> _notifications = [];

  List<MyNotification> get notifications {
    return [..._notifications];
  }

  Future<void> fetchAndSetNotifications(String userId) async {
    final List<MyNotification> loadedNotifications = [];
    final collection = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('notification')
        .orderBy('createdAt', descending: true)
        .get();
    final documents = collection.docs;

    for (var i = 0; i < documents.length; i++) {
      var currNotifi = documents[i].data();

      MyNotification notification =
          MyNotification.fromSnapshot(documents[i].id, currNotifi);
      loadedNotifications.add(notification);
    }
    _notifications = loadedNotifications;
    print("Notification has been fetched and set!");
    notifyListeners();
  }
}
