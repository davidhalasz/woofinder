import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:woof/screens/animalDetailPage/animal_detail_screen.dart';

class UploadedAnimalCard extends StatelessWidget {
  const UploadedAnimalCard(this.id, this.description, this.userId, {Key? key})
      : super(key: key);
  final String id;
  final String description;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => AnimalDetailScreen(id, false)),
          );
        },
        child: Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.80,
                child: Text(
                  description,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
