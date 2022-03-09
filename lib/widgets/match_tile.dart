import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/core/match_making.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/pages/home/screens/inbox/chat_screen.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/utils/helper.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:uni_lights/widgets/profile_image.dart';

class MatchesTiles extends StatefulWidget {
  final String? studentPic, studentName, universityName, department, year;
  final String id;
  final String light;
  final bool isDate;
  final Function()? onTap;

  const MatchesTiles({
    Key? key,
    required this.id,
    required this.onTap,
    required this.isDate,
    required this.light,
    this.studentPic,
    this.studentName,
    this.universityName,
    this.department,
    this.year,
  }) : super(key: key);

  @override
  State<MatchesTiles> createState() => _MatchesTilesState();
}

class _MatchesTilesState extends State<MatchesTiles> {
  bool onLongPress = false;

  final CollectionReference<Map<String, dynamic>> _chatroom = FirebaseFirestore.instance.collection('chatroom');

  openChatRoom(String id) {}

  createChatRoom(Users user) async {
    String id = getId(user.uid!, widget.id);
    // check if chatrrom exists
    bool exists = await _chatroom.doc(id).get().then((doc) => doc.exists);
    if (exists) {
      // Open the chat screen and get messages stream.
      return;
    }

    // create on if it doesn't exists.
    Map<String, dynamic> data = {
      "users": [
        {
          "id": user.uid!,
          "name": user.name!,
          "photo_url": user.photoURL!,
          "light": user.light,
        },
        {
          "id": widget.id,
          "name": widget.studentName!,
          "photo_url": widget.studentPic!,
          "light": widget.light,
        }
      ],
      "last_message": {
        "message": "",
        "time": Timestamp.now(),
      }
    };

    _chatroom.doc(id).set(data).then((value) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            id: id,
            name: widget.studentName!,
            photo: widget.studentPic!,
          ),
        ),
      );
    });

    // return true
  }

  @override
  Widget build(BuildContext context) {
    var user = context.watch<Authentication>().user;
    return InkWell(
      onTap: () {
        var user = context.read<Authentication>().user!;
        if (onLongPress) {
          // Unmatch
          context.read<MatchMaker>().unmatch(user.uid!, widget.id, widget.isDate);
        } else {
          // create new chat/ got to chat
          createChatRoom(user);
        }
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onLongPress: () {
        if (onLongPress) {
          setState(() {
            onLongPress = false;
          });
        } else {
          setState(() {
            onLongPress = true;
          });
        }
      },
      child: Container(
        height: 112,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                ProfileImage(
                  image: widget.studentPic!,
                  status: user!.light!,
                  height: 90,
                  width: 90,
                ),
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            MyText(
                              paddingLeft: 10.0,
                              text: '${widget.studentName}',
                              size: 16,
                              weight: FontWeight.w700,
                              color: kBlackColor,
                              fontFamily: 'Roboto Mono',
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                    'assets/images/icons8_student.png',
                                    color: kBlackColor,
                                    height: 35,
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      MyText(
                                        text: '${widget.universityName}',
                                        size: 14,
                                        maxlines: 1,
                                        overFlow: TextOverflow.ellipsis,
                                        color: kGreyColor,
                                        fontFamily: 'Roboto',
                                      ),
                                      MyText(
                                        paddingTop: 3.0,
                                        text: '${widget.department} | ${widget.year} year',
                                        size: 12,
                                        maxlines: 1,
                                        overFlow: TextOverflow.ellipsis,
                                        color: kGreyColor,
                                        fontFamily: 'Roboto',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(),
                          ],
                        ),
                        onLongPress == true
                            ? Container(
                                padding: const EdgeInsets.only(right: 15),
                                width: kWidth(context),
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      kPrimaryColor.withOpacity(0.0),
                                      kRedColor.withOpacity(0.5),
                                      kRedColor,
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    MyText(
                                      onTap: () {
                                        setState(() {
                                          onLongPress = false;
                                        });
                                      },
                                      text: 'Unmatch',
                                      size: 14,
                                      weight: FontWeight.w700,
                                      color: kPrimaryColor,
                                      fontFamily: 'Roboto',
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
