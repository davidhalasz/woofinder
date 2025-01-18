import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:woof/models/locationSql.dart';
import 'package:woof/screens/addAnimalPage/add_animal_screen.dart';
import 'package:woof/screens/displayMapPage/store_map_screen.dart';

class BottomNavBar extends StatelessWidget {
  final LatLng? currentLoc;
  final LocationSql locSql;
  final Function navigatorToSettings;

  BottomNavBar({
    this.currentLoc,
    required this.locSql,
    required this.navigatorToSettings,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10,
      ),
      height: 70,
      color: Color(0xff313131),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push<LatLng>(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (ctx) => StoreMapScreen(currentLoc!),
                ),
              );
            },
            icon: SvgPicture.asset(
              'assets/icons/map.svg',
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AddAnimalScreen.routeName);
            },
            icon: SvgPicture.asset(
              'assets/icons/add.svg',
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              navigatorToSettings(context);
              /*
              Navigator.of(context).push<LocationSql>(
                CupertinoPageRoute(
                  builder: (ctx) => SettingsScreen(locSql),
                ),
              );
              */
            },
            icon: SvgPicture.asset(
              'assets/icons/lines.svg',
            ),
          ),
        ],
      ),
    );
  }
}
