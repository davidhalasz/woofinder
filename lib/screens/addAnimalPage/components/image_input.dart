import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../constants.dart';

class ImageInput extends StatefulWidget {
  final Function onSelectImages;

  ImageInput(this.onSelectImages);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  List<XFile>? _imageFileList;
  dynamic pickImageError;

  set imageFile(XFile? value) {
    _imageFileList = value == null ? null : [value];
  }

  Future<void> _onImageButtonPressed() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final List<XFile>? pickedFileList = await _picker.pickMultiImage();
      setState(() {
        _imageFileList = pickedFileList;
      });
    } catch (e) {
      setState(() {
        pickImageError = e;
        print(pickImageError);
      });
    }
    widget.onSelectImages(_imageFileList);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
      child: Container(
        width: double.infinity,
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
        child: Column(
          children: [
            if (_imageFileList != null)
              _PreviewImages(imageFileList: _imageFileList),
            if (_imageFileList == null)
              Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  AppLocalizations.of(context).noImageSelected,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    shadows: [
                      Shadow(
                          offset: Offset(3, 3),
                          color: Colors.black38,
                          blurRadius: 18),
                      Shadow(
                          offset: Offset(-3, -3),
                          color: Colors.white.withOpacity(0.85),
                          blurRadius: 18)
                    ],
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: _onImageButtonPressed,
              icon: Icon(Icons.image),
              label: Text(AppLocalizations.of(context).choosePic),
              style: TextButton.styleFrom(
                primary: cSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewImages extends StatelessWidget {
  const _PreviewImages({
    Key? key,
    required List<XFile>? imageFileList,
  })  : _imageFileList = imageFileList,
        super(key: key);

  final List<XFile>? _imageFileList;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Semantics(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            key: UniqueKey(),
            itemBuilder: (context, index) {
              return Container(
                child: Semantics(
                  child: Image.file(
                    File(_imageFileList![index].path),
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                  ),
                ),
              );
            },
            itemCount: _imageFileList!.length,
          ),
          label: 'image_picker_example_picked_images'),
    );
  }
}
