import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../constants.dart';

class Account extends StatefulWidget {
  const Account(this.userData, {Key? key}) : super(key: key);

  final dynamic userData;
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final user = FirebaseAuth.instance.currentUser!;
  void _deleteAccount() async {
    try {
      showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cGrayBGColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            AppLocalizations.of(context).deleteAccount,
            style: TextStyle(
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
            ),
          ),
          content: Text(AppLocalizations.of(context).sureDeleteAcc),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                user.delete();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context).deleteBtn.toUpperCase(),
                style: TextStyle(
                  color: cSecondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context).cancel.toUpperCase(),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Container(
            height: 60,
            width: double.infinity,
            child: Text(
              AppLocalizations.of(context).yourAccount,
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
                Container(
                  width: double.infinity,
                  child: Text(
                    AppLocalizations.of(context).userName +
                        ': ' +
                        widget.userData['username'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    AppLocalizations.of(context).emailAddress +
                        ': ' +
                        widget.userData['email'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context).logout,
                        style: TextStyle(
                          color: cSecondaryColor,
                          fontSize: 18,
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
                  height: 15,
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  _deleteAccount();
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: cSecondaryColor,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).deleteAccount,
                    style: TextStyle(
                      color: cSecondaryColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
