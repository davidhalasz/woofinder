import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:woof/providers/notification_counter.dart';
import 'package:woof/providers/notifications.dart';

import 'package:woof/screens/addAnimalPage/add_animal_screen.dart';
import 'package:woof/screens/animalDetailPage/animal_detail_screen.dart';
import 'package:woof/screens/animalDetailPage/image_view_screen.dart';
import 'package:woof/screens/authPage/auth_screen.dart';
import 'package:woof/screens/authPage/reset_password_screen.dart';
import 'package:woof/screens/errorPage/error_screen.dart';
import 'package:woof/screens/mainPage/animals_screen.dart';
import 'package:woof/providers/found_animals.dart';
import 'package:woof/screens/notificationsPage/notificationScreen.dart';
import 'package:woof/screens/settingsPage/screens/AccountPage/account_settings_screen.dart';
import 'package:woof/screens/settingsPage/screens/ReportsPage/reports_screen.dart';
import 'package:woof/screens/settingsPage/screens/uploadedAnimalPage/uploaded_animals_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'helpers/db_helper.dart';
import 'helpers/value_notifiers.dart';
import 'providers/current_location.dart';

import 'constants.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

String? selectedNotificationPayload;
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");
Future<bool> isTheSameUser(RemoteMessage messaging) async {
  final String currentUser = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic> data = messaging.data;
  if (data['uid'] == currentUser) {
    return true;
  } else {
    return false;
  }
}

String initPayload = '';

Future<LocationData> _getCurrentLocation() => Location().getLocation();

int getDistanceInMeters(currLat, currLng, lat, lng) {
  return Geolocator.distanceBetween(
    currLat,
    currLng,
    lat,
    lng,
  ).round();
}

Future<bool> isValidDistance(
    RemoteMessage messaging, int dist, double currLat, double currLng) async {
  Map<String, dynamic> data = messaging.data;

  var lat = double.parse(data['latitude']);
  var lng = double.parse(data['longitude']);

  int distance = getDistanceInMeters(currLat, currLng, lat, lng);
  var distanceInKm = (distance / 1000).round();

  print('Distance is: ${distanceInKm.toString()}');
  if (distanceInKm < dist) {
    return true;
  }
  return false;
}

showNotification(RemoteMessage message) {
  Map<String, dynamic> data = message.data;
  var body = '';

  if (data["body"] != null) {
    if (data["body"] == "commentedOnFollowedPost") {
      body = "Someone commented on a post you have wrote a comment.";
    } else if (data["body"] == "commentedOnOwnPost") {
      body = "Someone commented on your post.";
    } else {
      body = data["body"];
    }

    flutterLocalNotificationsPlugin.show(
      data.hashCode,
      data["title"],
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: IOSNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true),
      ),
      payload: data['animalId'],
    );
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('onBackground called');
  await Firebase.initializeApp();
  final String currentUser = FirebaseAuth.instance.currentUser!.uid;
  final isEmpty = await CurrentLocation().isEmptyTable();
  if (!isEmpty && message.data['uid'] != null) {
    final currLocation =
        await CurrentLocation().fetchAndSetLocation(currentUser);
    final double currLat = double.parse(currLocation.latitude);
    final double currLng = double.parse(currLocation.longitude);
    final int dist = currLocation.distance;
    bool isValid = await isValidDistance(message, dist, currLat, currLng);
    if (isValid) {
      print('onBackgroundMessage');
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(currentUser)
          .collection('notification')
          .add({
        'animalId': message.data['animalId'],
        'userName': message.data['title'],
        'uid': message.data['uid'],
        'action': 'newAnimalAdded',
        'createdAt': Timestamp.now(),
      });
      showNotification(message);
      notifierCounter.value = notifierCounter.value + 1;
    }
  }
  if (message.data['commentSender'] != null) {
    if (message.data['commentSender'] != currentUser) {
      final comments = await FirebaseFirestore.instance
          .collection('comments')
          .doc(message.data['animalId'])
          .collection('comment')
          .get();
      final documents = comments.docs;
      for (var i = 0; i < documents.length; i++) {
        var currComment = documents[i].data();
        if (currComment['userId'] == currentUser) {
          showNotification(message);
          notifierCounter.value = notifierCounter.value + 1;
          break;
        }
      }
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _initialzationSettingsAndriod =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final IOSInitializationSettings _initialzationSettingsIOS =
      IOSInitializationSettings();
  final InitializationSettings _initializationSettings = InitializationSettings(
      android: _initialzationSettingsAndriod, iOS: _initialzationSettingsIOS);
  _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await _flutterLocalNotificationsPlugin.initialize(
    _initializationSettings,
    onSelectNotification: (payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      initPayload = payload!;
      await navigatorKey.currentState!.push(CupertinoPageRoute<void>(
        builder: (BuildContext context) => AnimalDetailScreen(payload, true),
      ));
    },
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  onClickNotificationHandler(RemoteMessage message) async {
    Map<String, dynamic> data = message.data;
    print(data);
  }

  void getCurrLoc() async {
    final String currentUser = FirebaseAuth.instance.currentUser!.uid;
    final location = await _getCurrentLocation();
    final bool empty = await CurrentLocation().isEmptyTable();
    if (empty) {
      CurrentLocation().addLocation(
        currLatitude: location.latitude.toString(),
        currLlongitude: location.longitude.toString(),
        distance: 60,
        id: currentUser,
      );
    }
  }

  void getCurrNotification() async {
    final String currentUser = FirebaseAuth.instance.currentUser!.uid;
    NotificationCounter().fetchAndSetLocation(currentUser);
  }

  @override
  void initState() {
    super.initState();
    final messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic('animal');
    messaging.subscribeToTopic('notifications');

    getCurrLoc();
    getCurrNotification();

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      if (message != null) {
        Provider.of<FoundAnimals>(context).fetchAndSetAnimals().then((_) {
          onClickNotificationHandler(message);
        });
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final String currentUser = FirebaseAuth.instance.currentUser!.uid;
      final isEmptyLoc = await CurrentLocation().isEmptyTable();
      if (!isEmptyLoc && message.data['uid'] != null) {
        final currLocation =
            await CurrentLocation().fetchAndSetLocation(currentUser);
        final double currLat = double.parse(currLocation.latitude.toString());
        final double currLng =
            double.parse(currLocation.longitude.toLowerCase());
        final int dist = currLocation.distance;
        bool isValid = await isValidDistance(message, dist, currLat, currLng);
        if (isValid && currentUser != message.data['uid']) {
          print('onMessageListen');
          showNotification(message);
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(currentUser)
              .collection('notification')
              .add({
            'animalId': message.data['animalId'],
            'userName': message.data['title'],
            'uid': message.data['uid'],
            'action': 'newAnimalAdded',
            'createdAt': Timestamp.now(),
          });
          notifierCounter.value = notifierCounter.value + 1;
        }
      }
      if (message.data['commentSender'] != null) {
        if (message.data['commentSender'] != currentUser) {
          final comments = await FirebaseFirestore.instance
              .collection('comments')
              .doc(message.data['animalId'])
              .collection('comment')
              .get();
          final documents = comments.docs;
          for (var i = 0; i < documents.length; i++) {
            var currComment = documents[i].data();
            if (currComment['userId'] == currentUser) {
              showNotification(message);
              notifierCounter.value = notifierCounter.value + 1;
              break;
            }
          }
        }
      }
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      Map<String, dynamic> data = message.data;
      print(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => FoundAnimals()),
        ChangeNotifierProvider(create: (ctx) => Notifications())
      ],
      //create: (ctx) => FoundAnimals(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Woofy',
        navigatorKey: navigatorKey,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', ''),
          Locale('hu', ''),
        ],
        theme: ThemeData(
          //primaryColor: cPrimaryColor,
          textTheme: GoogleFonts.robotoTextTheme(),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.black),
            hintStyle: TextStyle(color: Colors.grey),
            focusColor: cSecondaryColor,
          ),
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: cPrimaryColor),
        ),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, userSnapshot) {
              if (userSnapshot.hasData) {
                return AnimalsScreen();
              }
              return AuthScreen();
            }),
        onGenerateRoute: (settings) {
          if (settings.name == "/image_view") {
            return PageRouteBuilder(
                settings: settings,
                pageBuilder: (_, __, ___) => ImageViewScreen(),
                transitionDuration: Duration(seconds: 0));
          }

          switch (settings.name) {
            case ImageViewScreen.routeName:
              return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) => ImageViewScreen(),
                  transitionDuration: Duration(milliseconds: 400));
            case AnimalsScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => AnimalsScreen(), settings: settings);
            case AnimalDetailScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => AnimalDetailScreen(initPayload, true),
                  settings: settings);
            case AddAnimalScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => AddAnimalScreen(), settings: settings);
            case NotificationScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => NotificationScreen(), settings: settings);
            case ErrorScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => ErrorScreen(), settings: settings);
            case UploadedAnimalScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => UploadedAnimalScreen(), settings: settings);
            case AccountSettingsScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => AccountSettingsScreen(), settings: settings);
            case ReportsScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => ReportsScreen(), settings: settings);
            case ResetPasswordScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => ResetPasswordScreen(), settings: settings);
          }
          return CupertinoPageRoute(builder: (_) => AnimalsScreen());
        },
      ),
    );
  }
}
