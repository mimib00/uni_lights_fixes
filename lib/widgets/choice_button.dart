import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/utils/constants.dart';

class ChoiceButton extends StatelessWidget {
  final String text;
  final Color shadowColor;
  final Color selectedColor;
  final int index;
  const ChoiceButton(
    this.text,
    this.selectedColor,
    this.shadowColor,
    this.index, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int currentIndex = context.watch<Authentication>().choice;
    return SizedBox(
      width: kWidth(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: MaterialButton(
          elevation: 0,
          splashColor: shadowColor.withOpacity(0.1),
          highlightColor: shadowColor.withOpacity(0.1),
          highlightElevation: 0,
          onPressed: () {
            context.read<Authentication>().setChoice(index);
          },
          color: currentIndex == index ? selectedColor : kPrimaryColor,
          height: 37,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: currentIndex == index ? kPrimaryColor : kGreyColor,
              fontWeight: FontWeight.w300,
              fontFamily: 'Roboto',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
