import 'dart:io';

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
    required String locale,
  }) async {
    final newLocation = LocationSql(
      id: id,
      distance: distance,
      latitude: currLatitude,
      longitude: currLlongitude,
      locale: locale,
    );

    DBHelper.insert('location_infos', {
      'id': newLocation.id,
      'distance': newLocation.distance,
      'latitude': newLocation.latitude,
      'longitude': newLocation.longitude,
      'locale': newLocation.locale,
    });
    _item = newLocation;
    notifyListeners();
  }

  Future<LocationSql> fetchAndSetLocation(String id) async {
    final bool isEmpty = await CurrentLocation().isEmptyTable();
    final data = await DBHelper.getData('location_infos', id);
    if (!isEmpty && data != null) {
      _item = LocationSql(
          id: data['id'],
          distance: data['distance'],
          latitude: data['latitude'].toString(),
          longitude: data['longitude'].toString(),
          locale: data['locale']);
      notifyListeners();
      return item;
    } else {
      final location = await Location().getLocation();
      var newItem = LocationSql(
          id: id,
          distance: 60,
          latitude: location.latitude.toString(),
          longitude: location.longitude.toString(),
          locale: Platform.localeName);
      addLocation(
        id: newItem.id,
        distance: newItem.distance,
        currLatitude: newItem.latitude,
        currLlongitude: newItem.longitude,
        locale: newItem.locale,
      );
      notifyListeners();
      return newItem;
    }
  }

  Future firstLocationSetting(String id) async {
    var isEmpty = await isEmptyTable();
    if (isEmpty) {
      addLocation(
        id: id,
        distance: 60,
        currLatitude: "47.497913",
        currLlongitude: "19.040236",
        locale: Platform.localeName,
      );
    }
  }

  Future<bool> isEmptyTable() async {
    return await DBHelper.isEmptyTable();
  }
}
