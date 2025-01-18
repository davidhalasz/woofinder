import 'package:flutter/material.dart';
import 'package:woof/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const routeName = '/reset_passord';

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _userEmail = '';

  void _submitAuthForm(
    String email,
    BuildContext ctx,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      );

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).resetEmailMsg,
            style: TextStyle(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: cSecondaryColor,
        ),
      );

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (err) {
      var message = AppLocalizations.of(context).errorOccured;

      if (err.message != null) {
        message = err.message!;
      }

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
    } catch (err) {
      print(err);
    }
  }

  void trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      _submitAuthForm(
        _userEmail.trim(),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBlackBGColor,
      body: Center(
        child: Card(
          color: cGrayBGColor,
          margin: EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    key: ValueKey('email'),
                    validator: (value) {
                      if (value!.isEmpty ||
                          !value.contains('@') ||
                          !value.contains('.')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: cSecondaryColor),
                      ),
                      focusColor: cSecondaryColor,
                    ),
                    onSaved: (value) {
                      _userEmail = value!;
                    },
                  ),
                  ElevatedButton(
                    onPressed: trySubmit,
                    child: Text('Send'),
                    style: ElevatedButton.styleFrom(primary: cBlackBGColor),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: cSecondaryColor),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
