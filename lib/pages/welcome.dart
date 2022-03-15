import 'package:flutter/material.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_button.dart';
import 'package:uni_lights/widgets/my_text.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo_2.png',
          height: 89,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              height: kHeight(context),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/group_41.png'),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      MyText(
                        paddingBottom: 20.0,
                        text: 'WELCOME!',
                        size: 24,
                        weight: FontWeight.w500,
                        color: kBlackColor,
                        fontFamily: 'Roboto Mono',
                      ),
                      MyText(
                        lineHeight: 1.5,
                        text: 'Uni Lights is a sociable app for connecting university students. Built for dates, mates, discounts and more.',
                        size: 12,
                        color: kGreyColor2,
                        fontFamily: 'Roboto',
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FlutterSocialButton(
                        onTap: () {
                          context.read<Authentication>().signInWithApple(context);
                        },
                        buttonType: ButtonType.apple,
                        iconColor: Colors.white,
                        title: "Sign in with Apple",
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: kWidth(context) * 0.25,
                            child: MyButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/login');
                              },
                              text: 'SIGN IN'.toUpperCase(),
                              shadowColor: kRedColor,
                            ),
                          ),
                          MyText(
                            paddingTop: 15.0,
                            paddingBottom: 15.0,
                            text: 'or',
                            size: 16,
                            color: kBlackColor,
                            fontFamily: 'Roboto',
                          ),
                          SizedBox(
                            width: kWidth(context) * 0.25,
                            child: MyButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/signup');
                              },
                              text: 'SIGN UP'.toUpperCase(),
                              shadowColor: kGreenColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
