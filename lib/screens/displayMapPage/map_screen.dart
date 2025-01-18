import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:woof/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:woof/models/locationSql.dart';

class MapScreen extends StatefulWidget {
  final bool isSelecting;
  final LocationSql currentLoc;

  MapScreen({
    this.isSelecting = false,
    required this.currentLoc,
  });
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  late GoogleMapController _controller;

  @override
  void initState() {
    super.initState();
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    LatLng _initialcameraposition = LatLng(
        double.parse(widget.currentLoc.latitude),
        double.parse(widget.currentLoc.longitude));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).selectPlace),
        backgroundColor: cBlackBGColor,
        actions: <Widget>[
          if (widget.isSelecting)
            IconButton(
              onPressed: _pickedLocation == null
                  ? null
                  : () {
                      Navigator.of(context).pop(_pickedLocation);
                    },
              icon: const Icon(Icons.check),
            )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialcameraposition,
          zoom: 16,
        ),
        onMapCreated: _onMapCreated,
        onTap: widget.isSelecting ? _selectLocation : null,
        markers: _pickedLocation == null
            ? {}
            : [
                Marker(
                  markerId: MarkerId('m1'),
                  position: _pickedLocation ?? _initialcameraposition,
                ),
              ].toSet(),
      ),
    );
  }
}
