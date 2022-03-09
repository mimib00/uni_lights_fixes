import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/chat_tile.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:provider/provider.dart';

class Inbox extends StatefulWidget {
  const Inbox({Key? key}) : super(key: key);

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  Stream<QuerySnapshot<Map<String, dynamic>>> getChatRooms(Users user) {
    final CollectionReference<Map<String, dynamic>> _chatroom = FirebaseFirestore.instance.collection('chatroom');

    return _chatroom.where(
      "users",
      arrayContains: {
        "id": user.uid!,
        "name": user.name!,
        "photo_url": user.photoURL!,
        "light": user.light,
      },
    ).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    Users user = context.read<Authentication>().user!;
    return Padding(
      padding: const EdgeInsets.only(top: 110),
      child: Column(
        children: [
          MyText(
            align: TextAlign.center,
            text: 'INBOX'.toUpperCase(),
            size: 16,
            fontFamily: 'Roboto Mono',
            weight: FontWeight.w700,
            color: kBlackColor,
            paddingBottom: 20.0,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getChatRooms(user),
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
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 20, bottom: 100),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          var chat = data.docs[index];
                          List<dynamic> users = chat["users"];
                          users.removeWhere(
                            (element) => element['id'] == user.uid!,
                          );

                          var lastMessage = chat["last_message"];
                          Timestamp temp = lastMessage["time"];
                          DateTime time = temp.toDate();

                          return ChatTile(
                            chatId: chat.id,
                            userName: users.first["name"],
                            userPhoto: users.first["photo_url"],
                            status: users.first["light"],
                            time: "${time.hour}:${time.minute}",
                            lastMessage: lastMessage["message"],
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
        ],
      ),
    );
  }
}

/*ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return const ChatTile(
                  chatId: "1",
                  userName: "Mohamed Malkia",
                  userPhoto: "https://firebasestorage.googleapis.com/v0/b/uni-lights-e64c1.appspot.com/o/images%2FwW6JHEHP9CYAQsOfosGZuzVwNQe2%2Fprofile?alt=media&token=1a2d7d2f-1c9c-45b9-8bf2-1247d2fab5c5",
                  status: "Single",
                  time: "10:31",
                );
              },
            ),*/
