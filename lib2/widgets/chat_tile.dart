import 'package:flutter/material.dart';
import 'package:uni_lights/pages/home/screens/inbox/chat_screen.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/profile_image.dart';

import 'my_text.dart';

class ChatTile extends StatelessWidget {
  final String chatId;
  final String userName, userPhoto;
  final String lastMessage;
  final String? time;
  final String status;
  const ChatTile({
    Key? key,
    required this.userName,
    required this.userPhoto,
    required this.chatId,
    required this.status,
    required this.lastMessage,
    this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // chat screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              id: chatId,
              name: userName,
              photo: userPhoto,
            ),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileImage(
                  image: userPhoto,
                  status: status,
                  width: 55,
                  height: 55,
                ),
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyText(
                                  paddingLeft: 20.0,
                                  text: userName,
                                  size: 16,
                                  weight: FontWeight.w500,
                                  color: kBlackColor,
                                  fontFamily: 'Roboto Mono',
                                ),
                                MyText(
                                  paddingLeft: 10.0,
                                  text: time,
                                  size: 13,
                                  color: kGreyColor3,
                                  fontFamily: 'Roboto',
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      MyText(
                                        text: lastMessage.isEmpty ? "No messages start the conversation" : lastMessage,
                                        size: 13,
                                        maxlines: 2,
                                        paddingTop: 5.0,
                                        paddingLeft: 10.0,
                                        paddingRight: 15.0,
                                        align: TextAlign.justify,
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
                        )
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
