import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:woof/models/locationSql.dart';
import 'package:woof/providers/current_location.dart';
import 'package:woof/screens/settingsPage/screens/AccountPage/account_settings_screen.dart';
import 'package:woof/screens/settingsPage/screens/ReportsPage/reports_screen.dart';
import 'package:woof/screens/settingsPage/screens/uploadedAnimalPage/uploaded_animals_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants.dart';

class SettingsScreen extends StatefulWidget {
  final LocationSql locSql;

  SettingsScreen(
    this.locSql, {
    Key? key,
  }) : super(key: key);
  static const routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  dynamic userData;
  double? distance;

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      getUserName().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.initState();
    distance = widget.locSql.distance.toDouble();
  }

  Future<void> getUserName() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      userData = userDoc;
    });
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      getUserName().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBlackBGColor,
      appBar: AppBar(
        backgroundColor: cBlackBGColor,
        elevation: 0,
        leading: IconButton(
            padding: EdgeInsets.only(left: 20),
            icon: SvgPicture.asset(
              'assets/icons/left-arrow.svg',
              color: Colors.white,
              height: 28,
            ),
            onPressed: () {
              CurrentLocation().addLocation(
                id: user.uid,
                distance: distance!.toInt(),
                currLatitude: widget.locSql.latitude,
                currLlongitude: widget.locSql.longitude,
                locale: widget.locSql.locale,
              );

              Navigator.pop(context);
            }),
        centerTitle: false,
        title: Text(
          AppLocalizations.of(context).back,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: cSecondaryColor,
                backgroundColor: cBlackBGColor,
              ),
            )
          : Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    width: double.infinity,
                    child: Text(
                      AppLocalizations.of(context).settings,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                UploadedAnimalScreen.routeName,
                                arguments: userData);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  AppLocalizations.of(context).uploadedAnimals,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                AccountSettingsScreen.routeName,
                                arguments: userData);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  AppLocalizations.of(context).yourAccount,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                        if (userData['role'] == "admin")
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(ReportsScreen.routeName);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    AppLocalizations.of(context).settingReport,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              AppLocalizations.of(context).notificationSetting,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: Text(
                            '${AppLocalizations.of(context).notificationContent}: ${distance!.toInt().toString()} km',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            Expanded(
                              child: Slider.adaptive(
                                activeColor: cSecondaryColor,
                                thumbColor: cSecondaryColor,
                                inactiveColor: Colors.white,
                                value: distance!,
                                onChanged: (newDistance) {
                                  setState(() {
                                    distance = newDistance;
                                  });
                                },
                                min: 0,
                                max: 200,
                                label: distance!.toInt().toString(),
                                divisions: 200,
                              ),
                            ),
                            Text(
                              '200',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
