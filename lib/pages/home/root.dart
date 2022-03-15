import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/core/data_manager.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/pages/home/screens/inbox/inbox.dart';
import 'package:uni_lights/pages/home/screens/likes/likes.dart';
import 'package:uni_lights/pages/home/screens/market/market.dart';
import 'package:uni_lights/pages/home/screens/matches.dart';

import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/bottom_nav_bar.dart';
import 'package:uni_lights/widgets/my_app_bar.dart';
import 'package:uni_lights/widgets/my_drawer.dart';
import 'package:uni_lights/widgets/my_text.dart';

import 'screens/home.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/social.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int selectedScreen = 0;

  List<Widget> screens = [
    const UserProfile(),
    const MyLikes(),
    const UniMarket(),
    const Home(),
    const Social(),
    const Inbox(),
    const MyMatches(),
  ];

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  isNewUser(user) {
    if (user?.bio == null) {
      // add bio and quote.
      showDialog(
        context: context,
        builder: (context) => AddBio(
          user: user,
        ),
        barrierDismissible: false,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    context.read<Authentication>().getUserData();

    context.read<DataManager>().checkLimits(context);
    // Future.delayed(const Duration(seconds: 2), () {
    //   isNewUser(user);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      endDrawer: const MyDrawer(),
      appBar: MyAppBar(
        haveMenuButton: true,
        globalKey: _key,
      ),
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: Builder(
        builder: (context) {
          return Scaffold(
            body: screens[selectedScreen],
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Visibility(
              visible: MediaQuery.of(context).viewInsets.bottom == 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedScreen = 3;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 100, right: 2),
                  height: 70,
                  width: 70,
                  padding: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/ellipse_141.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/heart_white.png',
                      height: 25,
                    ),
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.transparent,
              ),
              child: BottomAppBar(
                color: Colors.transparent,
                elevation: 0,
                shape: const CircularNotchedRectangle(),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bottom_bar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: 100,
                  padding: const EdgeInsets.only(left: 15, right: 15, bottom: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          BottomNavBarItem(
                            icon: 'assets/images/ic_sharp-account-circle.png',
                            iconSize: 27,
                            isSelected: selectedScreen == 0,
                            onTap: () {
                              setState(() {
                                selectedScreen = 0;
                              });
                            },
                          ),
                          BottomNavBarItem(
                            icon: 'assets/images/group.png',
                            iconSize: 22.0,
                            isSelected: selectedScreen == 1,
                            onTap: () {
                              setState(() {
                                selectedScreen = 1;
                              });
                            },
                          ),
                          BottomNavBarItem(
                            icon: 'assets/images/ic_baseline-sell.png',
                            isSelected: selectedScreen == 2,
                            onTap: () {
                              setState(() {
                                selectedScreen = 2;
                              });
                            },
                          ),
                          //do not remove these empty containers
                          Container(),
                          Container(),
                          //do not remove these empty containers
                          BottomNavBarItem(
                            icon: 'assets/images/fluent_document-one-page-24-filled.png',
                            isSelected: selectedScreen == 4,
                            onTap: () {
                              setState(() {
                                selectedScreen = 4;
                              });
                            },
                          ),
                          BottomNavBarItem(
                            icon: 'assets/images/bi_chat-dots-fill.png',
                            isSelected: selectedScreen == 5,
                            onTap: () {
                              setState(() {
                                selectedScreen = 5;
                              });
                            },
                          ),

                          BottomNavBarItem(
                            icon: 'assets/images/group_44.png',
                            iconSize: 28.0,
                            isSelected: selectedScreen == 6,
                            onTap: () {
                              setState(() {
                                selectedScreen = 6;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    // return Scaffold(
    //   key: _key,
    // appBar: MyAppBar(
    //   haveMenuButton: true,
    //   globalKey: _key,
    // ),
    //   endDrawer: const MyDrawer(),
    // resizeToAvoidBottomInset: true,
    // extendBodyBehindAppBar: true,
    //   // extendBody: true,
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    //   body: screens[selectedScreen],
    // floatingActionButton: Visibility(
    //   visible: MediaQuery.of(context).viewInsets.bottom == 0,
    //   child: GestureDetector(
    //     onTap: () {
    //       setState(() {
    //         selectedScreen = 3;
    //       });
    //     },
    //     child: Container(
    //       margin: const EdgeInsets.only(top: 100, right: 2),
    //       height: 70,
    //       width: 70,
    //       padding: const EdgeInsets.only(bottom: 4),
    //       decoration: BoxDecoration(
    //         color: kPrimaryColor,
    //         image: const DecorationImage(
    //           image: AssetImage('assets/images/ellipse_141.png'),
    //           fit: BoxFit.cover,
    //         ),
    //         borderRadius: BorderRadius.circular(100),
    //       ),
    //       child: Center(
    //         child: Image.asset(
    //           'assets/images/heart_white.png',
    //           height: 25,
    //         ),
    //       ),
    //     ),
    //   ),
    // ),
    // bottomNavigationBar: Theme(
    //   data: Theme.of(context).copyWith(
    //     canvasColor: Colors.transparent,
    //   ),
    //   child: BottomAppBar(
    //     color: Colors.transparent,
    //     elevation: 0,
    //     shape: const CircularNotchedRectangle(),
    //     child: Container(
    //       decoration: const BoxDecoration(
    //         image: DecorationImage(
    //           image: AssetImage('assets/images/bottom_bar.png'),
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //       height: 100,
    //       padding: const EdgeInsets.only(left: 15, right: 15, bottom: 3),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.end,
    //         children: [
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: [
    //               BottomNavBarItem(
    //                 icon: 'assets/images/ic_sharp-account-circle.png',
    //                 iconSize: 27,
    //                 isSelected: selectedScreen == 0,
    //                 onTap: () {
    //                   setState(() {
    //                     selectedScreen = 0;
    //                   });
    //                 },
    //               ),
    //               BottomNavBarItem(
    //                 icon: 'assets/images/group.png',
    //                 iconSize: 22.0,
    //                 isSelected: selectedScreen == 1,
    //                 onTap: () {
    //                   setState(() {
    //                     selectedScreen = 1;
    //                   });
    //                 },
    //               ),
    //               BottomNavBarItem(
    //                 icon: 'assets/images/ic_baseline-sell.png',
    //                 isSelected: selectedScreen == 2,
    //                 onTap: () {
    //                   setState(() {
    //                     selectedScreen = 2;
    //                   });
    //                 },
    //               ),
    //               //do not remove these empty containers
    //               Container(),
    //               Container(),
    //               //do not remove these empty containers
    //               BottomNavBarItem(
    //                 icon: 'assets/images/fluent_document-one-page-24-filled.png',
    //                 isSelected: selectedScreen == 4,
    //                 onTap: () {
    //                   setState(() {
    //                     selectedScreen = 4;
    //                   });
    //                 },
    //               ),
    //               BottomNavBarItem(
    //                 icon: 'assets/images/bi_chat-dots-fill.png',
    //                 isSelected: selectedScreen == 5,
    //                 onTap: () {
    //                   setState(() {
    //                     selectedScreen = 5;
    //                   });
    //                 },
    //               ),

    //               BottomNavBarItem(
    //                 icon: 'assets/images/group_44.png',
    //                 iconSize: 28.0,
    //                 isSelected: selectedScreen == 6,
    //                 onTap: () {
    //                   setState(() {
    //                     selectedScreen = 6;
    //                   });
    //                 },
    //               ),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // ),
    // );
  }
}

class AddBio extends StatelessWidget {
  final Users? user;
  AddBio({Key? key, required this.user}) : super(key: key);

  final TextEditingController _bio = TextEditingController();
  final TextEditingController _quote = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: MyText(
        paddingBottom: 15.0,
        align: TextAlign.center,
        text: "Add Bio & Quote",
        size: 20,
        weight: FontWeight.w700,
        color: kBlackColor,
        fontFamily: 'Roboto Mono',
      ),
      content: SizedBox(
        height: kHeight(context) * .18,
        child: Form(
          key: _key,
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) return "You must enter a Bio.";
                  if (value.length < 10) return "Bio must be 50 charachters long.";
                  return null;
                },
                controller: _bio,
                cursorColor: kRedColor,
                decoration: const InputDecoration(
                  hintText: "Bio",
                  hintStyle: TextStyle(
                    color: kGreyColor,
                  ),
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) return "You must enter a Quote.";
                  if (value.length < 10) return "Quote must be 10 charachters long.";
                  return null;
                },
                controller: _quote,
                cursorColor: kRedColor,
                decoration: const InputDecoration(
                  hintText: "Quote",
                  hintStyle: TextStyle(
                    color: kGreyColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () {
            if (_key.currentState!.validate()) {
              var ref = FirebaseFirestore.instance.collection("users").doc(user?.uid);

              Map<String, dynamic> data = {
                "bio": _bio.text.trim(),
                "quote": _quote.text.trim(),
              };

              ref.update(data);
              context.read<Authentication>().getUserData().then((value) => Navigator.of(context).pop());
            }
          },
          child: const Text(
            "ADD",
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }
}

class AddPhotos extends StatefulWidget {
  final Users? user;
  const AddPhotos({Key? key, required this.user}) : super(key: key);

  @override
  State<AddPhotos> createState() => _AddPhotosState();
}

class _AddPhotosState extends State<AddPhotos> {
  List<File> photos = [];
  bool showError = false, uploadLoading = false;

  void _getImages() async {
    final ImagePicker _picker = ImagePicker();
    var temp = await _picker.pickMultiImage();
    if (temp != null) {
      for (var i = 0; i < 3; i++) {
        setState(() {
          photos.add(File(temp[i].path));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          MyText(
            align: TextAlign.center,
            text: "Add Photos",
            size: 20,
            weight: FontWeight.w700,
            color: kBlackColor,
            fontFamily: 'Roboto Mono',
          ),
          Visibility(
            visible: showError,
            child: MyText(
              align: TextAlign.center,
              text: "You must select 3 photos of you",
              size: 8,
              weight: FontWeight.w700,
              color: Colors.red,
              fontFamily: 'Roboto Mono',
            ),
          ),
        ],
      ),
      content: SizedBox(
        height: kHeight(context) * .2,
        width: kWidth(context),
        child: photos.isEmpty
            ? OutlinedButton(
                onPressed: () => _getImages(),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.black,
                  size: 50,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: photos.length,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) => photos
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Image.file(
                          e,
                          width: 100,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .toList()[index],
              ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        uploadLoading
            ? const CircularProgressIndicator.adaptive()
            : OutlinedButton(
                onPressed: () async {
                  if (photos.isEmpty || photos.length != 3) {
                    setState(() {
                      showError = true;
                    });
                    Future.delayed(const Duration(seconds: 3), () {
                      setState(() {
                        showError = false;
                        uploadLoading = false;
                      });
                    });
                  } else {
                    setState(() {
                      uploadLoading = true;
                    });
                    final Reference _storage = FirebaseStorage.instance.ref();

                    List<String> list = [];
                    for (var image in photos) {
                      var path = "/images/${widget.user?.uid}/${DateTime.now().microsecondsSinceEpoch}";
                      TaskSnapshot snapshot = await _storage.child(path).putFile(image);
                      if (snapshot.state == TaskState.success) {
                        var imageUrl = await snapshot.ref.getDownloadURL();

                        list.add(
                          imageUrl,
                        );
                      }
                    }
                    var ref = FirebaseFirestore.instance.collection("users").doc(widget.user?.uid!);
                    Map<String, dynamic> data = {
                      "photos": list
                    };
                    ref.update(data);
                    context.read<Authentication>().getUserData().then((value) => Navigator.of(context).pop());
                    setState(() {
                      uploadLoading = false;
                    });
                  }
                },
                child: const Text(
                  "ADD",
                  style: TextStyle(fontSize: 20),
                ),
              ),
        Visibility(
          visible: photos.isNotEmpty,
          child: IconButton(
            icon: const Icon(Icons.undo_rounded),
            onPressed: () {
              setState(() {
                photos.clear();
              });
            },
          ),
        ),
      ],
    );
  }
}
