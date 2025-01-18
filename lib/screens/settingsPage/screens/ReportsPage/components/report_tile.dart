import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:woof/screens/animalDetailPage/animal_detail_screen.dart';

import '../../../../../constants.dart';

class ReportTile extends StatelessWidget {
  final Timestamp createdAt;
  final String animalId;
  const ReportTile(this.createdAt, this.animalId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stampToDate = createdAt.toDate();
    final formattedDate = DateFormat.yMMMd().add_jm().format(stampToDate);
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32),
        bottomLeft: Radius.circular(32),
      ),
      child: Container(
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(formattedDate.toString()),
          tileColor: cGrayBGColor,
          subtitle: Text(animalId),
          isThreeLine: true,
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => AnimalDetailScreen(animalId, false)),
            );
          },
        ),
      ),
    );
  }
}
