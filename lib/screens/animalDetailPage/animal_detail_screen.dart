import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:woof/constants.dart';
import 'package:woof/models/animals.dart';
import 'package:woof/providers/found_animals.dart';
import 'package:woof/screens/animalDetailPage/components/comment_input.dart';
import 'package:woof/screens/animalDetailPage/components/description.dart';
import 'package:woof/screens/animalDetailPage/components/image_viewer.dart';
import 'components/comment_list.dart';
import 'components/edit_description.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AnimalDetailScreen extends StatefulWidget {
  final String? animalId;
  final bool? isFromNotify;
  const AnimalDetailScreen(this.animalId, this.isFromNotify, {Key? key})
      : super(key: key);

  static const routeName = '/animal-detail';

  @override
  _AnimalDetailScreenState createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  final commentController = TextEditingController();
  final String currentUser = FirebaseAuth.instance.currentUser!.uid;
  final _descController = TextEditingController();
  var _isInit = true;
  bool _isLoading = false;
  bool solved = false;
  String role = '';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<FoundAnimals>(context).fetchAndSetAnimals().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _getUserData() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser)
        .snapshots()
        .listen((userData) {
      setState(() {
        role = userData.data()!['role'];
      });
    });
  }

  Future<void> saveForm(String animalId, String authorId) async {
    if (commentController.text.isEmpty) {
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      FirebaseFirestore.instance
          .collection('comments')
          .doc(animalId)
          .collection('comment')
          .add({
        'animalId': animalId,
        'userId': userData.id,
        'username': userData['username'],
        'comment': commentController.text,
        'createdAt': Timestamp.now(),
      });
      final comments = await FirebaseFirestore.instance
          .collection('comments')
          .doc(animalId)
          .collection('comment')
          .get();
      final commentDocs = comments.docs;
      var userIdList = [];
      for (var i = 0; i < commentDocs.length; i++) {
        var comment = commentDocs[i].data();
        userIdList.add(comment['userId']);
      }

      var distinctIds = userIdList.toSet().toList();
      for (var i = 0; i < distinctIds.length; i++) {
        if (user.uid == authorId && distinctIds[i] != authorId) {
          FirebaseFirestore.instance
              .collection('notifications')
              .doc(distinctIds[i])
              .collection('notification')
              .add({
            'animalId': animalId,
            'userName': userData['username'],
            'uid': user.uid,
            'action': 'commentedOnFollowedPost',
            'createdAt': Timestamp.now(),
          });
        }
        if (user.uid != authorId) {
          if (distinctIds[i] != user.uid && distinctIds[i] != authorId) {
            FirebaseFirestore.instance
                .collection('notifications')
                .doc(distinctIds[i])
                .collection('notification')
                .add({
              'animalId': animalId,
              'userName': userData['username'],
              'uid': user.uid,
              'action': 'commentedOnFollowedPost',
              'createdAt': Timestamp.now(),
            });
          }
          if (distinctIds[i] != user.uid && distinctIds[i] == authorId) {
            FirebaseFirestore.instance
                .collection('notifications')
                .doc(distinctIds[i])
                .collection('notification')
                .add({
              'animalId': animalId,
              'userName': userData['username'],
              'uid': user.uid,
              'action': 'commentedOnOwnPost',
              'createdAt': Timestamp.now(),
            });
          }
        }
      }

      commentController.clear();
    } catch (error) {
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
                child: Text('Okay'))
          ],
        ),
      );
    }
  }

  Future<void> _deleteAnimal(String animalId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: cSecondaryColor,
        content: Text(
          AppLocalizations.of(context).successDel,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ));
      setState(() {
        _isLoading = false;
      });
      await Provider.of<FoundAnimals>(context, listen: false)
          .deleteAnimal(animalId)
          .then((value) {});
    } catch (error) {
      print(error);
    }
  }

  Future<void> _delete(String animalId, String commentId) async {
    showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cGrayBGColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          AppLocalizations.of(context).deleteBtn,
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
        content: Text(AppLocalizations.of(context).deleteCommentTxt),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('comments')
                  .doc(animalId)
                  .collection('comment')
                  .doc(commentId)
                  .delete();
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context).deleteBtn.toUpperCase(),
              style: TextStyle(
                color: cSecondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context).cancel.toUpperCase(),
              style: TextStyle(
                color: cBlackBGColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendReport(String animalId) async {
    showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cGrayBGColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          AppLocalizations.of(context).reportTitle,
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
        content: Text(AppLocalizations.of(context).reportContent),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              FoundAnimals().sendReport(animalId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: cSecondaryColor,
                content: Text(
                  AppLocalizations.of(context).reportScaffold,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ));
            },
            child: Text(
              AppLocalizations.of(context).reportSendBtn,
              style: TextStyle(
                color: cSecondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context).cancel.toUpperCase(),
              style: TextStyle(
                color: cBlackBGColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getDescription(String animalId) async {
    try {
      final Animals? animal =
          Provider.of<FoundAnimals>(context, listen: false).findById(animalId);
      _descController.text = animal!.description;
    } catch (e) {
      print(e);
    }
  }

  Future<void> _saveEditedDescription(String animalId) async {
    Navigator.of(context).pop();
    try {
      await Provider.of<FoundAnimals>(context, listen: false)
          .updateAnimalDescription(
        animalId,
        _descController.text,
      );
    } catch (error) {
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
                child: Text('Ok'))
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Animals? animal =
        Provider.of<FoundAnimals>(context).findById(widget.animalId!);

    return Scaffold(
      backgroundColor: cBlackBGColor,
      appBar: AppBar(
        backgroundColor: cGrayBGColor,
        elevation: 0,
        leading: IconButton(
            padding: EdgeInsets.only(left: 20),
            icon: SvgPicture.asset(
              'assets/icons/left-arrow.svg',
              color: Colors.black,
              height: 28,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        centerTitle: false,
        title: Text(
          AppLocalizations.of(context).back,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: Colors.black,
              ),
              onPressed: () {
                actionPopUpMaterial(context, animal!);
              },
            ),
          ),
        ],
      ),
      body: _isLoading && animal == null
          ? Center(
              child: CircularProgressIndicator(
                color: cSecondaryColor,
                backgroundColor: cBlackBGColor,
              ),
            )
          : GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          ImageViewer(animal!),
                          Description(animal),
                          Stack(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: cBlackBGColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(50),
                                  ),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      color: cBlackBGColor,
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 20),
                                      child: Text(
                                        AppLocalizations.of(context).comments,
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('comments')
                                          .doc(animal.id)
                                          .collection('comment')
                                          .orderBy('createdAt',
                                              descending: false)
                                          .snapshots(),
                                      builder: (context, commentSnapshot) {
                                        if (commentSnapshot.hasError) {
                                          return Text(
                                            commentSnapshot.error.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          );
                                        }
                                        if (commentSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: cSecondaryColor,
                                            ),
                                          );
                                        }

                                        return CommentList(commentSnapshot,
                                            _delete, animal.id, currentUser);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  height: 49,
                                  width: 49,
                                  color: cGrayBGColor,
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: cBlackBGColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(50),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  CommentInput(
                      commentController, saveForm, animal.id, animal.userId),
                ],
              ),
            ),
    );
  }

  Future<dynamic> actionPopUpMaterial(BuildContext context, Animals author) {
    double height = 160;

    if (author.userId == currentUser || role == 'admin') {
      height = 340;
    }
    return showModalBottomSheet<dynamic>(
      backgroundColor: cBlackBGColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
          height: height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: <Widget>[
                if (author.userId == currentUser || role == 'admin')
                  Container(
                    height: 60,
                    color: cBlackBGColor,
                    child: CupertinoActionSheetAction(
                      child: Text(
                        AppLocalizations.of(context).deleteBtn,
                        style: TextStyle(
                          color: cSecondaryColor,
                        ),
                      ),
                      onPressed: () {
                        showDialog<Null>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            content: Text(AppLocalizations.of(context)
                                .deleteAnimalContent),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  _deleteAnimal(author.id);
                                },
                                child: Text(
                                  AppLocalizations.of(context).deleteBtn,
                                  style: TextStyle(
                                    color: cSecondaryColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  AppLocalizations.of(context).cancel,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                if (author.userId == currentUser || role == 'admin')
                  Container(
                    height: 60,
                    color: cBlackBGColor,
                    child: CupertinoActionSheetAction(
                      child: Text(
                        AppLocalizations.of(context).editDescBtn,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        _getDescription(author.id);
                        editDialog(context, author.id, _descController,
                            _saveEditedDescription);
                      },
                    ),
                  ),
                if (author.userId == currentUser || role == 'admin')
                  Container(
                    height: 60,
                    color: cBlackBGColor,
                    child: CupertinoActionSheetAction(
                      child: Text(
                        solved
                            ? AppLocalizations.of(context).problemUnsolved
                            : AppLocalizations.of(context).problemSolved,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          solved = !solved;
                        });
                        Provider.of<FoundAnimals>(context, listen: false)
                            .solvedAnimal(author);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                Container(
                  height: 60,
                  color: cBlackBGColor,
                  child: CupertinoActionSheetAction(
                    child: Text(
                      AppLocalizations.of(context).reportTitle,
                      style: TextStyle(
                        color: cSecondaryColor,
                      ),
                    ),
                    isDefaultAction: true,
                    onPressed: () {
                      _sendReport(author.id);
                    },
                  ),
                ),
                Divider(
                  color: cSecondaryColor,
                ),
                Container(
                  height: 60,
                  color: cBlackBGColor,
                  child: CupertinoActionSheetAction(
                    child: Text(
                      AppLocalizations.of(context).cancel,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    isDefaultAction: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
