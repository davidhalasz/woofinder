import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:woof/models/animals.dart';
import 'package:woof/providers/found_animals.dart';
import 'package:woof/screens/settingsPage/screens/uploadedAnimalPage/components/uploaded_animal_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../constants.dart';

class UploadedAnimalScreen extends StatelessWidget {
  const UploadedAnimalScreen({Key? key}) : super(key: key);
  static const routeName = '/uploaded_animals';

  @override
  Widget build(BuildContext context) {
    final animalsData = Provider.of<FoundAnimals>(context);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final animals = animalsData.items;
    final List<Animals> filteredAnimals = [];
    for (var i = 0; i < animals.length; i++) {
      if (animals[i].userId == userId) {
        filteredAnimals.add(animals[i]);
      }
    }
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
          AppLocalizations.of(context).back,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Container(
              height: 60,
              width: double.infinity,
              child: Text(
                AppLocalizations.of(context).uploadedAnimals,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: filteredAnimals.length,
              itemBuilder: (ctx, i) => UploadedAnimalCard(
                filteredAnimals[i].id,
                filteredAnimals[i].description,
                filteredAnimals[i].userId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
