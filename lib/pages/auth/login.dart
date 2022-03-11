// ignore_for_file: prefer_final_fields

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_app_bar.dart';
import 'package:uni_lights/widgets/my_button.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:uni_lights/widgets/my_text_field.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // bool? status = false;

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  bool _validateInput() {
    if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No field can be empty'),
          backgroundColor: kRedColor,
        ),
      );
      return false;
    } else if (!EmailValidator.validate(_email.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email is not valid'),
          backgroundColor: kRedColor,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: const MyAppBar(
        haveBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              height: kWidth(context),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      MyTextField(
                        hintText: 'Email',
                        controller: _email,
                      ),
                      MyTextField(
                        hintText: 'Password',
                        obsecure: true,
                        haveSuffixIcon: true,
                        controller: _password,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: kWidth(context) * 0.5,
                        child: MyButton(
                          onPressed: () {
                            bool isValid = _validateInput();
                            if (!isValid) return;
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
                            context.read<Authentication>().login(_email.text.trim(), _password.text.trim());
                          },
                          text: 'SIGN IN'.toUpperCase(),
                          shadowColor: kRedColor,
                        ),
                      ),
                      MyText(
                        paddingTop: 20.0,
                        text: 'Forgot your password?',
                        size: 13,
                        decoration: TextDecoration.underline,
                        color: kRedColor,
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
