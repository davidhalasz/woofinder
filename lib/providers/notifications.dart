import 'package:flutter/foundation.dart';
import 'package:woof/models/my_notification.dart';

import '../helpers/db_helper.dart';

class Notifications with ChangeNotifier {
  List<MyNotification> _notifications = [];

  List<MyNotification> get notifications {
    return [..._notifications.reversed];
  }

  Future<void> addNotification({
    required String id,
    required String userName,
    required String action,
    required DateTime createdAt,
    required String animalId,
    required String uid,
  }) async {
    final newNotification = MyNotification(
      id: id,
      userName: userName,
      action: action,
      createdAt: createdAt,
      animalId: animalId,
      uid: uid,
    );
    print('insert noti called');

    // String
    var dtStr = createdAt.toIso8601String();

    try {
      DBHelper.insert('notification_infos', {
        'id': newNotification.id,
        'userName': newNotification.userName,
        'action': newNotification.action,
        'createdAt': dtStr,
        'animalId': newNotification.animalId,
        'uid': uid,
      });
      print('New notification added!');
      _notifications.add(newNotification);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchAndSetNotifications(String uid) async {
    final List<MyNotification> loadedNotifications = [];
    final data = await DBHelper.getAllDataSQL('notification_infos');
    for (var i = 0; i < data.length; i++) {
      var currNotif = data[i];
      print(currNotif['createdAt']);
      DateTime? createdAt = DateTime.tryParse(currNotif['createdAt']);
      print(createdAt);
      var nowDateTime = DateTime.now();
      int days = nowDateTime.difference(createdAt!).inDays;

      if (days > 60) {
        await DBHelper.deleteNotification(currNotif['id']);
      } else {
        if (currNotif['uid'] == uid) {
          MyNotification notification =
              MyNotification.fromSnapshot(currNotif, uid);
          loadedNotifications.add(notification);
        }
      }
    }
    _notifications = loadedNotifications;
    print("Notification has been fetched and set!");
    notifyListeners();
  }
}
