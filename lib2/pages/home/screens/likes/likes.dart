import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/pages/home/screens/likes/no_likes.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:uni_lights/widgets/profile_image.dart';
import 'package:provider/provider.dart';

class MyLikes extends StatefulWidget {
  const MyLikes({Key? key}) : super(key: key);

  @override
  State<MyLikes> createState() => _MyLikesState();
}

class _MyLikesState extends State<MyLikes> {
  @override
  void initState() {
    context.read<Authentication>().checkSub();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = context.watch<Authentication>().user!;
    return Padding(
      padding: const EdgeInsets.only(top: 110),
      child: user.isPremium ? const Likes() : const NoLikes(),
    );
  }
}

class Likes extends StatefulWidget {
  const Likes({Key? key}) : super(key: key);

  @override
  State<Likes> createState() => _LikesState();
}

class _LikesState extends State<Likes> {
  Future<List<Users>> fetchMyLikes() {
    var mates = FirebaseFirestore.instance.collection("mates");
    var user = context.read<Authentication>().user!;

    return mates.where(user.uid!, isEqualTo: false).get().then((QuerySnapshot<Map<String, dynamic>> snap) async {
      if (snap.docs.isNotEmpty) {
        List<Users> likes = [];
        for (var doc in snap.docs) {
          List users = List.from(doc.data()["users"]);
          users.removeWhere((e) => e == user.uid!);

          var query = await FirebaseFirestore.instance.collection("users").doc(users.first).get();

          likes.add(Users.fromMap(query.data()!, id: query.id));
        }
        return likes;
      } else {
        return [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyText(
          align: TextAlign.center,
          text: 'My Likes'.toUpperCase(),
          size: 16,
          fontFamily: 'Roboto Mono',
          weight: FontWeight.w700,
          color: kBlackColor,
          paddingBottom: 20.0,
        ),
        Image.asset(
          'assets/images/Line 18.png',
          height: 1,
          width: kWidth(context),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Image.asset(
          'assets/images/icon-park-outline_like.png',
          height: 48,
        ),
        Expanded(
          child: FutureBuilder<List<Users>>(
            future: fetchMyLikes(),
            builder: (context, snapshot) {
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
                case ConnectionState.done:
                  if (snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data?.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 20, bottom: 100),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var data = snapshot.data!;
                        return LikeTile(
                          studentPic: data[index].photoURL!,
                          studentName: data[index].name!,
                          universityName: data[index].university!,
                          department: data[index].courseName!,
                          year: data[index].year!,
                          status: data[index].light!,
                        );
                      },
                    );
                  } else {
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
                            text: 'There are no likes',
                            size: 12,
                            color: kGreyColor3,
                          ),
                        ),
                      ],
                    );
                  }
                default:
                  return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}

class LikeTile extends StatefulWidget {
  final String studentPic, studentName, universityName, department, year, status;
  const LikeTile({
    Key? key,
    required this.studentName,
    required this.status,
    required this.department,
    required this.studentPic,
    required this.universityName,
    required this.year,
  }) : super(key: key);

  @override
  State<LikeTile> createState() => _LikeTileState();
}

class _LikeTileState extends State<LikeTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              ProfileImage(
                image: widget.studentPic,
                status: widget.status,
                width: 90,
                height: 90,
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
                            text: widget.studentName,
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
                                      text: widget.universityName,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
