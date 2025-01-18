import 'package:flutter/foundation.dart';

class NotificationNumber with ChangeNotifier {
  NotificationNumber({
    required this.id,
    required this.notificationNumber,
  });

  final String id;
  final int notificationNumber;
}
