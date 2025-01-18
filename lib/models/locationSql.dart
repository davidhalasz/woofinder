import 'package:flutter/foundation.dart';

class LocationSql with ChangeNotifier {
  LocationSql({
    required this.id,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.locale,
  });

  final String id;
  final int distance;
  final String latitude;
  final String longitude;
  final String locale;
}
