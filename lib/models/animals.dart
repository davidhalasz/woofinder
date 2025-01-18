import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Animals with ChangeNotifier {
  final String id;
  final String userId;
  final String username;
  final Timestamp createdAt;
  final String description;
  final List<dynamic> images;
  final double latitude;
  final double longitude;
  final String address;
  double? distance;
  bool solved;
  Timestamp? solvedDate;
  final bool featured;

  Animals(
      {required this.id,
      required this.userId,
      required this.username,
      required this.createdAt,
      required this.description,
      required this.images,
      required this.latitude,
      required this.longitude,
      required this.address,
      this.distance,
      required this.solved,
      this.solvedDate,
      required this.featured});

  Animals.fromSnapshot(String id, Map<String, dynamic> snapshot)
      : id = id,
        userId = snapshot['userId'],
        username = snapshot['username'],
        createdAt = snapshot['createdAt'],
        description = snapshot['description'],
        images = snapshot['imageUrls'] ?? [],
        latitude = double.parse(snapshot['latitude'].toString()),
        longitude = double.parse(snapshot['longitude'].toString()),
        address = snapshot['address'],
        solved = snapshot['solved'],
        solvedDate = snapshot['solvedDate'],
        featured = snapshot['featured'];
}
