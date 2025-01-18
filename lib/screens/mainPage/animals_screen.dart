import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:woof/constants.dart';
import 'package:woof/helpers/value_notifiers.dart';
import 'package:woof/models/locationSql.dart';
import 'package:woof/providers/current_location.dart';
import 'package:woof/providers/notifications.dart';
import 'package:woof/screens/notificationsPage/notificationScreen.dart';
import 'package:woof/screens/settingsPage/settings_screen.dart';
import '../../providers/notification_counter.dart';
import 'components/body.dart';
import 'components/bottom_nav_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/found_animals.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({Key? key}) : super(key: key);
  static const routeName = '/animal-screen';

  @override
  _AnimalsScreenState createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  var _isInit = true;
  var _isLoading = false;
  var _enabledLocation = false;
  LocationSql? currentLocation;
  final String currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    CurrentLocation().firstLocationSetting(currentUser);
    getCurrNotification();
    _refreshAnimals(context);
    _refreshNotifications(context);
  }

  @override
  void dispose() {
    super.dispose();
    _isLoading = false;
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<FoundAnimals>(context).fetchAndSetAnimals().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;

    if (!_enabledLocation) {
      Future.delayed(const Duration(seconds: 5), () {
        if (this.mounted) {
          setState(() {
            _enabledLocation = true;
          });
        }
      });
    }
    super.didChangeDependencies();
  }

  void getCurrNotification() async {
    final String currentUser = FirebaseAuth.instance.currentUser!.uid;
    NotificationCounter().fetchAndSetLocation(currentUser);
  }

  Future<void> _getCurrentLocation() async {
    Map<handler.Permission, handler.PermissionStatus> statuses = await [
      handler.Permission.location,
    ].request();

    if (statuses[handler.Permission.location]!.isGranted ||
        statuses[handler.Permission.location]!.isLimited) {
      final locData = await Location().getLocation();
      var currentLatitude = locData.latitude;
      var currentLongitude = locData.longitude;
      final bool empty = await CurrentLocation().isEmptyTable();
      if (!empty) {
        final currentSql =
            await CurrentLocation().fetchAndSetLocation(currentUser);
        addLocation(currentLatitude!, currentLongitude!, currentSql.distance);
      } else {
        addLocation(currentLatitude!, currentLongitude!, 60);
      }
      setState(() {
        _enabledLocation = true;
      });
    } else {
      if (statuses[handler.Permission.location]!.isPermanentlyDenied ||
          statuses[handler.Permission.location]!.isDenied) {
        setState(() {
          _enabledLocation = false;
        });
      }
    }
    if (await CurrentLocation().isEmptyTable()) {
      await CurrentLocation().firstLocationSetting(currentUser).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Future<void> addLocation(double lat, double lng, int dist) async {
    await CurrentLocation()
        .addLocation(
      currLatitude: lat.toString(),
      currLlongitude: lng.toString(),
      distance: dist,
      id: currentUser,
      locale: Platform.localeName,
    )
        .then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<LocationSql?> _getDataFromSql() async {
    LocationSql? locInfo;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final bool empty = await CurrentLocation().isEmptyTable();
    if (!empty) {
      final currentSql = await CurrentLocation().fetchAndSetLocation(userId);
      locInfo = LocationSql(
        id: userId,
        distance: currentSql.distance,
        latitude: currentSql.latitude,
        longitude: currentSql.longitude,
        locale: currentSql.locale,
      );
    } else {
      await CurrentLocation().firstLocationSetting(userId);
      final currentSql = await CurrentLocation().fetchAndSetLocation(userId);
      locInfo = LocationSql(
        id: userId,
        distance: currentSql.distance,
        latitude: currentSql.latitude,
        longitude: currentSql.longitude,
        locale: currentSql.locale,
      );
    }
    return locInfo;
  }

  Future<void> _refreshAnimals(BuildContext context) async {
    print('refresh');
    await _getCurrentLocation();
    await Provider.of<FoundAnimals>(context, listen: false)
        .fetchAndSetAnimals()
        .then((value) => {
              setState(() {
                _isLoading = false;
              })
            });
  }

  Future<void> _refreshNotifications(BuildContext context) async {
    await Provider.of<Notifications>(context, listen: false)
        .fetchAndSetNotifications(currentUser)
        .then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _openAppSetting() async {
    await handler.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    void _navigatorToSettings(BuildContext context) async {
      final locationInfo = await _getDataFromSql();
      if (locationInfo != null) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => SettingsScreen(locationInfo),
          ),
        ).then((value) {
          setState(() {
            _getDataFromSql();
          });
        });
      }
    }

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: cSecondaryColor,
              backgroundColor: cBlackBGColor,
            ),
          )
        : RefreshIndicator(
            onRefresh: () => _refreshAnimals(context),
            color: cSecondaryColor,
            child: FutureBuilder(
              future: _getDataFromSql(),
              builder:
                  (BuildContext context, AsyncSnapshot<LocationSql?> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: cSecondaryColor,
                    ),
                  );
                }

                var locationInfo = snapshot.data!;
                var lat = double.parse(locationInfo.latitude);
                var lng = double.parse(locationInfo.longitude);

                return Scaffold(
                  backgroundColor: cBlackBGColor,
                  appBar: AppBar(
                    backgroundColor: cBlackBGColor,
                    title: Text(AppLocalizations.of(context).mainTitle),
                    centerTitle: false,
                    elevation: 0,
                    actions: <Widget>[
                      ValueListenableBuilder(
                          valueListenable: notifierCounter,
                          builder: (context, int counterValue, child) {
                            return IconButton(
                              onPressed: () {
                                if (counterValue > 0) {
                                  _refreshNotifications(context);
                                }
                                Navigator.of(context)
                                    .pushNamed(NotificationScreen.routeName);
                              },
                              icon: const Icon(Icons.pets),
                              color: counterValue > 0
                                  ? cSecondaryColor
                                  : cGrayBGColor,
                            );
                          }),
                    ],
                  ),
                  body: Stack(
                    children: <Widget>[
                      Body(lat, lng),
                      Visibility(
                        visible: !_enabledLocation,
                        child: Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: cSecondaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _enabledLocation = true;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: AppLocalizations.of(context)
                                                .enableLocation,
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          TextSpan(
                                            text: AppLocalizations.of(context)
                                                .enableLocationLink,
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                _openAppSetting();
                                              },
                                          ),
                                          const TextSpan(
                                            text: '!',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: BottomNavBar(
                    currentLoc: LatLng(lat, lng),
                    locSql: locationInfo,
                    navigatorToSettings: _navigatorToSettings,
                  ),
                );
              },
            ),
          );
  }
}
