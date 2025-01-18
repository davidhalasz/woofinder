import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:woof/providers/found_animals.dart';
import 'package:woof/screens/mainPage/components/featured_card.dart';
import '../../../models/animals.dart';
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
  Future<Animals?> _getFeatured() async {
    final Animals? featured =
        Provider.of<FoundAnimals>(context).findLastFeatured();
    return featured;
  }

  @override
  Widget build(BuildContext context) {
    final animalsData = Provider.of<FoundAnimals>(context);
    final animals = animalsData.items;
    Animals? featured = animalsData.findLastFeatured();

    return SafeArea(
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          FutureBuilder<Animals?>(
            future: _getFeatured(), // function where you call your api
            builder: (
              BuildContext context,
              AsyncSnapshot<Animals?> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  Animals featured = snapshot.data as Animals;
                  return FeaturedCard(featured: featured);
                } else {
                  return const Text('');
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            },
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                    top: 70,
                  ),
                  decoration: const BoxDecoration(
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
