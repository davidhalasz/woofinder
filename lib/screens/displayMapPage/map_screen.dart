import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:woof/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MapScreen extends StatefulWidget {
  final bool isSelecting;

  MapScreen({
    this.isSelecting = false,
  });
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  late LatLng _initialcameraposition;
  late GoogleMapController _controller;

  @override
  void initState() {
    super.initState();
    _getCurrentLatLng();
  }

  void _getCurrentLatLng() async {
    await Location().getLocation().then((currLocation) {
      setState(() {
        _initialcameraposition = new LatLng(
          currLocation.latitude as double,
          currLocation.longitude as double,
        );
      });
    });
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _selectLocation(_initialcameraposition);
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
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
              icon: Icon(Icons.check),
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
