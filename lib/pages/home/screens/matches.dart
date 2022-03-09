import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/core/match_making.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/match_tile.dart';
import 'package:uni_lights/widgets/my_text.dart';

class MyMatches extends StatefulWidget {
  const MyMatches({Key? key}) : super(key: key);

  @override
  State<MyMatches> createState() => _MyMatchesState();
}

class _MyMatchesState extends State<MyMatches> {
  @override
  Widget build(BuildContext context) {
    var user = context.watch<Authentication>().user;
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 110),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            MyText(
              paddingBottom: 15.0,
              align: TextAlign.center,
              text: "My Matches",
              size: 16,
              weight: FontWeight.w700,
              color: kBlackColor,
              fontFamily: 'Roboto Mono',
            ),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: SizedBox(
                height: 40,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                  child: TabBar(
                    labelColor: kPrimaryColor,
                    unselectedLabelColor: kBlackColor,
                    labelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: kGreenColor,
                    ),
                    tabs: const [
                      Text('Mates'),
                      Text('Dates'),
                    ],
                  ),
                ),
              ),
            ),
            user != null
                ? Expanded(
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        FutureBuilder<List<Users>>(
                          future: context.read<MatchMaker>().fetchMatches(user.uid!, false),
                          initialData: context.watch<MatchMaker>().mates,
                          builder: (_, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            context.read<MatchMaker>().setMates(snapshot.data!);

                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.isEmpty ? 1 : snapshot.data?.length,
                              padding: const EdgeInsets.only(top: 30, bottom: 60),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (_, index) {
                                if (snapshot.data!.isNotEmpty) {
                                  return MatchesTiles(
                                    isDate: false,
                                    onTap: () {},
                                    light: snapshot.data![index].light!,
                                    id: snapshot.data![index].uid!,
                                    studentPic: snapshot.data?[index].photoURL,
                                    studentName: snapshot.data?[index].name,
                                    universityName: snapshot.data?[index].university,
                                    department: snapshot.data?[index].courseName,
                                    year: snapshot.data?[index].year,
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
                                          text: 'There are no matches',
                                          size: 12,
                                          color: kGreyColor3,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            );
                          },
                        ),
                        FutureBuilder<List<Users>>(
                          future: context.read<MatchMaker>().fetchMatches(user.uid!, true),
                          initialData: context.watch<MatchMaker>().dates,
                          builder: (_, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            context.read<MatchMaker>().setDates(snapshot.data!);
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.isEmpty ? 1 : snapshot.data?.length,
                              padding: const EdgeInsets.only(top: 30, bottom: 60),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (_, index) {
                                if (snapshot.data!.isNotEmpty) {
                                  return MatchesTiles(
                                    isDate: true,
                                    onTap: () {},
                                    light: snapshot.data![index].light!,
                                    id: snapshot.data![index].uid!,
                                    studentPic: snapshot.data?[index].photoURL,
                                    studentName: snapshot.data?[index].name,
                                    universityName: snapshot.data?[index].university,
                                    department: snapshot.data?[index].courseName,
                                    year: snapshot.data?[index].year,
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
                                          text: 'There are no matches',
                                          size: 12,
                                          color: kGreyColor3,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
