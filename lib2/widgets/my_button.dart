// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:uni_lights/utils/constants.dart';

class MyButton extends StatefulWidget {
  var text, weight, textColor, btnBgColor, radius, shadowColor, fontFamily;
  double? textSize, height, elevation;
  VoidCallback? onPressed;

  MyButton({
    Key? key,
    this.text,
    this.textSize = 14,
    this.textColor = kBlackColor,
    this.btnBgColor = kPrimaryColor,
    this.height = 37,
    this.shadowColor = kGreyColor,
    this.radius = 50.0,
    this.fontFamily = 'Poppins',
    this.weight = FontWeight.w500,
    this.onPressed,
  }) : super(key: key);

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor,
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: MaterialButton(
        elevation: 0,
        splashColor: widget.shadowColor.withOpacity(0.1),
        highlightColor: widget.shadowColor.withOpacity(0.1),
        highlightElevation: 0,
        onPressed: widget.onPressed,
        color: widget.btnBgColor,
        height: widget.height,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        child: Text(
          '${widget.text}',
          style: TextStyle(
            fontSize: widget.textSize,
            color: widget.textColor,
            fontWeight: widget.weight,
            fontFamily: widget.fontFamily,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
