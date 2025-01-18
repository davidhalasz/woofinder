import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:woof/providers/found_animals.dart';
import 'animal_card.dart';

class Body extends StatefulWidget {
  Body(
    this.currentLatitude,
    this.currentLongitude,
  );

  final double currentLatitude;
  final double currentLongitude;

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    final animalsData = Provider.of<FoundAnimals>(context);
    final animals = animalsData.items;

    return SafeArea(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    top: 70,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffE5E6EB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: animals.length,
                  itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                    value: animals[i],
                    child: AnimalCard(
                        widget.currentLatitude, widget.currentLongitude),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
