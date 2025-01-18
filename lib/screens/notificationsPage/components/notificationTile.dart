import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:woof/constants.dart';
import 'package:woof/models/my_notification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:woof/screens/animalDetailPage/animal_detail_screen.dart';

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

    var postedDateTime = notification.createdAt.toDate();

    String _postedAgo = postedAgo(postedDateTime);

    var content = '';
    if (notification.action == 'commentedOnFollowedPost') {
      content = "wrote a comment on a found animal you have commented.";
    }
    if (notification.action == 'commentedOnOwnPost') {
      content = "wrote a comment on your found animal.";
    }
    if (notification.action == 'newAnimalAdded') {
      content = "found a new animal!";
    }
    return ListTile(
      textColor: cGrayBGColor,
      leading: Container(
        height: double.infinity,
        child: Icon(
          Icons.circle_outlined,
          color: cGrayBGColor,
          size: 14,
        ),
      ),
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 15.0,
          ),
          children: <TextSpan>[
            TextSpan(
              text: notification.userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: " "),
            TextSpan(text: content),
          ],
        ),
      ),
      subtitle: Text(_postedAgo),
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) =>
                  AnimalDetailScreen(notification.animalId, false)),
        );
      },
    );
  }
}
