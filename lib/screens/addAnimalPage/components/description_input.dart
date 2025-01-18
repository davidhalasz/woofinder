import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants.dart';

class DescriptionInput extends StatelessWidget {
  const DescriptionInput({
    Key? key,
    required TextEditingController descController,
    required FocusNode descFocusNode,
  })  : _descController = descController,
        super(key: key);

  final TextEditingController _descController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
      child: Column(
        children: <Widget>[
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color(0xffE5E6EB),
              boxShadow: [
                BoxShadow(
                    offset: Offset(8, 8),
                    color: Colors.black38,
                    blurRadius: 15),
                BoxShadow(
                    offset: Offset(-8, -8),
                    color: Colors.white.withOpacity(0.75),
                    blurRadius: 15),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: TextFormField(
                textInputAction: TextInputAction.done,
                cursorColor: cSecondaryColor,
                controller: _descController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).descHintText,
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
        ],
      ),
    );
  }
}
