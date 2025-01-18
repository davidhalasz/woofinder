import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:woof/helpers/value_notifiers.dart';
import 'package:woof/providers/found_animals.dart';
import 'package:woof/providers/notifications.dart';
import 'package:woof/screens/notificationsPage/components/notificationTile.dart';

import '../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({Key? key}) : super(key: key);
  static const routeName = '/notifications';

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final String currentUser = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _refreshNotifications(BuildContext context) async {
    await Provider.of<Notifications>(context, listen: false)
        .fetchAndSetNotifications(currentUser);
  }

  @override
  Widget build(BuildContext context) {
    final notifiData = Provider.of<Notifications>(context);
    Provider.of<FoundAnimals>(context, listen: false).fetchAndSetAnimals();
    final notifications = notifiData.notifications;
    return RefreshIndicator(
      onRefresh: () => _refreshNotifications(context),
      child: Scaffold(
        backgroundColor: cBlackBGColor,
        appBar: AppBar(
          backgroundColor: cBlackBGColor,
          title: Text(
            AppLocalizations.of(context).notification,
          ),
          centerTitle: false,
          elevation: 0,
          leading: IconButton(
              padding: const EdgeInsets.only(left: 20),
              icon: SvgPicture.asset(
                'assets/icons/left-arrow.svg',
                color: Colors.white,
                height: 28,
              ),
              onPressed: () {
                Navigator.pop(context);
                notifierCounter.value = 0;
              }),
        ),
        body: ListView.builder(
          shrinkWrap: true,
          itemCount: notifications.length,
          itemBuilder: (context, i) => NotificationTile(notifications[i]),
        ),
      ),
    );
  }
}
