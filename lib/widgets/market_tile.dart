import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/core/data_manager.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/pages/home/screens/inbox/chat_screen.dart';
import 'package:uni_lights/pages/home/screens/profile/profile_screen.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/utils/helper.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:uni_lights/widgets/profile_image.dart';

class DiscountsTiles extends StatefulWidget {
  final String? pic, name, time, description;
  final String? uid;
  final DocumentReference<Map<String, dynamic>>? owner;
  final List? postImages, tags;
  final double? price;
  final String? status;

  const DiscountsTiles({
    Key? key,
    this.uid,
    this.owner,
    this.status,
    this.pic,
    this.name,
    this.time,
    this.description,
    this.postImages,
    this.price,
    this.tags,
  }) : super(key: key);

  @override
  State<DiscountsTiles> createState() => _DiscountsTilesState();
}

class _DiscountsTilesState extends State<DiscountsTiles> {
  DocumentSnapshot<Map<String, dynamic>>? owner;
  final CollectionReference<Map<String, dynamic>> _chatroom = FirebaseFirestore.instance.collection('chatroom');
  @override
  void initState() {
    super.initState();
    getOwner();
  }

  getOwner() async {
    var temp = await widget.owner!.get();
    setState(() {
      owner = temp;
    });
  }

  createChatRoom(Users user) async {
    String id = getId(user.uid!, owner!.id);
    // check if chatrrom exists
    bool exists = await _chatroom.doc(id).get().then((doc) => doc.exists);
    if (exists) {
      // Open the chat screen and get messages stream.
      return;
    }

    var ownerData = owner!.data()!;

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
          "id": owner!.id,
          "name": ownerData["name"],
          "photo_url": ownerData["photo_url"],
          "light": ownerData["light"],
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
            name: ownerData["name"],
            photo: ownerData["photo_url"],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = context.read<Authentication>().user!;
    Widget? photos;

    if (widget.postImages?.length == 1) {
      photos = Container(
        margin: const EdgeInsets.only(
          top: 15,
          bottom: 10.0,
          right: 10.0,
        ),
        height: 120,
        width: kWidth(context),
        child: Padding(
          padding: const EdgeInsets.only(
            right: 5,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ImagePreview(
              imageLink: widget.postImages!.first,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: CachedNetworkImage(
                      imageUrl: widget.postImages!.first,
                      height: kHeight(context) * .4,
                      width: kWidth(context),
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
              width: kWidth(context),
              height: kHeight(context),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (widget.postImages?.length == 2) {
      photos = Container(
        margin: const EdgeInsets.only(
          top: 15,
          bottom: 10.0,
          right: 10.0,
        ),
        height: 120,
        width: kWidth(context),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 5,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ImagePreview(
                    imageLink: widget.postImages!.first,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: CachedNetworkImage(
                            imageUrl: widget.postImages!.first,
                            height: kHeight(context) * .4,
                            width: kWidth(context),
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                    width: kWidth(context) * .4,
                    height: kHeight(context),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 5,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ImagePreview(
                    imageLink: widget.postImages!.last,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: CachedNetworkImage(
                            imageUrl: widget.postImages!.last,
                            height: kHeight(context) * .4,
                            width: kWidth(context),
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                    width: kWidth(context),
                    height: kHeight(context),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    List tags = widget.tags!
        .map(
          (e) => MyText(
            text: "#$e",
            size: 9,
            weight: FontWeight.w300,
            color: kRedColor,
          ),
        )
        .toList();
    // widget.owner?.get().then((value) => owne)

    return Container(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileImage(
                image: owner?["photo_url"] ?? '',
                status: owner?["light"],
                height: 55,
                width: 55,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyText(
                              paddingLeft: 15.0,
                              text: owner?["name"],
                              size: 16,
                              weight: FontWeight.w500,
                              color: kBlackColor,
                              fontFamily: 'Roboto Mono',
                            ),
                            MyText(
                              text: '${widget.time}',
                              size: 10,
                              color: kGreyColor,
                              fontFamily: 'Roboto',
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Visibility(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: kGreyColor3,
                                      size: 30,
                                    ),
                                    tooltip: "More",
                                    onSelected: (value) {
                                      var ref = FirebaseFirestore.instance.collection('products').doc(widget.uid);

                                      context.read<DataManager>().flagPosting(ref, user).then(
                                            (value) => ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Post has been reported"),
                                              ),
                                            ),
                                          );
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem<String>(
                                        child: Text(
                                          'Report',
                                        ),
                                        value: "report",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: owner?.id != null && user.uid == owner!.id,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: kGreyColor3,
                                      size: 30,
                                    ),
                                    tooltip: "More",
                                    onSelected: (value) {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Center(
                                            child: Text("Warning!"),
                                          ),
                                          titleTextStyle: const TextStyle(color: Colors.red, fontSize: 28),
                                          content: const Text("Are you sure you want to delete this post permanently?"),
                                          actionsAlignment: MainAxisAlignment.center,
                                          actions: [
                                            OutlinedButton(
                                              onPressed: () {
                                                context.read<DataManager>().deleteProduct(widget.uid!);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Yes"),
                                            ),
                                            OutlinedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("No"),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem<String>(
                                        child: Text(
                                          'Delete',
                                        ),
                                        value: "delete",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: '${widget.description}',
                                    size: 10,
                                    maxlines: 3,
                                    align: TextAlign.center,
                                    overFlow: TextOverflow.ellipsis,
                                    color: kGreyColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        photos!,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ...tags,
                            Row(
                              children: [
                                MyText(
                                  text: '${widget.price} £',
                                  size: 12,
                                  paddingRight: 15.0,
                                  weight: FontWeight.w600,
                                  color: kRedColor,
                                ),
                                Visibility(
                                  visible: owner?.id != null && owner!.id != user.uid,
                                  child: GestureDetector(
                                    onTap: () {
                                      createChatRoom(user);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Image.asset(
                                      'assets/images/send.png',
                                      height: 35,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
