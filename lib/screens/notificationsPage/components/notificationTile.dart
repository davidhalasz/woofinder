import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:woof/constants.dart';
import 'package:woof/models/my_notification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:woof/screens/animalDetailPage/animal_detail_screen.dart';

import '../../errorPage/error_screen.dart';

class NotificationTile extends StatelessWidget {
  final MyNotification notification;
  const NotificationTile(this.notification, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    var postedDateTime = notification.createdAt;

    String _postedAgo = postedAgo(postedDateTime);

    var content = '';
    if (notification.action == 'CommentedOnFollowedPost') {
      content = AppLocalizations.of(context).commentedOnFollowedPost;
    }
    if (notification.action == 'commentedOnOwnPost') {
      content = AppLocalizations.of(context).commentedOnOwnPost;
    } else {
      content = AppLocalizations.of(context).foundNewAnimal;
    }
    return ListTile(
      textColor: cGrayBGColor,
      leading: Container(
        height: double.infinity,
        child: const Icon(
          Icons.circle_outlined,
          color: cGrayBGColor,
          size: 14,
        ),
      ),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 15.0,
          ),
          children: <TextSpan>[
            TextSpan(
              text: notification.userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const TextSpan(text: " "),
            TextSpan(text: content),
          ],
        ),
      ),
      subtitle: Text(_postedAgo),
      onTap: () async {
        final animalSnapshot = await FirebaseFirestore.instance
            .collection('animal')
            .doc(notification.animalId)
            .get();

        if (animalSnapshot.exists) {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) =>
                    AnimalDetailScreen(notification.animalId, false)),
          );
        } else {
          Navigator.of(context).pushNamed(ErrorScreen.routeName);
        }
      },
    );
  }
}
