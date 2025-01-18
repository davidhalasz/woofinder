import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:woof/screens/settingsPage/screens/ReportsPage/components/report_tile.dart';

import '../../../../constants.dart';

class ReportsScreen extends StatefulWidget {
  ReportsScreen({Key? key}) : super(key: key);
  static const routeName = '/reports';

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
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
                'Reported Animals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: cSecondaryColor,
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: cGrayBGColor,
                      );
                    },
                    itemBuilder: (context, index) {
                      return ReportTile(snapshot.data!.docs[index]['date'],
                          snapshot.data!.docs[index]['animalId']);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
