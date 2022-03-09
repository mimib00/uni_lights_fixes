import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/choice_button.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:url_launcher/url_launcher.dart';

class LightPicker extends StatefulWidget {
  const LightPicker({Key? key}) : super(key: key);

  @override
  State<LightPicker> createState() => _LightPickerState();
}

class _LightPickerState extends State<LightPicker> {
  bool isOld = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/signup_image.png',
                ),
                alignment: Alignment.center,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                  text: 'STRICTLY FOR UNI STUDENTS\nONLY...sorry albert!',
                  size: 16,
                  fontFamily: 'Roboto Mono',
                  weight: FontWeight.w500,
                  color: kBlackColor,
                  align: TextAlign.center,
                ),
                Column(
                  children: [
                    MyText(
                      paddingBottom: 10.0,
                      text: 'Pick your light'.toUpperCase(),
                      size: 16,
                      fontFamily: 'Roboto Mono',
                      weight: FontWeight.w500,
                      color: kBlackColor,
                      align: TextAlign.center,
                    ),
                    MyText(
                      paddingLeft: 50.0,
                      paddingRight: 50.0,
                      text: 'Each profile is colour coded to represent their relationship status.',
                      size: 10,
                      color: kGreyColor,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15, top: 10),
          child: Image.asset('assets/images/line_4.png'),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const ChoiceButton(
                  'Green - Single',
                  kGreenColor,
                  kGreenColor,
                  0,
                ),
                const ChoiceButton(
                  'Orange - It\'s complicated',
                  kOrangeColor,
                  kOrangeColor,
                  1,
                ),
                const ChoiceButton(
                  'Red - In a relationship',
                  kRedColor,
                  kRedColor,
                  2,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Image.asset('assets/images/line_4.png'),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Checkbox(
              value: isOld,
              onChanged: (value) {
                setState(() {
                  isOld = value!;
                });
              },
            ),
            const Text("By ticking this box i confirm I'm +18")
          ],
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: SizedBox(
                  width: kWidth(context) * 0.5,
                  child: MaterialButton(
                    height: 37,
                    elevation: 0,
                    highlightElevation: 0,
                    color: kRedColor,
                    shape: const StadiumBorder(),
                    highlightColor: kRedColor.withOpacity(0.1),
                    onPressed: () {
                      if (!isOld) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You must confirm that you are +18'),
                            backgroundColor: kRedColor,
                          ),
                        );
                      }
                      int choice = context.read<Authentication>().choice;
                      if (choice != -1) {
                        switch (choice) {
                          case 0:
                            context.read<Authentication>().setData({
                              "light": "Signle"
                            });
                            break;
                          case 1:
                            context.read<Authentication>().setData({
                              "light": "It's complicated"
                            });
                            break;
                          case 2:
                            context.read<Authentication>().setData({
                              "light": "In a relationship"
                            });
                            break;
                          default:
                        }
                        context.read<Authentication>().next();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You must select your light'),
                            backgroundColor: kRedColor,
                          ),
                        );
                      }
                    },
                    child: MyText(
                      text: 'Create an account',
                      size: 14,
                      weight: FontWeight.w500,
                      color: kPrimaryColor,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => {
                  launch("https://bit.ly/3ACCpfJ"),
                  launch("https://bit.ly/3nYhkXX"),
                  launch("https://bit.ly/3IEeUFJ")
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: kGreyColor,
                    ),
                    children: [
                      TextSpan(text: 'By creating an account you agree with our\n'),
                      TextSpan(
                        text: 'Terms of Use ',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Roboto', color: kGreyColor, decoration: TextDecoration.underline),
                      ),
                      TextSpan(text: 'and'),
                      TextSpan(
                        text: ' Privacy Policy',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Roboto', color: kGreyColor, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
