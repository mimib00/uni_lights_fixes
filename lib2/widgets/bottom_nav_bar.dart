// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:uni_lights/utils/constants.dart';

class BottomNavBarItem extends StatelessWidget {
  BottomNavBarItem({
    Key? key,
    this.icon,
    this.isSelected,
    this.onTap,
    this.iconSize = 25.0,
  }) : super(key: key);
  String? icon;
  bool? isSelected;
  VoidCallback? onTap;
  double? iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            '$icon',
            color: isSelected! ? kRedColor : kBlackColor,
            height: iconSize,
          ),
          isSelected!
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.asset(
                    'assets/images/rectangle_94.png',
                    width: 13,
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 13,
                  height: 4,
                ),
        ],
      ),
    );
  }
}
