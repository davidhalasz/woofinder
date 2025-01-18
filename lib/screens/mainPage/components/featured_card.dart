import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:woof/models/animals.dart';
import 'package:woof/providers/found_animals.dart';
import 'package:woof/screens/animalDetailPage/animal_detail_screen.dart';
import 'package:woof/screens/errorPage/error_screen.dart';
import '../../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FeaturedCard extends StatefulWidget {
  final Animals featured;

  const FeaturedCard({Key? key, required this.featured}) : super(key: key);

  @override
  _FeaturedCardState createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<FeaturedCard> {
  @override
  Widget build(BuildContext context) {
    var solvedBorderColor = cSecondaryColor;
    var solvedBorderWidth = 3.0;
    var cornerColor = cSecondaryColor;
    var solved = widget.featured.solved;

    if (solved) {
      solvedBorderColor = greenColor;
      solvedBorderWidth = 3.0;
      cornerColor = greenColor;
    }

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

    var postedDateTime = widget.featured.createdAt.toDate();

    String _postedAgo = postedAgo(postedDateTime);

    Timer.periodic(const Duration(seconds: 30), (timer) {
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
            .doc(widget.featured.id)
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
        margin: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xffE5E6EB),
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
                    padding: const EdgeInsets.only(left: 10),
                    child: Container(
                      child: Text(
                        widget.featured.username,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  Text(_postedAgo),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: cornerColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context).pinned,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                child: Text(
                  widget.featured.description,
                  maxLines: 4,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
