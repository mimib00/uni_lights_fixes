// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/widgets/my_app_bar.dart';

import 'singup_steps/about_me.dart';
import 'singup_steps/account_info.dart';
import 'singup_steps/know_each_other.dart';
import 'singup_steps/light_pick.dart';

class SignUp extends StatefulWidget {
  final String uid, email;
  final bool isApple;
  SignUp({Key? key, this.uid = "", this.email = "", this.isApple = false}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  List steps = [];
  @override
  void initState() {
    steps = [
      const LightPicker(),
      AccountInfo(
        isApple: widget.isApple,
        email: widget.email,
      ),
      const AboutMe(),
      KnowEachOther(uid: widget.uid, isApple: widget.isApple),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int index = context.watch<Authentication>().step;
    return Scaffold(
      appBar: MyAppBar(
        haveBackButton: true,
        backButtonOnTap: () {
          context.read<Authentication>().disposed();
          Navigator.of(context).pop();
        },
      ),
      body: steps[index],
    );
  }
}
