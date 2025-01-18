import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woof/models/animals.dart';
import 'package:woof/providers/found_animals.dart';
import 'package:woof/screens/animalDetailPage/animal_detail_screen.dart';
import 'package:woof/screens/errorPage/error_screen.dart';
import '../../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AnimalCard extends StatefulWidget {
  AnimalCard(
    this.currentLatitude,
    this.currentLongitude,
  );

  final double currentLatitude;
  final double currentLongitude;

  @override
  _AnimalCardState createState() => _AnimalCardState();
}

class _AnimalCardState extends State<AnimalCard> {
  @override
  Widget build(BuildContext context) {
    final animal = Provider.of<Animals>(context, listen: false);

    var solvedBorderColor = Colors.transparent;
    var solvedBorderWidth = 0.0;
    var cornerColor = cSecondaryColor;
    var solved = animal.solved;

    if (solved) {
      solvedBorderColor = greenColor;
      solvedBorderWidth = 3.0;
      cornerColor = greenColor;
    }

    double distanceInMeters = Geolocator.distanceBetween(
      widget.currentLatitude,
      widget.currentLongitude,
      animal.latitude,
      animal.longitude,
    );

    String postedAgo(DateTime postedDateTime) {
      var nowDateTime = DateTime.now();

      int days = nowDateTime.difference(postedDateTime).inDays;
      int hours = nowDateTime.difference(postedDateTime).inHours;
      int minutes = nowDateTime.difference(postedDateTime).inMinutes;
      int seconds = nowDateTime.difference(postedDateTime).inSeconds;

      if (minutes < 1) {
        return '$seconds ' + AppLocalizations.of(context).postedSec;
      } else if (hours < 1) {
        return '$minutes ' + AppLocalizations.of(context).postedMin;
      } else if (days < 1) {
        return '$hours ' + AppLocalizations.of(context).postedHrs;
      } else {
        return '$days ' + AppLocalizations.of(context).postedDays;
      }
    }

    String format(double n) {
      int number = n.round();
      int length = number.toString().length;
      if (length > 3) {
        number = (number / 1000).round();
        return number.toString() + ' km';
      }
      return number.toString() + ' m';
    }

    var postedDateTime = animal.createdAt.toDate();

    String _postedAgo = postedAgo(postedDateTime);

    Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _postedAgo = postedAgo(postedDateTime);
        });
      }
    });

    return GestureDetector(
      onTap: () async {
        final animalSnapshot = await FirebaseFirestore.instance
            .collection('animal')
            .doc(animal.id)
            .get();
        if (animalSnapshot.exists) {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) =>
                    AnimalDetailScreen(animalSnapshot.id, false)),
          );
        } else {
          Provider.of<FoundAnimals>(context, listen: false)
              .removeAnimal(animalSnapshot.id);
          Navigator.of(context).pushNamed(ErrorScreen.routeName);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xffE5E6EB),
          boxShadow: [cBoxShadow],
          border: Border.all(
            color: solvedBorderColor,
            width: solvedBorderWidth,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Container(
                      child: Text(
                        animal.username,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  Text(_postedAgo),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: cornerColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      format(distanceInMeters),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(animal.address),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                child: Text(
                  animal.description,
                  maxLines: 4,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
