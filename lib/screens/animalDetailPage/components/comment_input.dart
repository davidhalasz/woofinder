import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommentInput extends StatefulWidget {
  final TextEditingController commentController;
  final Function saveForm;
  final String animalId;
  final String authorId;
  CommentInput(
      this.commentController, this.saveForm, this.animalId, this.authorId,
      {Key? key})
      : super(key: key);

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: cBlackBGColor,
      padding: EdgeInsets.all(1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: TextFormField(
                controller: widget.commentController,
                style: TextStyle(color: Colors.white),
                cursorColor: cSecondaryColor,
                autocorrect: false,
                decoration: InputDecoration(
                  labelStyle: TextStyle(fontSize: 20.0, color: Colors.white),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: AppLocalizations.of(context).writeComment,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: cSecondaryColor,
            ),
            iconSize: 20.0,
            onPressed: () => {
              FocusManager.instance.primaryFocus?.unfocus(),
              widget.saveForm(
                widget.animalId,
                widget.authorId,
              ),
            },
          ),
        ],
      ),
    );
  }
}
