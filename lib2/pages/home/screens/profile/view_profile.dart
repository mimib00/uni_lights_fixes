import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/pages/home/screens/profile/profile_screen.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_app_bar.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:uni_lights/widgets/profile_image.dart';
import 'package:uni_lights/widgets/tags.dart';
import 'package:uni_lights/widgets/uni_bottom_sheet.dart';

class ViewProfile extends StatelessWidget {
  const ViewProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Users user = context.watch<Authentication>().user!;

    return Scaffold(
      appBar: const MyAppBar(
        haveMenuButton: true,
        haveBackButton: true,
      ),
      body: ListView(
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
            paddingBottom: 20.0,
            align: TextAlign.center,
            text: '${user.courseName}, ${user.year}',
            size: 12,
            color: kBlackColor,
            fontFamily: 'Roboto',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "“${user.quote}”",
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
            text: user.bio,
            size: 12,
            color: kGreyColor,
            fontFamily: 'Roboto',
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10.0,
            runSpacing: 15.0,
            children: user.tags!.map((e) => Tags(title: e)).toList(),
          ),
          Visibility(
            visible: user.photos != null,
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
            height: 30.0,
          ),
          Center(
            child: SizedBox(
              width: kWidth(context) * 0.355,
              child: MaterialButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      // var posts = context.read<DataController>().fetchMyPosts(context);
                      return const UniBottomSheet(
                        title: "Posts",
                        // content: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        //   stream: posts,
                        //   builder: (context, snapshot) {
                        //     if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                        //     switch (snapshot.connectionState) {
                        //       case ConnectionState.none:
                        //         return const Center(child: Text('No Data'));
                        //       case ConnectionState.waiting:
                        //         return const Center(child: Text('Loading...'));
                        //       case ConnectionState.active:
                        //         if (snapshot.data!.size > 0) {
                        //           var docs = snapshot.data!.docs;
                        //           return Column(
                        //             children: docs
                        //                 .map(
                        //                   (e) => PostCard(
                        //                     post: Posts(caption: "").fromMap(e.data(), e.id),
                        //                     onDelete: () {
                        //                       print("Click");
                        //                     },
                        //                   ),
                        //                 )
                        //                 .toList(),
                        //           );
                        //         } else {
                        //           return Container();
                        //         }

                        //       default:
                        //         return Container();
                        //     }
                        //   },
                        // ),
                      );
                    },
                  );
                },
                height: 35,
                elevation: 0,
                highlightElevation: 0,
                color: kRedColor,
                shape: const StadiumBorder(),
                child: MyText(
                  maxlines: 1,
                  overFlow: TextOverflow.ellipsis,
                  text: 'See my posts',
                  size: 14,
                  weight: FontWeight.w500,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
