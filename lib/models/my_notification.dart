import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MyNotification with ChangeNotifier {
  final String id;
  final String userName;
  final String action;
  final Timestamp createdAt;
  final String animalId;

  MyNotification({
    required this.id,
    required this.userName,
    required this.action,
    required this.createdAt,
    required this.animalId,
  });

  MyNotification.fromSnapshot(String id, Map<String, dynamic> snapshot)
      : id = id,
        userName = snapshot['userName'],
        action = snapshot['action'],
        createdAt = snapshot['createdAt'],
        animalId = snapshot['animalId'];
}
