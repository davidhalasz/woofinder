import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:woof/providers/notifications.dart';
import 'package:woof/screens/authPage/verify.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

Future<bool> isValidDistanceIOS(Map<String, dynamic> messaging, int dist,
    double currLat, double currLng) async {
  var lat = double.parse(messaging['latitude']);
  var lng = double.parse(messaging['longitude']);

  int distance = getDistanceInMeters(currLat, currLng, lat, lng);
  var distanceInKm = (distance / 1000).round();

  print('Distance is: ${distanceInKm.toString()}');
  if (distanceInKm < dist) {
    return true;
  }
  return false;
}

showNotification(RemoteMessage message, String locale) async {
  Map<String, dynamic> data = message.data;
  final String defaultLocale = Intl.getCurrentLocale();
  var body = '';
  if (data["body"] != null) {
    if (data["body"] == "CommentedOnFollowedPost") {
      if (locale == "hu_HU") {
        body = "Valaki reagált egy bejegyzésre, amihez korábban hosszászóltál.";
      } else {
        body = "Someone reacted to a post where you commented.";
      }
    } else if (data["body"] == "commentedOnOwnPost") {
      if (locale == "hu_HU") {
        body = "Valaki hozzászólt a bejegyzésedhez.";
      } else {
        body = "Someone commented on your post.";
      }
    } else {
      if (locale == "hu_HU") {
        body = data["title"] + " talált egy állatot a közeledben.";
      } else {
        body = data["title"] + " just found an animal.";
      }
    }

    await flutterLocalNotificationsPlugin.show(
      data.hashCode,
      "Woofinder",
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          priority: Priority.high,
        ),
        iOS: IOSNotificationDetails(),
      ),
      payload: data['animalId'],
    );
  }
}

Future<String> getNotifMessageIOS(Map<String, dynamic> message) async {
  final String defaultLocale = Platform.localeName;
  String body = '';
  if (message["body"] != null) {
    if (message["body"] == "CommentedOnFollowedPost") {
      if (defaultLocale == "hu_HU") {
        body = "Valaki reagált egy bejegyzésre, amihez korábban hosszászóltál.";
      } else {
        body = "Someone reacted to a post where you commented.";
      }
    } else if (message["body"] == "commentedOnOwnPost") {
      if (defaultLocale == "hu_HU") {
        body = "Valaki hozzászólt a bejegyzésedhez.";
      } else {
        body = "Someone commented on your post.";
      }
    } else {
      if (defaultLocale == "hu_HU") {
        body = message["title"] + " talált egy állatot a közeledben.";
      } else {
        body = message["title"] + " just found an animal.";
      }
    }
  }
  return body;
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('onBackground called');
  await Firebase.initializeApp();
  final String currentUser = FirebaseAuth.instance.currentUser!.uid;
  final isEmpty = await CurrentLocation().isEmptyTable();
  final currLocation = await CurrentLocation().fetchAndSetLocation(currentUser);
  if (!isEmpty && message.data['uid'] != null) {
    final double currLat = double.parse(currLocation.latitude);
    final double currLng = double.parse(currLocation.longitude);
    final int dist = currLocation.distance;
    bool isValid = await isValidDistance(message, dist, currLat, currLng);
    if (isValid) {
      print('onBackgroundMessage');
      await Notifications().addNotification(
        id: DateTime.now().toString(),
        userName: message.data['title'],
        action: message.data['body'],
        createdAt: DateTime.now(),
        animalId: message.data['animalId'],
        uid: currentUser,
      );
      showNotification(message, currLocation.locale);
      notifierCounter.value = notifierCounter.value + 1;
    }
  }
  if (message.data['toUser'] != null) {
    if (message.data['toUser'] == currentUser) {
      await Notifications().addNotification(
        id: DateTime.now().toString(),
        userName: message.data['title'],
        action: message.data['body'],
        createdAt: DateTime.now(),
        animalId: message.data['animalId'],
        uid: currentUser,
      );
      await showNotification(message, currLocation.locale);
      notifierCounter.value = notifierCounter.value + 1;
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _initialzationSettingsAndriod =
      AndroidInitializationSettings('noticon');
  final IOSInitializationSettings _initialzationSettingsIOS =
      IOSInitializationSettings(
          onDidReceiveLocalNotification: (id, title, body, payload) =>
              onSelectNotification(payload!));

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

Future onSelectNotification(String payload) async {
  if (payload != null) {
    debugPrint('notification payload: ' + payload);
  }
  initPayload = payload;
  await navigatorKey.currentState!.push(CupertinoPageRoute<void>(
    builder: (BuildContext context) => AnimalDetailScreen(payload, true),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('com.example.woof/noti');
  static const platformNotification =
      MethodChannel('com.example.woof/showNotif');

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
        locale: Platform.localeName,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    platform.setMethodCallHandler(myUtilsHandler);
    final messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic('animal');
    messaging.subscribeToTopic('notifications');
    messaging.requestPermission(
      alert: true,
      sound: false,
      badge: true,
      provisional: false,
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

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("onMessage called");
      final String currentUser = FirebaseAuth.instance.currentUser!.uid;
      final isEmptyLoc = await CurrentLocation().isEmptyTable();
      final currLocation =
          await CurrentLocation().fetchAndSetLocation(currentUser);
      if (!isEmptyLoc && message.data['uid'] != null) {
        final double currLat = double.parse(currLocation.latitude.toString());
        final double currLng =
            double.parse(currLocation.longitude.toLowerCase());
        final int dist = currLocation.distance;
        bool isValid = await isValidDistance(message, dist, currLat, currLng);
        if (isValid && currentUser != message.data['uid']) {
          await Notifications().addNotification(
            id: DateTime.now().toString(),
            userName: message.data['title'],
            action: message.data['body'],
            createdAt: DateTime.now(),
            animalId: message.data['animalId'],
            uid: currentUser,
          );
          showNotification(message, currLocation.locale);
          notifierCounter.value = notifierCounter.value + 1;
        }
      }

      if (message.data['toUser'] != null) {
        if (message.data['toUser'] == currentUser) {
          await Notifications().addNotification(
            id: DateTime.now().toString(),
            userName: message.data['title'],
            action: message.data['body'],
            createdAt: DateTime.now(),
            animalId: message.data['animalId'],
            uid: currentUser,
          );
          await showNotification(message, currLocation.locale);
          notifierCounter.value = notifierCounter.value + 1;
        }
      }
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      Map<String, dynamic> data = message.data;
      print(data);
    });
  }

  Future<dynamic> myUtilsHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'messageReceived':
        print("Flutter side");
        var args = methodCall.arguments;
        var message = _dictToMap(args.toString());

        final String currentUser = FirebaseAuth.instance.currentUser!.uid;
        final isEmptyLoc = await CurrentLocation().isEmptyTable();
        if (!isEmptyLoc && message['uid'] != null) {
          final currLocation =
              await CurrentLocation().fetchAndSetLocation(currentUser);
          final double currLat = double.parse(currLocation.latitude.toString());
          final double currLng =
              double.parse(currLocation.longitude.toLowerCase());
          final int dist = currLocation.distance;
          bool isValid =
              await isValidDistanceIOS(message, dist, currLat, currLng);
          if (isValid && currentUser != message['uid']) {
            String bodyMsg = await getNotifMessageIOS(message);
            print(bodyMsg);
            notifierCounter.value = notifierCounter.value + 1;
            await Notifications().addNotification(
              id: DateTime.now().toString(),
              userName: message['title'],
              action: message['body'],
              createdAt: DateTime.now(),
              animalId: message['animalId'],
              uid: currentUser,
            );
            await platformNotification.invokeMethod(
                'sendNotification', bodyMsg);
          }
        }
        if (message['toUser'] != null) {
          String bodyMsg = await getNotifMessageIOS(message);
          print(bodyMsg);
          if (message['toUser'] == currentUser) {
            await Notifications().addNotification(
              id: DateTime.now().toString(),
              userName: message['title'],
              action: message['body'],
              createdAt: DateTime.now(),
              animalId: message['animalId'],
              uid: currentUser,
            );
            notifierCounter.value = notifierCounter.value + 1;
            await platformNotification.invokeMethod(
                'sendNotification', bodyMsg);
          }
        }
        break;
      case 'error':
        print('error');
        break;
      default:
        print('default');
    }
  }

  Map<String, dynamic> _dictToMap(String dict) {
    var withoutSpace = dict.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    var tagName = withoutSpace;

    if (tagName != null && tagName.length > 0) {
      tagName = tagName.substring(0, tagName.length - 1);
      tagName = tagName.substring(1);
    }
    final splitText = tagName.split(',');
    Map<String, dynamic> values = {};
    splitText.forEach((element) => values[element.split(':')[0] as String] =
        element.split(':')[1] as String);
    return values;
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: false,
        );
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
        localizationsDelegates: const [
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
                return VerifyScreen();
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
                  builder: (_) => const ErrorScreen(), settings: settings);
            case UploadedAnimalScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => const UploadedAnimalScreen(),
                  settings: settings);
            case AccountSettingsScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => const AccountSettingsScreen(),
                  settings: settings);
            case ReportsScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => ReportsScreen(), settings: settings);
            case ResetPasswordScreen.routeName:
              return CupertinoPageRoute(
                  builder: (_) => ResetPasswordScreen(), settings: settings);
          }
          return CupertinoPageRoute(builder: (_) => const AnimalsScreen());
        },
      ),
    );
  }
}
