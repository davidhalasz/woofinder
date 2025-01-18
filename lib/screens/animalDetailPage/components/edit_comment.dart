import 'package:flutter/material.dart';

import '../../../constants.dart';

Future<dynamic> editCommentDialog(
  BuildContext context,
  String animalId,
  String postId,
  TextEditingController controller,
  Future<void> Function(
          String animalId, String commentId, String controllerText)
      saveEditedComment,
) {
  return showDialog(
    context: context,
    builder: (context) {
      var width = MediaQuery.of(context).size.width;
      return AlertDialog(
        backgroundColor: cGrayBGColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          'Edit Comment',
          style: TextStyle(
            shadows: [
              Shadow(
                  offset: Offset(3, 3), color: Colors.black38, blurRadius: 18),
              Shadow(
                  offset: Offset(-3, -3),
                  color: Colors.white.withOpacity(0.85),
                  blurRadius: 18)
            ],
          ),
        ),
        content: Container(
          width: width - 40,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Color(0xffE5E6EB),
            boxShadow: [
              BoxShadow(
                  offset: Offset(8, 8), color: Colors.black38, blurRadius: 15),
              BoxShadow(
                  offset: Offset(-8, -8),
                  color: Colors.white.withOpacity(0.75),
                  blurRadius: 15),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              cursorColor: cSecondaryColor,
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Description about animal...',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 0,
                  ),
                ),
                border: InputBorder.none,
              ),
              maxLines: 5,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'CANCEL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(
              'SAVE',
              style: TextStyle(
                color: cSecondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              saveEditedComment(animalId, postId, controller.text);
            },
          ),
        ],
      );
    },
  );
}
