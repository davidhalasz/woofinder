import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:woof/constants.dart';
import 'package:woof/helpers/location_helper.dart';
import '../../displayMapPage/map_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  Future<void> _getCurrentLocation() async {
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

  Future<void> _getCurrentLatLng() async {
    final locData = await Location().getLocation();
    setState(() {
      lat = locData.latitude;
      lng = locData.longitude;
    });
  }

  Future<void> _selectOnMap() async {
    _getCurrentLatLng();
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
          isSelecting: true,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(0xffE5E6EB),
          boxShadow: [
            BoxShadow(
                offset: Offset(8, 8), color: Colors.black38, blurRadius: 15),
            BoxShadow(
                offset: Offset(-8, -8),
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
                          Shadow(
                              offset: Offset(3, 3),
                              color: Colors.black38,
                              blurRadius: 18),
                          Shadow(
                              offset: Offset(-3, -3),
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
            Row(
              children: <Widget>[
                TextButton.icon(
                  icon: Icon(
                    Icons.location_on,
                  ),
                  label: Text(
                    AppLocalizations.of(context).currentLoc,
                  ),
                  style: TextButton.styleFrom(
                    primary: cSecondaryColor,
                  ),
                  onPressed: _getCurrentLocation,
                ),
                TextButton.icon(
                  icon: Icon(
                    Icons.map,
                  ),
                  label: Text(
                    AppLocalizations.of(context).seletOnMap,
                  ),
                  style: TextButton.styleFrom(
                    primary: cSecondaryColor,
                  ),
                  onPressed: _selectOnMap,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
