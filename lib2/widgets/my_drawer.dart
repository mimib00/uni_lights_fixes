import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/pages/home/screens/market/view_products.dart';
import 'package:uni_lights/pages/settings.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/profile_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'my_text.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Users user = context.read<Authentication>().user!;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -38,
          top: 42,
          child: GestureDetector(
            onTap: () {},
            child: Image.asset(
              'assets/images/close_button.png',
              height: 40,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          child: Drawer(
            elevation: 4,
            child: SizedBox(
              width: 300,
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ProfileImage(
                              image: user.photoURL!,
                              height: 200,
                              width: 200,
                              status: user.light!,
                            ),
                          ],
                        ),
                        MyText(
                          paddingTop: 10.0,
                          maxlines: 1,
                          overFlow: TextOverflow.ellipsis,
                          text: user.name,
                          fontFamily: 'Roboto Mono',
                          size: 24,
                          weight: FontWeight.w500,
                          color: kDarkGreyColor,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 10),
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ViewProducts(),
                            ));
                          },
                          leading: Image.asset(
                            'assets/images/ic_outline-sell.png',
                            height: 26,
                          ),
                          title: MyText(
                            text: 'My announcements',
                            size: 20,
                            color: kDarkGreyColor,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          },
                          leading: Image.asset(
                            'assets/images/fluent_settings-32-regular.png',
                            height: 25,
                          ),
                          title: MyText(
                            text: 'Settings',
                            size: 20,
                            weight: FontWeight.w500,
                            color: kDarkGreyColor,
                          ),
                        ),
                        ListTile(
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                          leading: Image.asset(
                            'assets/images/akar-icons_sign-out.png',
                            height: 24,
                          ),
                          title: MyText(
                            text: 'Sign Out',
                            size: 20,
                            weight: FontWeight.w500,
                            color: kDarkGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => launch("mailto:contact@unilightsapp.com"),
                              child: MyText(
                                text: 'Contact us',
                                size: 13,
                                color: kDarkGreyColor,
                              ),
                            ),
                            MyText(
                              text: '|',
                              size: 13,
                              color: kDarkGreyColor,
                            ),
                            GestureDetector(
                              onTap: () => {
                                launch("https://bit.ly/3ACCpfJ"),
                                launch("https://bit.ly/3nYhkXX")
                              },
                              child: MyText(
                                text: 'Privacy',
                                size: 13,
                                color: kDarkGreyColor,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => launch("https://bit.ly/3IEeUFJ"),
                          child: MyText(
                            text: 'Terms and conditions',
                            size: 13,
                            color: kDarkGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
