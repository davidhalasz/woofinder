import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:woof/models/animals.dart';
import 'package:woof/providers/current_location.dart';
import 'package:collection/collection.dart';

class FoundAnimals with ChangeNotifier {
  List<Animals> _items = [];

  List<Animals> get items {
    return [..._items];
  }

  Animals? findById(String id) {
    return _items.firstWhereOrNull((anim) => anim.id == id);
  }

  String findByImage(String id, String image) {
    final Animals user = _items.firstWhere((anim) => anim.id == id);
    for (var i = 0; i < user.images.length; i++) {
      if (user.images[i] == image) {
        return user.images[i];
      }
    }
    return '';
  }

  void removeAnimal(String id) {
    final existingItemIndex = _items.indexWhere((anim) => anim.id == id);
    _items.removeAt(existingItemIndex);
    notifyListeners();
  }

  Future<void> fetchAndSetAnimals() async {
    final List<Animals> loadedAnimals = [];
    final animals = await FirebaseFirestore.instance.collection('animal').get();

    final documents = animals.docs;
    for (var i = 0; i < documents.length; i++) {
      var currAnim = documents[i].data();
      if (currAnim['solved'] == true) {
        var nowDateTime = DateTime.now();
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
        } else {
          Animals animal = Animals.fromSnapshot(documents[i].id, currAnim);
          loadedAnimals.add(animal);
        }
      } else {
        Animals animal = Animals.fromSnapshot(documents[i].id, currAnim);
        loadedAnimals.add(animal);
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
    final existingItemIndex = _items.indexWhere((anim) => anim.id == animalId);
    _items.removeAt(existingItemIndex);
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
    final existingItemIndex = _items.indexWhere((anim) => anim.id == animalId);
    _items[existingItemIndex] = animal;
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
