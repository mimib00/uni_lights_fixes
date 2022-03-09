// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uni_lights/utils/constants.dart';

import 'my_text.dart';

class Tags extends StatelessWidget {
  final String title;
  final Color? shadowColor;
  Tags({Key? key, required this.title, this.shadowColor}) : super(key: key);

  Random random = Random(DateTime.now().microsecondsSinceEpoch);

  @override
  Widget build(BuildContext context) {
    int index = random.nextInt(lights.length);
    return Chip(
      backgroundColor: kPrimaryColor,
      elevation: 10,
      shadowColor: shadowColor ?? lights[index],
      side: BorderSide(color: shadowColor ?? lights[index], width: 0.1),
      label: MyText(
        text: title,
        size: 12,
        color: kGreyColor,
        maxlines: 1,
        overFlow: TextOverflow.ellipsis,
      ),
    );
  }
}

/*Container(
      width: 96,
      height: 29,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: kPrimaryColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? lights[index],
            blurRadius: 10.0,
            spreadRadius: 2.0,
            offset: const Offset(
              0.0,
              4.0,
            ),
          ),
        ],
      ),
      child: Center(
        child: MyText(
          text: title,
          size: 12,
          color: kGreyColor,
          maxlines: 1,
          overFlow: TextOverflow.ellipsis,
        ),
      ),
    );*/
