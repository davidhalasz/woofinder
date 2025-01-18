import 'package:flutter/material.dart';

import '../../constants.dart';

class ImageViewScreen extends StatelessWidget {
  static const routeName = '/image-view';

  @override
  Widget build(BuildContext context) {
    final loadedImage = ModalRoute.of(context)?.settings.arguments as String;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Center(
        child: Hero(
          tag: '$loadedImage',
          child: Container(
            color: cGrayBGColor,
            height: double.infinity,
            width: double.infinity,
            child: Image.network(
              loadedImage.toString(),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }
}
