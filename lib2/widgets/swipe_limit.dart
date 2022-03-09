import 'package:flutter/material.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_button.dart';
import 'package:uni_lights/widgets/my_text.dart';

class SwipeLimit extends StatelessWidget {
  const SwipeLimit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Rectangle 96.png'),
            fit: BoxFit.fill,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                width: kWidth(context),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/bi_exclamation-circle-fill.png',
                      height: 60,
                    ),
                    MyText(
                      align: TextAlign.center,
                      paddingTop: 20.0,
                      paddingBottom: 20.0,
                      text: 'You\'ve reached the limit of swipes for today! \n\nUpgrade to unilights pro for unlimited swipes'.toUpperCase(),
                      size: 16,
                      fontFamily: 'Roboto Mono',
                      weight: FontWeight.w700,
                      color: kDarkGreyColor,
                      lineHeight: 1.5,
                    ),
                    SizedBox(
                      width: kWidth(context) * 0.5,
                      child: MyButton(
                        text: 'UPGRADE NOW',
                        fontFamily: 'Roboto',
                        weight: FontWeight.w500,
                        shadowColor: kOrangeColor,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
