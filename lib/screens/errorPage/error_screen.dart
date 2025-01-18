import 'package:flutter/material.dart';

import '../../constants.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({Key? key}) : super(key: key);
  static const routeName = '/error-page';

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: cBlackBGColor,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Text(
                  'This page no longer avaliable!',
                  style: TextStyle(
                    color: cSecondaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'BACK',
                  style: TextStyle(color: cSecondaryColor),
                ),
                style: TextButton.styleFrom(
                  side: BorderSide(color: cSecondaryColor, width: 3),
                  backgroundColor: cBlackBGColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
