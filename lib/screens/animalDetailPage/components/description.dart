import 'package:flutter/material.dart';
import 'package:woof/models/animals.dart';

import '../../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Description extends StatefulWidget {
  final Animals animal;
  Description(this.animal, {Key? key}) : super(key: key);

  @override
  _DescriptionState createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Stack(
        children: <Widget>[
          Container(
            color: cGrayBGColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 10),
                      child: Text(
                        widget.animal.username,
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Spacer(),
                    if (widget.animal.solved)
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: greenColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            AppLocalizations.of(context).problemSolved,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 10, 10, 20),
                  child: Text(AppLocalizations.of(context).locationTxt +
                      ': ' +
                      widget.animal.address),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 10, 10, 40),
                  child: Text(
                    widget.animal.description,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 49,
              width: 49,
              color: cBlackBGColor,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: cGrayBGColor,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
