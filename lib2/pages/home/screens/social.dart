// ignore_for_file: must_be_immutable
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/core/data_manager.dart';
import 'package:uni_lights/models/post.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:uni_lights/widgets/post_card.dart';
import 'package:uni_lights/widgets/profile_image.dart';
import 'package:url_launcher/url_launcher.dart';

class Social extends StatefulWidget {
  const Social({Key? key}) : super(key: key);

  @override
  State<Social> createState() => _SocialState();
}

class _SocialState extends State<Social> {
  List sorts = [
    'Date',
    'University',
  ];
  bool? expandCard = false;

  File? image;

  void getImage() async {
    final ImagePicker _picker = ImagePicker();
    var temp = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = File(temp!.path);
    });
  }

  @override
  void dispose() {
    image = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          expandCard == true
              ? const SizedBox()
              : ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  title: Card(
                    margin: EdgeInsets.zero,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      onTap: () {
                        setState(() {
                          expandCard = true;
                        });
                      },
                      cursorColor: kGreyColor,
                      style: const TextStyle(
                        color: kGreyColor,
                        fontSize: 12,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        hintText: 'What\'s on your mind?',
                        hintStyle: TextStyle(
                          color: kGreyColor,
                          fontSize: 12,
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  trailing: Wrap(
                    spacing: 10.0,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          var user = context.read<Authentication>().user!;
                          getImage();
                          if (image != null) {
                            Post post = Post(
                              caption: "",
                              university: user.university,
                              attachment: image != null ? image!.path : "",
                            );
                            context.read<DataManager>().addPost(user, post);
                          }
                        },
                        child: const CircleAvatar(
                          backgroundColor: kRedColor,
                          foregroundColor: Colors.white,
                          child: Icon(
                            Icons.camera_alt,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          expandCard == true ? cardExpand() : const SizedBox(),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            height: 146,
            child: GestureDetector(
              onTap: () {
                launch("https://www.fatsoma.com/uni-lights");
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/backroom.png",
                        width: kWidth(context),
                        height: kHeight(context),
                        fit: BoxFit.cover,
                      ),
                      const Center(
                        child: Text(
                          "Uni Lights Single Parties.",
                          style: TextStyle(
                            fontSize: 20,
                            color: kPrimaryColor,
                            fontFamily: 'Roboto Mono',
                            fontWeight: FontWeight.w500,
                            backgroundColor: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          MyText(
            text: 'Your Uni Community Page',
            size: 14,
            paddingLeft: 15.0,
            weight: FontWeight.w500,
            color: kDarkGreyColor,
            paddingTop: 30.0,
            paddingBottom: 15.0,
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 21,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  height: 21,
                  child: Center(
                    child: MyText(
                      text: 'Sorted by ',
                      size: 12,
                      color: kGreyColor,
                    ),
                  ),
                ),
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: sorts.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) => sortsWidget(
                    '${sorts[index]}',
                    index,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: context.read<DataManager>().posts(context.read<Authentication>().user!),
            builder: (_, snapshot) {
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
                  return const Text('Loading...');
                case ConnectionState.active:
                  if (snapshot.data!.size > 0) {
                    return Column(
                      children: snapshot.data!.docs
                          .map(
                            (e) => PostCard(
                              post: Post.fromMap(e.data(), e.id),
                            ),
                          )
                          .toList(),
                    );
                    // return ListView.builder(
                    //   itemCount: snapshot.data!.docs.length,
                    //   physics: const BouncingScrollPhysics(),
                    //   shrinkWrap: true,
                    //   itemBuilder: (_, index) {
                    //     return PostCard(
                    //       post: Post.fromMap(snapshot.data!.docs[index].data(), snapshot.data!.docs[index].id),
                    //     );
                    //   },
                    // );
                  } else {
                    return Container();
                  }

                default:
                  return Container();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget sortsWidget(String sort, int index) {
    int currentIndex = context.watch<DataManager>().currentIndex;
    return GestureDetector(
      onTap: () {
        if (currentIndex == 1 && currentIndex != index) {
          context.read<DataManager>().toggleOrder(0);
        } else {
          context.read<DataManager>().toggleOrder(1);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 21,
        decoration: BoxDecoration(
          color: currentIndex == index ? kGreenColor : kPrimaryColor,
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: MyText(
            text: sort,
            size: 12,
            color: currentIndex == index ? kPrimaryColor : kGreyColor,
          ),
        ),
      ),
    );
  }

  Widget cardExpand() {
    TextEditingController _caption = TextEditingController();
    var user = context.read<Authentication>().user!;
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.only(left: 30, right: 30, top: 50),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    cursorColor: kGreyColor,
                    controller: _caption,
                    maxLines: 10,
                    style: const TextStyle(
                      color: kGreyColor,
                      fontSize: 12,
                    ),
                    scrollPhysics: const BouncingScrollPhysics(),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 50,
                        right: 15,
                        top: 15,
                        bottom: 15,
                      ),
                      hintText: 'What\'s on your mind?',
                      hintStyle: TextStyle(
                        color: kGreyColor,
                        fontSize: 12,
                      ),
                      suffixText: '0/500',
                      suffixStyle: TextStyle(
                        color: kGreyColor,
                        fontSize: 12,
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Visibility(
                  visible: image != null,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(
                          image ?? File(""),
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              image = null;
                            });
                          },
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(180),
                              color: Colors.red,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: getImage,
                              child: Image.asset(
                                'assets/images/ic_round-photo-camera.png',
                                height: 25,
                              ),
                            ),
                            Image.asset(
                              'assets/images/bx_bx-link-alt.png',
                              height: 24,
                            ),
                            Image.asset(
                              'assets/images/location_grey.png',
                              height: 24,
                            ),
                            Image.asset(
                              'assets/images/micGrey.png',
                              height: 20,
                            ),
                            Image.asset(
                              'assets/images/ant-design_smile-outlined.png',
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: MaterialButton(
                                child: MyText(
                                  text: 'Make a post',
                                  size: 14,
                                  color: kPrimaryColor,
                                  weight: FontWeight.w500,
                                ),
                                shape: const StadiumBorder(),
                                elevation: 0,
                                highlightElevation: 0,
                                color: kRedColor,
                                onPressed: () {
                                  if (_caption.text.trim().isNotEmpty) {
                                    Post post = Post(
                                      caption: _caption.text.trim(),
                                      university: user.university,
                                      attachment: image != null ? image!.path : "",
                                    );
                                    context.read<DataManager>().addPost(user, post);
                                    _caption.clear();
                                    setState(() {
                                      expandCard = false;
                                    });
                                  }
                                },
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
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30, left: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileImage(
                image: user.photoURL!,
                status: user.light!,
                width: 55,
                height: 55,
              ),
              Expanded(
                child: Row(
                  children: [
                    MyText(
                      paddingLeft: 15.0,
                      text: user.name,
                      size: 16,
                      weight: FontWeight.w500,
                      color: kBlackColor,
                      fontFamily: 'Roboto Mono',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
