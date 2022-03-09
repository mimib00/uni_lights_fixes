import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_button.dart';
import 'package:uni_lights/widgets/my_text.dart';

class KnowEachOther extends StatefulWidget {
  final String uid;
  final bool isApple;
  const KnowEachOther({Key? key, this.isApple = false, this.uid = ""}) : super(key: key);

  @override
  State<KnowEachOther> createState() => _KnowEachOtherState();
}

class _KnowEachOtherState extends State<KnowEachOther> {
  String item1 = '';
  String item2 = '';
  String item3 = '';
  String item4 = "";
  String item5 = "";
  int? currentIndex;

  bool _validateInput() {
    if (item1.isEmpty || item2.isEmpty || item3.isEmpty || item4.isEmpty || item5.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No field can be empty'),
          backgroundColor: kRedColor,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          MyText(
            paddingLeft: 50.0,
            paddingRight: 50.0,
            align: TextAlign.center,
            text: 'Let\'s get to know each other',
            size: 16,
            weight: FontWeight.w500,
            fontFamily: 'Roboto Mono',
            color: kBlackColor,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('My guilty pleasure is...'),
              RadioGroup<String>.builder(
                groupValue: item1,
                activeColor: kRedColor,
                onChanged: (value) => setState(() {
                  item1 = value!;
                }),
                items: const [
                  'Serial shopper',
                  'Series binger',
                  'Party goer',
                  'Chocoholic',
                ],
                itemBuilder: (item) => RadioButtonBuilder(
                  item,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('I am a...'),
              RadioGroup<String>.builder(
                groupValue: item2,
                activeColor: kRedColor,
                onChanged: (value) => setState(() {
                  item2 = value!;
                }),
                items: const [
                  'Fine diner',
                  'Takeaway Master',
                ],
                itemBuilder: (item) => RadioButtonBuilder(
                  item,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('Perfect gap year is being a...'),
              RadioGroup<String>.builder(
                groupValue: item3,
                activeColor: kRedColor,
                onChanged: (value) => setState(() {
                  item3 = value!;
                }),
                items: const [
                  'Ski-Bum',
                  'Travel-Bum',
                  'Beach-Bum',
                ],
                itemBuilder: (item) => RadioButtonBuilder(
                  item,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('If my Spotify could talk, I\'d be a...'),
              RadioGroup<String>.builder(
                groupValue: item4,
                activeColor: kRedColor,
                onChanged: (value) => setState(() {
                  item4 = value!;
                }),
                items: const [
                  'Disco dreamer',
                  'Club raver',
                  'Indie lover',
                  'RnB strutter',
                ],
                itemBuilder: (item) => RadioButtonBuilder(
                  item,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('My happy hour is me being a...'),
              RadioGroup<String>.builder(
                groupValue: item5,
                activeColor: kRedColor,
                onChanged: (value) => setState(() {
                  item5 = value!;
                }),
                items: const [
                  'Coffee junkie',
                  'Wine lover',
                  'Beer drinker',
                  'Cocktail sipper',
                  'Spirit seeker',
                  'Green tea chiller',
                ],
                itemBuilder: (item) => RadioButtonBuilder(
                  item,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: kPrimaryColor,
        child: SizedBox(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: kWidth(context) * 0.55,
                child: MyButton(
                  text: 'FINISH',
                  shadowColor: kRedColor,
                  onPressed: () async {
                    bool isValid = _validateInput();
                    if (isValid) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Row(
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(width: 8),
                              Text("Loading..."),
                            ],
                          ),
                        ),
                      );
                      var data = {
                        "tags": [
                          item1,
                          item2,
                          item3,
                          item4,
                          item5
                        ],
                      };
                      context.read<Authentication>().setData(data);
                      if (widget.isApple) {
                        var isRegistered = await context.read<Authentication>().appleSignUp(widget.uid);
                        if (!isRegistered) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Error in apple login"), backgroundColor: kRedColor),
                          );
                          return;
                        }
                        Navigator.pushNamed(context, '/root');
                      }
                      var isRegistered = await context.read<Authentication>().signUp();
                      if (!isRegistered) return;
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MyText heading(String title) {
    return MyText(
      paddingTop: 30,
      text: title,
      size: 14,
      color: kBlackColor,
      paddingBottom: 15.0,
    );
  }
}
