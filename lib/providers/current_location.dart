import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:woof/models/locationSql.dart';
import 'package:woof/helpers/db_helper.dart';

class CurrentLocation with ChangeNotifier {
  late LocationSql _item;

  LocationSql get item {
    return _item;
  }

  Future<void> addLocation({
    required String id,
    required int distance,
    required String currLatitude,
    required String currLlongitude,
  }) async {
    final newLocation = LocationSql(
      id: id,
      distance: distance,
      latitude: currLatitude,
      longitude: currLlongitude,
    );

    DBHelper.insert('location_info', {
      'id': newLocation.id,
      'distance': newLocation.distance,
      'latitude': newLocation.latitude,
      'longitude': newLocation.longitude
    });
    print('Location info has changed!');
    _item = newLocation;
    notifyListeners();
  }

  Future<LocationSql> fetchAndSetLocation(String id) async {
    final bool isEmpty = await CurrentLocation().isEmptyTable();
    final data = await DBHelper.getData('location_info', id);
    if (!isEmpty && data != null) {
      print('Location fetched data called');
      _item = LocationSql(
          id: data['id'],
          distance: data['distance'],
          latitude: data['latitude'].toString(),
          longitude: data['longitude'].toString());
      notifyListeners();
      return item;
    } else {
      final location = await Location().getLocation();
      var newItem = LocationSql(
          id: id,
          distance: 60,
          latitude: location.latitude.toString(),
          longitude: location.longitude.toString());
      addLocation(
        id: newItem.id,
        distance: newItem.distance,
        currLatitude: newItem.latitude,
        currLlongitude: newItem.longitude,
      );
      return newItem;
    }
  }

  Future<bool> isEmptyTable() async {
    return await DBHelper.isEmptyTable();
  }
}
