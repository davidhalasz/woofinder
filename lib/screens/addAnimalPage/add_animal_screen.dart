import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:woof/constants.dart';
import 'package:woof/helpers/location_helper.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:woof/providers/found_animals.dart';
import 'components/description_input.dart';
import 'components/location_input.dart';
import 'components/image_input.dart';
import '../../models/place.dart';

class AddAnimalScreen extends StatefulWidget {
  final LatLng? currentLoc;
  AddAnimalScreen({this.currentLoc, Key? key}) : super(key: key);
  static const routeName = '/add-animal';

  @override
  _AddAnimalScreenState createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _descFocusNode = FocusNode();
  final _descController = TextEditingController();
  final _form = GlobalKey<FormState>();
  Place? _pickedLocation;
  bool _isFeatured = false;
  final user = FirebaseAuth.instance.currentUser!;
  String role = "";

  List<XFile>? _imageFileList;
  dynamic pickImageError;
  dynamic pickLocationError;

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  void dispose() {
    _descFocusNode.dispose();
    super.dispose();
  }

  void _selectImages(List<XFile>? value) {
    _imageFileList = value;
  }

  void _selectPlace(double lat, double lng) {
    _pickedLocation = Place(latitude: lat, longitude: lng);
  }

  void _getUserData() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((userData) {
      setState(() {
        role = userData.data()!['role'];
      });
    });
  }

  Future<void> _saveForm() async {
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[900],
          content: Text(
            AppLocalizations.of(context).theFieldCannotBeEmpty,
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[900],
          content: Text(
            AppLocalizations.of(context).noLocError,
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<String> dowUrls = [];
      var imageList;
      imageList = _imageFileList;
      if (imageList != null) {
        for (int i = 0; i < _imageFileList!.length; i++) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('animal_images')
              .child(const Uuid().v4() + '.jpeg');
          await ref.putFile(File(_imageFileList![i].path));
          dowUrls.add(await ref.getDownloadURL());
        }
      }

      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final address = await LocationHelper.getCountryStreet(
        _pickedLocation!.latitude,
        _pickedLocation!.longitude,
      );
      final updatedLocation = Place(
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
        address: address,
      );

      await FirebaseFirestore.instance.collection('animal').add({
        'description': _descController.text,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData['username'],
        'imageUrls': dowUrls.toList(),
        'latitude': updatedLocation.latitude,
        'longitude': updatedLocation.longitude,
        'address': updatedLocation.address,
        'solved': false,
        'featured': _isFeatured,
      }).then((value) {
        Provider.of<FoundAnimals>(context, listen: false).addAnimal(value.id);
      });
    } catch (error) {
      print(error);
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context).errorOccuredTtitle),
          content: Text(AppLocalizations.of(context).errorOccuredContent),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'))
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: cBlackBGColor,
        appBar: AppBar(
          backgroundColor: cBlackBGColor,
          elevation: 0,
          leading: IconButton(
              padding: const EdgeInsets.only(left: 20),
              icon: SvgPicture.asset(
                'assets/icons/left-arrow.svg',
                color: Colors.white,
                height: 28,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: false,
          title: Text(
            AppLocalizations.of(context).addNewPostTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: cSecondaryColor),
              )
            : SafeArea(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Text(
                        AppLocalizations.of(context).addNewPostSubtitle,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(
                              top: 40,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xffE5E6EB),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50),
                                topRight: Radius.circular(50),
                              ),
                            ),
                            child: Container(
                              height: double.infinity,
                              padding: const EdgeInsets.only(top: 20),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 5,
                              ),
                              child: Form(
                                key: _form,
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Column(
                                      children: <Widget>[
                                        DescriptionInput(
                                          descController: _descController,
                                          descFocusNode: _descFocusNode,
                                        ),
                                        ImageInput(_selectImages),
                                        LocationInput(_selectPlace),
                                        if (role == "admin")
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 20),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  color: cBlackBGColor),
                                              child: CheckboxListTile(
                                                activeColor: cSecondaryColor,
                                                value: _isFeatured,
                                                onChanged: (bool? value) {
                                                  setState(
                                                    () {
                                                      _isFeatured = value!;
                                                    },
                                                  );
                                                },
                                                title: const Text(
                                                  "Featured Post",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 25),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                                backgroundColor:
                                                    cSecondaryColor,
                                                primary: Colors.white,
                                                padding:
                                                    const EdgeInsets.all(15)),
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .send
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: _saveForm,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
