import 'package:flutter/foundation.dart';

import 'place.dart';

class Animal with ChangeNotifier {
  final String id;
  final String description;
  final List<String> images;
  final Place location;

  Animal(
      {required this.id,
      required this.description,
      required this.images,
      required this.location});
}
