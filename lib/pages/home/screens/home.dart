import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/data_manager.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/core/match_making.dart';
import 'package:uni_lights/pages/home/screens/inbox/chat_screen.dart';
import 'package:uni_lights/pages/home/screens/profile/profile_screen.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/utils/helper.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:uni_lights/widgets/profile_image.dart';
import 'package:uni_lights/widgets/swipe_limit.dart';
import 'package:uni_lights/widgets/tags.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  var currentIndex = 0;
  TabController? _controller;
  double radius = 10;

  late Stream stream;
  @override
  void initState() {
    super.initState();
    var locationData = context.read<Authentication>().locationData!;

    setState(() {
      stream = context.read<MatchMaker>().fetchNearByUsers(locationData, radius)!;
    });
    _controller = TabController(length: 2, vsync: this);
    _controller!.addListener(() {
      setState(() {
        currentIndex = _controller!.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = context.watch<Authentication>().user;
    int swipes = context.watch<DataManager>().swipes;
    return swipes <= 0
        ? const SwipeLimit()
        : Padding(
            padding: const EdgeInsets.only(top: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                      ),
                      child: TabBar(
                        controller: _controller,
                        labelColor: kPrimaryColor,
                        unselectedLabelColor: kBlackColor,
                        labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: currentIndex == 0 ? kRedColor : kGreenColor,
                        ),
                        tabs: const [
                          Text('Uni Mates'),
                          Text('Uni Dates'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<dynamic>(
                    stream: stream,
                    builder: (_, snapshot) {
                      if (!snapshot.hasData) return Text('Error: ${snapshot.error}');
                      var data = snapshot.data;

                      if (data["callBack"] == Geofire.onGeoQueryReady) {
                        List list = List.from(data["result"]);
                        list.removeWhere((element) => element == user!.uid);
                        for (var key in list) {
                          context.read<MatchMaker>().queryUsers(key, user!);
                        }
                      }

                      return UniDates(
                        isDate: currentIndex == 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}

class UniDates extends StatefulWidget {
  final bool isDate;
  const UniDates({
    Key? key,
    required this.isDate,
  }) : super(key: key);

  @override
  State<UniDates> createState() => _UniDatesState();
}

class _UniDatesState extends State<UniDates> {
  int index = 0;
  Users? currentDate;

  bool isLike = false;
  bool isClose = false;

  final CollectionReference<Map<String, dynamic>> _chatroom = FirebaseFirestore.instance.collection('chatroom');

  createChatRoom(Users user, Users date) async {
    String id = getId(user.uid!, date.uid!);
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
          "id": date.uid,
          "name": date.name!,
          "photo_url": date.photoURL!,
          "light": date.light!,
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
            name: date.name!,
            photo: date.photoURL!,
          ),
        ),
      );
    });

    // return true
  }

  @override
  Widget build(BuildContext context) {
    List<Users> dates = context.watch<MatchMaker>().users;
    if (dates.length > index) currentDate = dates[index];

    return dates.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Visibility(
            visible: currentDate != null,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              physics: const BouncingScrollPhysics(),
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ProfileImage(
                      image: currentDate!.photoURL!,
                      status: currentDate!.light!,
                      height: 210,
                      width: 210,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Left
                    GestureDetector(
                      onTap: () {
                        context.read<DataManager>().swipe().then((value) {
                          if (value != "limit") {
                            dates.removeWhere((element) => element.uid == currentDate!.uid);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: kPrimaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: kRedColor.withOpacity(0.63),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                              offset: const Offset(
                                0.0,
                                4.0,
                              ),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/emojione-v1_heavy-multiplication-x.png',
                            height: 25,
                          ),
                        ),
                      ),
                    ),
                    // Message
                    GestureDetector(
                      onTap: () {
                        var user = context.read<Authentication>().user!;
                        if (user.isPremium) {
                          createChatRoom(user, currentDate!);
                        } else {}
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: kPrimaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: kOrangeColor.withOpacity(0.63),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                              offset: const Offset(
                                0.0,
                                4.0,
                              ),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/chat.png',
                            height: 25,
                          ),
                        ),
                      ),
                    ),
                    // Match
                    GestureDetector(
                      onTap: () {
                        var user = context.read<Authentication>().user!;
                        context.read<DataManager>().swipe().then((temp) {
                          if (temp != "limit") {
                            context.read<MatchMaker>().match(user.uid!, currentDate!.uid!, widget.isDate);
                            setState(() {
                              dates.removeAt(index);
                            });
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: kPrimaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: kRedColor.withOpacity(0.63),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                              offset: const Offset(
                                0.0,
                                4.0,
                              ),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/heartt.png',
                            height: 35,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                MyText(
                  paddingTop: 20.0,
                  paddingBottom: 10.0,
                  align: TextAlign.center,
                  text: currentDate!.name!.toUpperCase(),
                  size: 16,
                  color: kBlackColor,
                  weight: FontWeight.w700,
                  fontFamily: 'Roboto Mono',
                ),
                Image.asset(
                  'assets/images/icons8_student.png',
                  height: 35,
                ),
                MyText(
                  paddingTop: 10.0,
                  paddingBottom: 8.0,
                  align: TextAlign.center,
                  text: currentDate!.university,
                  size: 16,
                  color: kBlackColor,
                  fontFamily: 'Roboto',
                ),
                MyText(
                  paddingBottom: 20.0,
                  align: TextAlign.center,
                  text: currentDate!.year == "Joining in september" ? '${currentDate!.courseName}, ${currentDate!.year}' : '${currentDate!.courseName}, ${currentDate!.year} Year',
                  size: 12,
                  color: kBlackColor,
                  fontFamily: 'Roboto',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "“${currentDate?.quote}”",
                    style: const TextStyle(
                      fontSize: 12,
                      color: kGreyColor,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                MyText(
                  paddingTop: 20.0,
                  paddingLeft: 10.0,
                  paddingRight: 10.0,
                  paddingBottom: 35.0,
                  align: TextAlign.center,
                  text: currentDate?.bio,
                  size: 12,
                  color: kGreyColor,
                  fontFamily: 'Roboto',
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10.0,
                  runSpacing: 15.0,
                  children: currentDate!.tags!.map((e) => Tags(title: e)).toList(),
                ),
                Visibility(
                  visible: currentDate!.photos != null,
                  child: MyText(
                    paddingTop: 30.0,
                    paddingBottom: 30.0,
                    align: TextAlign.center,
                    text: 'Photo gallery',
                    size: 16,
                    color: kBlackColor,
                    fontFamily: 'Roboto',
                  ),
                ),
                Visibility(
                  visible: currentDate?.photos != null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: currentDate?.photos?.length,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ImagePreview(
                              imageLink: currentDate?.photos?[index],
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: CachedNetworkImage(
                                      imageUrl: currentDate?.photos?[index],
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
                  height: 150,
                ),
              ],
            ),
          );
  }
}
