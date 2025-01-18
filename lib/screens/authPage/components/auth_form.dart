import 'package:flutter/material.dart';
import 'package:woof/constants.dart';
import 'package:woof/screens/authPage/reset_password_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;

  final void Function(
    String email,
    String username,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';

  void trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(
        _userEmail.trim(),
        _userName.trim(),
        _userPassword.trim(),
        _isLogin,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                      return AppLocalizations.of(context).emailError;
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).emailAddress,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: cSecondaryColor),
                    ),
                    focusColor: cSecondaryColor,
                  ),
                  onSaved: (value) {
                    _userEmail = value!;
                  },
                ),
                if (!_isLogin)
                  TextFormField(
                    key: ValueKey('username'),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 4) {
                        return AppLocalizations.of(context).userNameError;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).userName,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: cSecondaryColor),
                      ),
                      focusColor: cSecondaryColor,
                    ),
                    onSaved: (value) {
                      _userName = value!;
                    },
                  ),
                TextFormField(
                  key: ValueKey('password'),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 8) {
                      return AppLocalizations.of(context).passwordError;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).password,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: cSecondaryColor),
                    ),
                    focusColor: cSecondaryColor,
                    fillColor: cSecondaryColor,
                  ),
                  obscureText: true,
                  onSaved: (value) {
                    _userPassword = value!;
                  },
                ),
                SizedBox(height: 12),
                if (widget.isLoading)
                  CircularProgressIndicator(
                    color: cSecondaryColor,
                  ),
                if (!widget.isLoading)
                  ElevatedButton(
                    onPressed: trySubmit,
                    child: Text(_isLogin
                        ? AppLocalizations.of(context).login
                        : AppLocalizations.of(context).signUp),
                    style: ElevatedButton.styleFrom(primary: cBlackBGColor),
                  ),
                if (!widget.isLoading)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? AppLocalizations.of(context).createNewAcc
                          : AppLocalizations.of(context).alreadyAnAcc,
                      style: TextStyle(color: cSecondaryColor),
                    ),
                  ),
                if (!widget.isLoading)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(ResetPasswordScreen.routeName);
                    },
                    child: Text(
                      AppLocalizations.of(context).forgotPassword,
                      style: TextStyle(color: cSecondaryColor),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
