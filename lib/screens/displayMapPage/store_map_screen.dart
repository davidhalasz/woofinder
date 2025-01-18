import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:woof/constants.dart';
import 'package:woof/screens/animalDetailPage/animal_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoreMapScreen extends StatefulWidget {
  final LatLng currentLoc;

  StoreMapScreen(
    this.currentLoc,
  );

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<StoreMapScreen> {
  late BitmapDescriptor markerIcon;
  late LatLng _initialcameraposition = widget.currentLoc;
  late GoogleMapController _controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    super.initState();
    setCustomMarker();
  }

  void setCustomMarker() async {
    if (Platform.isIOS) {
      markerIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), 'assets/images/darker_pet_marker48.png');
    } else {
      markerIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          'assets/images/darker_pet_marker-138x187.png');
    }
  }

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

  Future<void> _getData() async {
    FirebaseFirestore.instance
        .collection('animal')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        final MarkerId markerId = MarkerId(element.id);
        final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(element['latitude'], element['longitude']),
          onTap: () {
            showModalBottomSheet(
                backgroundColor: cBlackBGColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                context: context,
                builder: (context) {
                  return Container(
                    height: double.infinity / 50,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    element['username'],
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: cGrayBGColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  postedAgo(element['createdAt'].toDate()),
                                  style: const TextStyle(
                                    color: cGrayBGColor,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Container(
                                child: Text(
                                  element['description'],
                                  maxLines: 5,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: cGrayBGColor,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: TextButton(
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            cSecondaryColor),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              AnimalDetailScreen(
                                                  element.id, false)),
                                    );
                                  },
                                  child: Text(
                                    AppLocalizations.of(context).moreInfo,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
          icon: markerIcon,
        );
        setState(() {
          markers[markerId] = marker;
        });
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(Utils.mapStyle);
    _controller = controller;
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cBlackBGColor,
        title: Text(AppLocalizations.of(context).foundAnimals),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('animal').snapshots(),
          builder: (context, snapshot) {
            return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.currentLoc,
                  zoom: 16,
                ),
                onMapCreated: _onMapCreated,
                markers: markers.isEmpty ? {} : Set<Marker>.of(markers.values));
          }),
    );
  }
}

class Utils {
  static String mapStyle = '''
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]
  ''';
}
