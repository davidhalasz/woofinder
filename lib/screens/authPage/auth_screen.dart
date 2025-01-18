import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:woof/constants.dart';
import 'package:woof/screens/authPage/components/auth_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = "/auth";

  const AuthScreen({Key? key}) : super(key: key);
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    //_getCurrentLocation();
  }

  _userExists(String username) async {
    try {
      var isExists = false;
      await FirebaseFirestore.instance
          .collection("users")
          .get()
          .then((querySnapshot) {
        var snapshotArray = querySnapshot.docs;

        for (var i = 0; i < snapshotArray.length; i++) {
          var data = snapshotArray[i].data();
          if (data['username'].toString().toLowerCase() ==
              username.toLowerCase()) {
            isExists = true;
            break;
          }
        }
      });
      if (isExists) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
    }
  }

  void _submitAuthForm(
    String email,
    String username,
    String password,
    bool isLogin,
    bool acceptedAge,
    bool acceptedRules,
    BuildContext ctx,
  ) async {
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });

      if (isLogin) {
        try {
          authResult = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).errorOccured,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Theme.of(ctx).errorColor,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        if (acceptedAge && acceptedRules) {
          bool isExists = await _userExists(username);

          if (!isExists) {
            setState(() {
              _isLoading = false;
            });
            try {
              authResult = await _auth.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(authResult.user!.uid)
                  .set({
                'username': username,
                'email': email,
                'role': 'user',
              });
            } catch (e) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: const Text(
                    "Error",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Theme.of(ctx).errorColor,
                ),
              );
              setState(() {
                _isLoading = false;
              });
            }
          } else {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).usernameExists,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Theme.of(ctx).errorColor,
              ),
            );
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).needAccept,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Theme.of(ctx).errorColor,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    } on FirebaseAuthException catch (err) {
      var message = AppLocalizations.of(context).errorOccured;

      if (err.message != null) {
        message = err.message!;
      }

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBlackBGColor,
      body: AuthForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}
