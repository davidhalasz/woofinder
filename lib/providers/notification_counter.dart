import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:woof/helpers/db_helper.dart';
import 'package:woof/models/nofitication_number.dart';

class NotificationCounter with ChangeNotifier {
  var currentUser = FirebaseAuth.instance.currentUser!.uid;
  late NotificationNumber _item = NotificationNumber(
    id: currentUser,
    notificationNumber: 0,
  );
  NotificationNumber get item {
    return _item;
  }

  Future<void> addNotification({
    required String id,
    required int notificationNumber,
  }) async {
    final newNotification = NotificationNumber(
      id: id,
      notificationNumber: notificationNumber,
    );

    DBHelper.insert('notification_info', {
      'id': newNotification.id,
      'notificationNumber': newNotification.notificationNumber
    });
    print('Notification info has changed!');
    _item = newNotification;
    notifyListeners();
  }

  Future<NotificationNumber> fetchAndSetLocation(String id) async {
    final data = await DBHelper.getData('notification_info', id);
    if (data != null) {
      print('Notification fetched data called');
      _item = NotificationNumber(
        id: data['id'],
        notificationNumber: data['notificationNumber'],
      );
      notifyListeners();
      return item;
    } else {
      var newItem = NotificationNumber(
        id: id,
        notificationNumber: 0,
      );
      addNotification(
        id: newItem.id,
        notificationNumber: newItem.notificationNumber,
      );
      notifyListeners();
      return newItem;
    }
  }
}
