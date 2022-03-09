// ignore_for_file: must_be_immutable, prefer_final_fields

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_button.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:uni_lights/widgets/my_text_field.dart';

class AccountInfo extends StatelessWidget {
  AccountInfo({Key? key, this.isApple = false, this.email = ""}) : super(key: key);
  final bool isApple;
  final String email;
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  Future<bool> _validateInput(BuildContext context) async {
    if (!isApple) {
      if (_password.text.trim().length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password must be more than 6 character long'),
            backgroundColor: kRedColor,
          ),
        );
        return false;
      } else if (_password.text.trim() != _confirmPassword.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password and Confirm password doesn\'t match'),
            backgroundColor: kRedColor,
          ),
        );
        return false;
      }
    }
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No field can be empty'),
          backgroundColor: kRedColor,
        ),
      );
      return false;
    } else if (_name.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name must be more than 3 characters long'),
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
    } else if (await context.read<Authentication>().userExist(_email.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There is already an account with this email.'),
          backgroundColor: kRedColor,
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _email.text = email;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/component_3.png',
                height: 280,
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 12, right: 6),
                child: Image.asset(
                  'assets/images/component_4.png',
                  height: 127,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: MyText(
                    paddingBottom: 15.0,
                    text: 'Create a new account'.toUpperCase(),
                    size: 16,
                    weight: FontWeight.w500,
                    fontFamily: 'Roboto Mono',
                    color: kBlackColor,
                  ),
                ),
                MyTextField(
                  hintText: 'Name',
                  controller: _name,
                ),
                MyTextField(
                  hintText: 'Email (University email preferred)',
                  readOnly: isApple ? true : false,
                  controller: _email,
                ),
                isApple
                    ? Container()
                    : MyTextField(
                        hintText: 'Password',
                        obsecure: true,
                        haveSuffixIcon: true,
                        controller: _password,
                      ),
                isApple
                    ? Container()
                    : MyTextField(
                        hintText: 'Re-type password',
                        obsecure: true,
                        haveSuffixIcon: true,
                        controller: _confirmPassword,
                      ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: kWidth(context) * 0.55,
                    child: MyButton(
                      text: 'NEXT',
                      shadowColor: kRedColor,
                      onPressed: () async {
                        bool isValid = await _validateInput(context);
                        if (isValid) {
                          var data = {
                            "name": _name.text.trim(),
                            "email": _email.text.trim(),
                            "password": isApple ? null : _password.text.trim(),
                          };
                          context.read<Authentication>().setData(data);
                          context.read<Authentication>().next();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
