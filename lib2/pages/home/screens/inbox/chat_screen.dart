import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/pages/home/screens/profile/profile_screen.dart';

import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:uni_lights/widgets/profile_image.dart';

class ChatScreen extends StatefulWidget {
  final String name, photo, id;
  const ChatScreen({
    Key? key,
    required this.id,
    required this.name,
    required this.photo,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>> getChatMessages() => FirebaseFirestore.instance.collection('chatroom').doc(widget.id).collection("chats").orderBy("time").snapshots();

  sendMessage(Users? user, {String attachment = ''}) {
    var ref = FirebaseFirestore.instance.collection('chatroom');

    Map<String, dynamic> message = attachment.isEmpty
        ? {
            "msg": msg.text.trim(),
            "time": Timestamp.now(),
            "sender": user?.uid!,
            "attachment": attachment
          }
        : {
            "msg": "",
            "time": Timestamp.now(),
            "sender": user?.uid!,
            "attachment": attachment
          };

    ref.doc(widget.id).collection("chats").add(message);
    ref.doc(widget.id).update({
      "last_message": attachment.isEmpty
          ? {
              "message": msg.text.trim(),
              "time": Timestamp.now(),
            }
          : {
              "message": "Attachment was sent",
              "time": Timestamp.now(),
            }
    });
    msg.clear();
    FocusScope.of(context).unfocus();
  }

  TextEditingController msg = TextEditingController();
  final Reference _storage = FirebaseStorage.instance.ref();
  @override
  Widget build(BuildContext context) {
    var user = context.watch<Authentication>().user;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Image.asset(
            'assets/images/arrow.png',
            height: 20,
          ),
        ),
        title: MyText(
          text: widget.name,
          size: 20,
          fontFamily: 'Roboto Mono',
          weight: FontWeight.w700,
          color: kBlackColor,
        ),
        actions: [
          ProfileImage(
            image: widget.photo,
            status: user!.light!,
            width: 55,
            height: 55,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getChatMessages(),
              builder: (context, snapshot) {
                var data = snapshot.data;
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(
                          'assets/images/clarity_sad-face-line.png',
                          height: 35,
                        ),
                        Center(
                          child: MyText(
                            paddingTop: 15.0,
                            text: 'There are no post to see',
                            size: 12,
                            color: kGreyColor3,
                          ),
                        ),
                      ],
                    );
                  case ConnectionState.waiting:
                    return const Center(child: Text('Loading...'));
                  case ConnectionState.active:
                    if (data!.docs.isNotEmpty) {
                      return ListView.builder(
                        itemCount: data.docs.length,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemBuilder: (context, index) {
                          var msg = data.docs[index];
                          Timestamp temp = msg["time"];
                          DateTime time = temp.toDate();

                          return ChatBubble(
                            msg: msg["msg"],
                            time: "${time.hour}:${time.minute}",
                            isSent: msg["sender"] == user.uid!,
                            photo: widget.photo,
                            attachment: msg["attachment"],
                          );
                        },
                      );
                    } else {
                      return Container();
                    }
                  default:
                    return Container();
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  height: 60,
                  width: kWidth(context),
                  color: kPrimaryColor,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final ImagePicker _picker = ImagePicker();
                              var img = await _picker.pickImage(source: ImageSource.gallery);

                              if (img == null) return;
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: Row(
                                    children: const [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 8),
                                      Text("Uploading..."),
                                    ],
                                  ),
                                ),
                              );
                              var path = "messages/${user.uid!}/${DateTime.now().microsecondsSinceEpoch}";
                              TaskSnapshot uploadTask = await _storage.child(path).putFile(File(img.path));

                              if (uploadTask.state == TaskState.success) {
                                var imageUrl = await uploadTask.ref.getDownloadURL();
                                sendMessage(user, attachment: imageUrl);
                              }
                              Navigator.pop(context);
                            },
                            child: Image.asset(
                              'assets/images/el_picture.png',
                              height: 23,
                            ),
                          ),
                          const SizedBox(width: 25),
                          GestureDetector(
                            onTap: () async {
                              final ImagePicker _picker = ImagePicker();
                              var img = await _picker.pickImage(source: ImageSource.camera);
                              if (img == null) return;
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: Row(
                                    children: const [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 8),
                                      Text("Uploading..."),
                                    ],
                                  ),
                                ),
                              );
                              var path = "messages/${user.uid!}/${DateTime.now().microsecondsSinceEpoch}";
                              TaskSnapshot snapshot = await _storage.child(path).putFile(File(img.path));
                              if (snapshot.state == TaskState.success) {
                                var imageUrl = await snapshot.ref.getDownloadURL();
                                sendMessage(user, attachment: imageUrl);
                              }
                              Navigator.pop(context);
                            },
                            child: Image.asset(
                              'assets/images/fluent_camera-24-regular.png',
                              height: 27,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: TextFormField(
                                  controller: msg,
                                  textAlignVertical: TextAlignVertical.center,
                                  cursorColor: kDarkGreyColor.withOpacity(0.4),
                                  textCapitalization: TextCapitalization.sentences,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    fillColor: kPrimaryColor,
                                    filled: true,
                                    hintText: 'Type a message...',
                                    hintStyle: TextStyle(
                                      color: kGreyColor.withOpacity(0.72),
                                      fontSize: 13,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: BorderSide(
                                        color: kBorderColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      borderSide: BorderSide(
                                        color: kBorderColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => sendMessage(user),
                              child: const Icon(
                                Icons.send,
                                color: kGreyColor,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget timeBubble(String time) {
    return Column(
      children: [
        Container(
          height: 24,
          width: 90,
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: kPrimaryColor,
            boxShadow: const [
              BoxShadow(
                color: kRedColor,
                blurRadius: 10,
                spreadRadius: 0.0,
                offset: Offset(0.0, 8.0),
              ),
            ],
          ),
          child: Center(
            child: MyText(
              text: time,
              size: 12,
              maxlines: 1,
              overFlow: TextOverflow.ellipsis,
              color: kDarkGreyColor,
            ),
          ),
        ),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String msg, time;
  final String? photo;
  final String attachment;
  final bool isSent;
  const ChatBubble({
    Key? key,
    required this.msg,
    required this.time,
    required this.isSent,
    this.photo,
    required this.attachment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget bubbleWithImage = isSent
        ? Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: kWidth(context) * 0.8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        paddingLeft: 10.0,
                        paddingBottom: 5.0,
                        text: time,
                        size: 12,
                        fontFamily: 'Roboto',
                        color: kBlackColor,
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: ImagePreview(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: CachedNetworkImage(
                                  imageUrl: attachment,
                                  height: kHeight(context) * .4,
                                  width: kWidth(context),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                          imageLink: attachment,
                          width: kWidth(context),
                          height: kHeight(context) * .3,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 20, left: 15),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MyText(
                      text: time,
                      size: 12,
                      fontFamily: 'Roboto',
                      color: kGreyColor2,
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xffEF8484),
                            Color(0xffFFB57F),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: attachment,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: -25,
                  top: -10,
                  child: Container(
                    width: 53,
                    height: 53,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: const [
                        BoxShadow(
                          color: kGreenColor,
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: Offset(0.0, 2),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.transparent,
                        cardColor: Colors.transparent,
                      ),
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.all(6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: photo!,
                              placeholder: (context, url) => const Icon(Icons.person, color: Colors.white),
                              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                              width: kWidth(context),
                              height: kHeight(context),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

    Widget bubbleWithoutImage = isSent
        ? Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: kWidth(context) * 0.8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        paddingLeft: 10.0,
                        paddingBottom: 5.0,
                        text: time,
                        size: 12,
                        fontFamily: 'Roboto',
                        color: kBlackColor,
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: MyText(
                          text: msg,
                          size: 12,
                          fontFamily: 'Roboto',
                          color: kBlackColor,
                          align: TextAlign.justify,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 20, left: 15),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MyText(
                      text: time,
                      size: 12,
                      fontFamily: 'Roboto',
                      color: kGreyColor2,
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xffEF8484),
                            Color(0xffFFB57F),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: MyText(
                        paddingLeft: 15.0,
                        paddingRight: 10.0,
                        color: kPrimaryColor,
                        align: TextAlign.justify,
                        text: msg,
                        size: 12,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: -25,
                  top: -10,
                  child: Container(
                    width: 53,
                    height: 53,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: const [
                        BoxShadow(
                          color: kGreenColor,
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: Offset(0.0, 2),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.transparent,
                        cardColor: Colors.transparent,
                      ),
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.all(6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: photo!,
                              placeholder: (context, url) => const Icon(Icons.person, color: Colors.white),
                              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                              width: kWidth(context),
                              height: kHeight(context),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
    return msg.isEmpty ? bubbleWithImage : bubbleWithoutImage;
  }
}
