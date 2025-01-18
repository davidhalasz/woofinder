import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:woof/screens/animalDetailPage/components/edit_comment.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../constants.dart';

class CommentList extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot<Object?>> commentSnapshot;
  final Function delete;
  final String animalId;

  final String currentUser;
  const CommentList(
    this.commentSnapshot,
    this.delete,
    this.animalId,
    this.currentUser, {
    Key? key,
  }) : super(key: key);

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  final List<TextEditingController> controllers = [];

  String postedAgo(DateTime postedDateTime) {
    var nowDateTime = DateTime.now();

    int days = nowDateTime.difference(postedDateTime).inDays;
    int hours = nowDateTime.difference(postedDateTime).inHours;
    int minutes = nowDateTime.difference(postedDateTime).inMinutes;
    int seconds = nowDateTime.difference(postedDateTime).inSeconds;

    if (minutes < 1) {
      return '$seconds ' + AppLocalizations.of(context).postedSec;
    } else if (hours < 1) {
      return '$minutes ' + AppLocalizations.of(context).postedMin;
    } else if (days < 1) {
      return '$hours ' + AppLocalizations.of(context).postedHrs;
    } else {
      return '$days ' + AppLocalizations.of(context).postedDays;
    }
  }

  Future<void> _saveEditedComment(
      String animalId, String commentId, String controllerText) async {
    Navigator.of(context).pop();
    try {
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(animalId)
          .collection('comment')
          .doc(commentId)
          .update({'comment': controllerText});
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occured!'),
          content: Text('Something went wrong!'),
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

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: widget.commentSnapshot.data!.docs.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: cGrayBGColor,
        );
      },
      itemBuilder: (context, index) {
        controllers.add(TextEditingController());
        var postedDateTime =
            widget.commentSnapshot.data!.docs[index]['createdAt'].toDate();

        String _postedAgo = postedAgo(postedDateTime);
        String initialComment =
            widget.commentSnapshot.data!.docs[index]['comment'];
        String postId = widget.commentSnapshot.data!.docs[index].id;

        controllers[index].text = initialComment;

        return ListTile(
          tileColor: cGrayBGColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.commentSnapshot.data!.docs[index]['username'],
                style: TextStyle(color: Colors.white),
              ),
              Text(
                _postedAgo,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          subtitle: Form(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      initialComment,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (widget.commentSnapshot.data!.docs[index]['userId'] ==
                    widget.currentUser)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          editCommentDialog(context, widget.animalId, postId,
                              controllers[index], _saveEditedComment);
                        },
                        child: Text(
                          AppLocalizations.of(context).editBtn,
                          style: TextStyle(color: cGrayBGColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.delete(
                            widget.animalId,
                            widget.commentSnapshot.data!.docs[index].id,
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context).deleteBtn,
                          style: TextStyle(color: cSecondaryColor),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
