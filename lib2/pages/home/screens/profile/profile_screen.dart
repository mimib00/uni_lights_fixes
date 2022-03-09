// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/pages/home/screens/profile/upgrade.dart';
import 'package:uni_lights/pages/settings.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:uni_lights/widgets/profile_image.dart';
import 'package:uni_lights/widgets/uni_bottom_sheet.dart';

import '../../root.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Users? user = context.watch<Authentication>().user;
    if (user == null) return Container();

    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        physics: const BouncingScrollPhysics(),
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ProfileImage(
                image: user.photoURL!,
                status: user.light!,
                width: 225,
                height: 225,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => UniBottomSheet(
                      title: "Choose",
                      height: kHeight(context) * .2,
                      content: Column(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: CachedNetworkImage(
                                    imageUrl: user.photoURL!,
                                    height: kHeight(context) * .4,
                                    width: kWidth(context),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                            child: const Text("View Profile Picture"),
                          ),
                          TextButton(
                            onPressed: () async {
                              File? image;
                              final Reference _storage = FirebaseStorage.instance.ref();
                              final _userRef = FirebaseFirestore.instance.collection("users");
                              final _chatroom = FirebaseFirestore.instance.collection('chatroom');
                              final ImagePicker _picker = ImagePicker();
                              var temp = await _picker.pickImage(source: ImageSource.gallery);

                              image = File(temp!.path);

                              // upload the image
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
                              var path = "images/${user.uid!}/profile";
                              TaskSnapshot snapshot = await _storage.child(path).putFile(image);
                              if (snapshot.state == TaskState.success) {
                                var imageUrl = await snapshot.ref.getDownloadURL();
                                Map<String, dynamic> data = {
                                  "photo_url": imageUrl
                                };

                                _userRef.doc(user.uid!).update(data);
                                _chatroom
                                    .where(
                                      "users",
                                      arrayContains: {
                                        "id": user.uid!,
                                        "name": user.name!,
                                        "photo_url": user.photoURL!,
                                        "light": user.light,
                                      },
                                    )
                                    .get()
                                    .then((value) {
                                      for (var doc in value.docs) {
                                        List users = doc.data()["users"];
                                        users.removeWhere((element) => element['id'] == user.uid!);
                                        users.add(
                                          {
                                            "id": user.uid!,
                                            "name": user.name!,
                                            "photo_url": imageUrl,
                                            "light": user.light,
                                          },
                                        );

                                        _chatroom.doc(doc.id).update(
                                          {
                                            "users": users
                                          },
                                        );
                                      }
                                    });
                                context.read<Authentication>().getUserData().then((value) => Navigator.pop(context));
                              }
                            },
                            child: const Text("Change Profile Picture"),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 35,
                child: Image.asset(
                  'assets/images/camera icon.png',
                  height: 30,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MyText(
                paddingTop: 20.0,
                paddingBottom: 10.0,
                align: TextAlign.center,
                text: user.name!.toUpperCase(),
                size: 16,
                color: kBlackColor,
                weight: FontWeight.w700,
                fontFamily: 'Roboto Mono',
              ),
              Visibility(
                visible: user.email!.contains(".ac.uk"),
                child: Container(
                  margin: const EdgeInsets.only(top: 10, left: 10),
                  child: Image.asset(
                    'assets/images/check_badge.png',
                    height: 25,
                  ),
                ),
              ),
            ],
          ),
          Image.asset(
            'assets/images/icons8_student.png',
            height: 35,
          ),
          MyText(
            paddingTop: 10.0,
            paddingBottom: 8.0,
            align: TextAlign.center,
            text: user.university!.toUpperCase(),
            size: 16,
            color: kBlackColor,
            fontFamily: 'Roboto',
          ),
          MyText(
            align: TextAlign.center,
            text: '${user.courseName}, ${user.year}',
            size: 12,
            color: kBlackColor,
            fontFamily: 'Roboto',
          ),
          GestureDetector(
            onTap: () {
              // add photos
              showDialog(
                context: context,
                builder: (context) => AddPhotos(
                  user: user,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/bi_plus-circle-fill.png',
                  height: 20,
                ),
                MyText(
                  paddingLeft: 10.0,
                  paddingTop: 30.0,
                  paddingBottom: 20.0,
                  align: TextAlign.center,
                  text: 'Photo gallery',
                  size: 16,
                  color: kBlackColor,
                  fontFamily: 'Roboto',
                ),
              ],
            ),
          ),
          Visibility(
            visible: user.photos != null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: user.photos?.length,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ImagePreview(
                        imageLink: user.photos?[index],
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: CachedNetworkImage(
                                imageUrl: user.photos?[index],
                                height: kHeight(context) * .4,
                                width: kWidth(context),
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          ProfileTiles(
            icon: 'assets/images/ic_round-remove-red-eye.png',
            title: 'View my profile',
            onTap: () {
              Navigator.pushNamed(context, '/view');
            },
          ),
          ProfileTiles(
            icon: 'assets/images/carbon_upgrade.png',
            title: 'Upgrade your account',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UpgradeAccount(),
                ),
              );
            },
          ),
          ProfileTiles(
            icon: 'assets/images/profile.png',
            title: 'Set your account details',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
          ),
          const SizedBox(
            height: 150,
          ),
        ],
      ),
    );
  }
}

class ProfileTiles extends StatelessWidget {
  String? icon, title;
  double? iconSize;
  VoidCallback? onTap;

  ProfileTiles({
    Key? key,
    this.icon,
    this.title,
    this.iconSize = 25.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Image.asset(
                '$icon',
                height: iconSize,
              ),
            ),
            Expanded(
              flex: 8,
              child: MyText(
                text: '$title',
                size: 16,
                color: const Color(0xff434343),
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final String? imageLink;
  final double? height, width;
  final Function()? onTap;
  final BoxFit fit;
  const ImagePreview({
    Key? key,
    required this.imageLink,
    this.height,
    this.width,
    required this.onTap,
    required this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap!();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: imageLink!,
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          width: width ?? 100,
          height: height ?? 100,
          fit: fit,
        ),
      ),
    );
  }
}
