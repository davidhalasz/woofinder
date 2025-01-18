import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
import 'components/body.dart';
import 'components/bottom_nav_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/found_animals.dart';
import 'package:permission_handler/permission_handler.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({Key? key}) : super(key: key);
  static const routeName = '/animal-screen';

  @override
  _AnimalsScreenState createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  var _isInit = true;
  var _isLoading = false;
  LocationSql? currentLocation;
  final String currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _refreshNotifications(context);
  }

  @override
  void dispose() {
    notifierCounter.dispose();
    super.dispose();
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
    super.didChangeDependencies();
  }

  Future<void> _getCurrentLocation() async {
    if (await Permission.location.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    }
    if (await Permission.location.request().isGranted) {
      final locData = await Location().getLocation();
      var currentLatitude = locData.latitude;
      var currentLongitude = locData.longitude;
      final bool empty = await CurrentLocation().isEmptyTable();
      if (!empty) {
        final currentSql =
            await CurrentLocation().fetchAndSetLocation(currentUser);
        await CurrentLocation().addLocation(
          id: currentUser,
          distance: currentSql.distance,
          currLatitude: currentLatitude.toString(),
          currLlongitude: currentLongitude.toString(),
        );
      } else {
        await CurrentLocation().addLocation(
          currLatitude: currentLatitude.toString(),
          currLlongitude: currentLongitude.toString(),
          distance: 60,
          id: currentUser,
        );
      }
    }
    var status = await Permission.location.status;
    if (status.isDenied) {
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pop();
    }
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
      );
    }
    return locInfo;
  }

  Future<void> _refreshAnimals(BuildContext context) async {
    await _getCurrentLocation();
    await Provider.of<FoundAnimals>(context, listen: false)
        .fetchAndSetAnimals();
  }

  Future<void> _refreshNotifications(BuildContext context) async {
    await Provider.of<Notifications>(context, listen: false)
        .fetchAndSetNotifications(currentUser);
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
        ? Center(
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
                  return Center(
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
                              icon: Icon(Icons.pets),
                              color: counterValue > 0
                                  ? cSecondaryColor
                                  : cGrayBGColor,
                            );
                          }),
                    ],
                  ),
                  body: Body(lat, lng),
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
