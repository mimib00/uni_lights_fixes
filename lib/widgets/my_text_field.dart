// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'package:flutter/material.dart';
import 'package:uni_lights/utils/constants.dart';

class MyTextField extends StatefulWidget {
  var hintText, suffixIcon, hintTextColor, suffixIconColor;
  bool? obsecure, haveSuffixIcon;
  bool readOnly;
  double? iconHeight, bottomPadding;
  Function()? onTap;
  TextEditingController? controller = TextEditingController();

  MyTextField({
    Key? key,
    this.hintText,
    this.suffixIcon,
    this.bottomPadding = 15.0,
    this.hintTextColor = kGreyColor,
    this.suffixIconColor,
    this.haveSuffixIcon = false,
    this.iconHeight,
    this.controller,
    this.obsecure = false,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.bottomPadding!,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: widget.controller,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            textAlignVertical: TextAlignVertical.center,
            cursorColor: kGreyColor,
            style: const TextStyle(
              color: kGreyColor,
              fontSize: 14,
            ),
            obscureText: widget.obsecure!,
            obscuringCharacter: "*",
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: '${widget.hintText}',
              hintStyle: TextStyle(
                color: widget.hintTextColor,
                fontSize: 14,
              ),
              suffixIcon: widget.haveSuffixIcon == true
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          widget.obsecure = !widget.obsecure!;
                        });
                      },
                      icon: Image.asset(
                        'assets/images/eye-icon.png',
                        height: 16,
                      ),
                    )
                  : const SizedBox(),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: kBorderColor,
                  width: 1.5,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: kBorderColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
