import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:woof/screens/settingsPage/screens/AccountPage/components/account.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../constants.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);
  static const routeName = '/account_settings';

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final userData = ModalRoute.of(context)?.settings.arguments as dynamic;

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
              Navigator.pop(context);
            }),
        centerTitle: false,
        title: Text(
          AppLocalizations.of(context).back.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      body: Account(userData),
    );
  }
}
