import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MyNotification with ChangeNotifier {
  final String id;
  final String userName;
  final String action;
  final DateTime createdAt;
  final String animalId;
  final String uid;

  MyNotification({
    required this.id,
    required this.userName,
    required this.action,
    required this.createdAt,
    required this.animalId,
    required this.uid,
  });

  MyNotification.fromSnapshot(Map<String, dynamic> snapshot, String uid)
      : id = snapshot['id'],
        userName = snapshot['userName'],
        action = snapshot['action'],
        createdAt = DateTime.parse(snapshot['createdAt']),
        animalId = snapshot['animalId'],
        uid = uid;
}
