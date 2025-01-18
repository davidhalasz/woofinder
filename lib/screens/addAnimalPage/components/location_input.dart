import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:woof/constants.dart';
import 'package:woof/helpers/location_helper.dart';
import 'package:woof/providers/current_location.dart';
import '../../displayMapPage/map_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

class LocationInput extends StatefulWidget {
  final Function onSelectPlace;

  LocationInput(this.onSelectPlace);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _address;
  double? lat;
  double? lng;
  var _enabledLocation = false;

  @override
  void initState() {
    _enabledLocation = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _getCurrentLocation() async {
    await _checkLocationStatus();
    if (_enabledLocation) {
      final locData = await Location().getLocation();
      final staticAddress = await LocationHelper.getPlaceAddress(
        locData.latitude as double,
        locData.longitude as double,
      );
      setState(() {
        _address = staticAddress;
      });
      widget.onSelectPlace(locData.latitude, locData.longitude);
    }
  }

  Future<void> _selectOnMap() async {
    final user = FirebaseAuth.instance.currentUser!;
    var locData = await CurrentLocation().fetchAndSetLocation(user.uid);
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
          isSelecting: true,
          currentLoc: locData,
        ),
      ),
    );
    if (selectedLocation == null) {
      return;
    }
    final staticAddress = await LocationHelper.getPlaceAddress(
      selectedLocation.latitude,
      selectedLocation.longitude,
    );
    setState(() {
      _address = staticAddress;
    });
    widget.onSelectPlace(selectedLocation.latitude, selectedLocation.longitude);
  }

  Future<void> _checkLocationStatus() async {
    Map<handler.Permission, handler.PermissionStatus> statuses = await [
      handler.Permission.location,
    ].request();
    if (statuses[handler.Permission.location]!.isGranted ||
        statuses[handler.Permission.location]!.isLimited) {
      setState(() {
        _enabledLocation = true;
      });
    } else {
      if (statuses[handler.Permission.location]!.isPermanentlyDenied ||
          statuses[handler.Permission.location]!.isDenied) {
        setState(() {
          _enabledLocation = false;
        });
        if (_enabledLocation == false) {
          print("Called didchange");
          Future.delayed(const Duration(seconds: 5), () {
            if (this.mounted) {
              setState(() {
                _enabledLocation = true;
              });
            }
          });
        }
      }
    }
  }

  Future<void> _openAppSetting() async {
    await handler.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xffE5E6EB),
          boxShadow: [
            const BoxShadow(
                offset: Offset(8, 8), color: Colors.black38, blurRadius: 15),
            BoxShadow(
                offset: const Offset(-8, -8),
                color: Colors.white.withOpacity(0.75),
                blurRadius: 15),
          ],
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: 40,
              width: double.infinity,
              alignment: Alignment.center,
              child: _address == null
                  ? Text(
                      AppLocalizations.of(context).noLocChosen,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        shadows: [
                          const Shadow(
                              offset: const Offset(3, 3),
                              color: Colors.black38,
                              blurRadius: 18),
                          Shadow(
                              offset: const Offset(-3, -3),
                              color: Colors.white.withOpacity(0.85),
                              blurRadius: 18)
                        ],
                        color: Colors.grey.shade500,
                      ),
                    )
                  : Text(
                      _address!,
                    ),
            ),
            Column(
              children: <Widget>[
                Visibility(
                  visible: !_enabledLocation,
                  child: Container(
                    color: cSecondaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        .enableCurrentLocation,
                                    style: const TextStyle(color: Colors.black),
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
                                    style: TextStyle(color: Colors.black),
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
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: cBlackBGColor,
                    ),
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.location_on,
                      ),
                      label: Text(
                        AppLocalizations.of(context).currentLoc,
                      ),
                      style: TextButton.styleFrom(
                        primary: cGrayBGColor,
                      ),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 1,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      color: cBlackBGColor,
                    ),
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.map,
                      ),
                      label: Text(
                        AppLocalizations.of(context).seletOnMap,
                      ),
                      style: TextButton.styleFrom(
                        primary: cGrayBGColor,
                      ),
                      onPressed: _selectOnMap,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
