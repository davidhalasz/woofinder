import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:woof/models/animals.dart';
import 'package:woof/providers/current_location.dart';
import 'package:collection/collection.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class FoundAnimals with ChangeNotifier {
  List<Animals> _items = [];
  List<Animals> _featuredItems = [];

  List<Animals> get items {
    return [..._items];
  }

  List<Animals> get featuredItems {
    return [..._featuredItems];
  }

  Animals? findById(String id) {
    Animals? animal = _items.firstWhereOrNull((anim) => anim.id == id);
    if (animal == null) {
      return _featuredItems.firstWhereOrNull((element) => element.id == id);
    }
    return animal;
  }

  Animals? findLastFeatured() {
    var featured = _featuredItems;
    featured.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return _featuredItems
        .firstWhereOrNull((element) => element == featured.last);
  }

  void removeAnimal(String id) {
    final existingItemIndex = _items.indexWhere((anim) => anim.id == id);
    _items.removeAt(existingItemIndex);
    notifyListeners();
  }

  Future<void> fetchAndSetAnimals() async {
    print("fetchandsetanimal start");
    final List<Animals> loadedAnimals = [];
    final animals = await FirebaseFirestore.instance.collection('animal').get();
    var nowDateTime = DateTime.now();
    final documents = animals.docs;
    for (var i = 0; i < documents.length; i++) {
      var currAnim = documents[i].data();
      if (currAnim['solved'] == true) {
        Timestamp solvedDateTime = currAnim['solvedDate'] as Timestamp;
        int days = nowDateTime.difference(solvedDateTime.toDate()).inDays;

        if (days > 2) {
          final animalData = await FirebaseFirestore.instance
              .collection('animal')
              .doc(documents[i].id)
              .get();
          final List<dynamic> images = animalData['imageUrls'];

          for (int i = 0; i < images.length; i++) {
            try {
              final getImage =
                  FirebaseStorage.instance.refFromURL(images[i].toString());
              await getImage.delete();
            } catch (error) {
              print(error);
            }
          }
          await FirebaseFirestore.instance
              .collection('animal')
              .doc(documents[i].id)
              .delete();

          var animalId = documents[i].id;
          await FirebaseFirestore.instance
              .collection('comments')
              .doc(animalId)
              .delete();
        } else {
          Animals animal = Animals.fromSnapshot(documents[i].id, currAnim);
          if (currAnim['featured']) {
            _featuredItems.add(animal);
          } else {
            loadedAnimals.add(animal);
          }
        }
      } else {
        if (currAnim['featured']) {
          Animals animal = Animals.fromSnapshot(documents[i].id, currAnim);
          _featuredItems.add(animal);
        } else {
          Timestamp solvedDateTime = currAnim['createdAt'] as Timestamp;
          int days = nowDateTime.difference(solvedDateTime.toDate()).inDays;

          if (days > 60) {
            final animalData = await FirebaseFirestore.instance
                .collection('animal')
                .doc(documents[i].id)
                .get();
            final List<dynamic> images = animalData['imageUrls'];

            for (int i = 0; i < images.length; i++) {
              try {
                final getImage =
                    FirebaseStorage.instance.refFromURL(images[i].toString());
                await getImage.delete();
              } catch (error) {
                print(error);
              }
            }
            await FirebaseFirestore.instance
                .collection('animal')
                .doc(documents[i].id)
                .delete();

            var animalId = documents[i].id;
            await FirebaseFirestore.instance
                .collection('comments')
                .doc(animalId)
                .delete();
          } else {
            Animals animal = Animals.fromSnapshot(documents[i].id, currAnim);
            loadedAnimals.add(animal);
          }
        }
        print('Fetch and set animal called');
      }
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    var locationInfo = await CurrentLocation().fetchAndSetLocation(uid);

    double distanceFromMyLocation(double lat, double lng) {
      double distance = Geolocator.distanceBetween(
        double.parse(locationInfo.latitude),
        double.parse(locationInfo.longitude),
        lat,
        lng,
      );
      return distance;
    }

    final List<Animals> sortedAnimals = [];

    for (var i = 0; i < loadedAnimals.length; i++) {
      final double distance = distanceFromMyLocation(
        loadedAnimals[i].latitude,
        loadedAnimals[i].longitude,
      );
      loadedAnimals[i].distance = distance;
      sortedAnimals.add(loadedAnimals[i]);
    }

    sortedAnimals.sort((a, b) {
      return (a.distance!.compareTo(b.distance!));
    });

    _items = sortedAnimals;
    notifyListeners();
  }

  Future<void> addAnimal(String id) async {
    final animalData =
        await FirebaseFirestore.instance.collection('animal').doc(id).get();

    var animalD = animalData.data() as Map<String, dynamic>;
    Animals animal = Animals.fromSnapshot(animalData.id, animalD);
    if (animal.featured) {
      _featuredItems.add(animal);
    } else {
      _items.add(animal);

      final uid = FirebaseAuth.instance.currentUser!.uid;
      var locationInfo = await CurrentLocation().fetchAndSetLocation(uid);

      double distanceFromMyLocation(double lat, double lng) {
        double distance = Geolocator.distanceBetween(
          double.parse(locationInfo.latitude),
          double.parse(locationInfo.longitude),
          lat,
          lng,
        );
        return distance;
      }

      final List<Animals> sortedAnimals = [];

      for (var i = 0; i < _items.length; i++) {
        final double distance = distanceFromMyLocation(
          _items[i].latitude,
          _items[i].longitude,
        );
        _items[i].distance = distance;
        sortedAnimals.add(_items[i]);
      }

      sortedAnimals.sort((a, b) {
        return (a.distance!.compareTo(b.distance!));
      });

      _items = sortedAnimals;
    }
    notifyListeners();
  }

  Future<void> deleteAnimal(
    String animalId,
  ) async {
    final animalData = await FirebaseFirestore.instance
        .collection('animal')
        .doc(animalId)
        .get();
    final List<dynamic> images = animalData['imageUrls'];

    for (int i = 0; i < images.length; i++) {
      try {
        final getImage =
            FirebaseStorage.instance.refFromURL(images[i].toString());
        await getImage.delete();
      } catch (error) {
        print(error);
      }
    }
    await FirebaseFirestore.instance
        .collection('animal')
        .doc(animalId)
        .delete();

    if (animalData['featured']) {
      final existingItemIndex =
          _featuredItems.indexWhere((anim) => anim.id == animalId);
      _featuredItems.removeAt(existingItemIndex);
    } else {
      final existingItemIndex =
          _items.indexWhere((anim) => anim.id == animalId);
      _items.removeAt(existingItemIndex);
    }

    notifyListeners();
  }

  Future<void> updateAnimalDescription(String animalId, String text) async {
    print('update void called');
    await FirebaseFirestore.instance
        .collection('animal')
        .doc(animalId)
        .update({'description': text});

    final animalData = await FirebaseFirestore.instance
        .collection('animal')
        .doc(animalId)
        .get();

    var animalD = animalData.data() as Map<String, dynamic>;
    Animals animal = Animals.fromSnapshot(animalData.id, animalD);
    print(animal.toString());

    if (animal.featured) {
      final existingItemIndex =
          _featuredItems.indexWhere((anim) => anim.id == animalId);
      _featuredItems[existingItemIndex] = animal;
    } else {
      final existingItemIndex =
          _items.indexWhere((anim) => anim.id == animalId);
      _items[existingItemIndex] = animal;
    }
    notifyListeners();
  }

  Future<void> solvedAnimal(Animals animal) async {
    print('solved Animal called');
    var solved = animal.solved;
    final solvedDate = Timestamp.now();
    await FirebaseFirestore.instance
        .collection('animal')
        .doc(animal.id)
        .update({
      'solved': !solved,
      'solvedDate': solvedDate,
    });
    var solvedAnimal = animal;

    solvedAnimal.solved = !solved;
    solvedAnimal.solvedDate = solvedDate;
    final existingItemIndex = _items.indexWhere((anim) => anim.id == animal.id);
    _items[existingItemIndex] = solvedAnimal;
    notifyListeners();
  }

  Future<void> sendReport(String id) async {
    print("Sending report called");
    FirebaseFirestore.instance.collection('reports').add({
      'date': Timestamp.now(),
      'animalId': id,
    });
  }
}
