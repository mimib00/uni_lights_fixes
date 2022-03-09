import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:uni_lights/utils/constants.dart';

import 'my_text.dart';

class CustomSwitchTiles extends StatefulWidget {
  const CustomSwitchTiles({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  State<CustomSwitchTiles> createState() => _CustomSwitchTilesState();
}

class _CustomSwitchTilesState extends State<CustomSwitchTiles> {
  bool? status = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 18,
            child: FlutterSwitch(
              toggleSize: 16.0,
              value: status!,
              inactiveColor: kGreyColor,
              activeColor: kRedColor,
              padding: 1.2,
              onToggle: (val) {
                setState(() {
                  status = !status!;
                });
              },
            ),
          ),
          Expanded(
            child: MyText(
              paddingLeft: 15.0,
              text: widget.title,
              size: 12,
              color: kGreyColor,
            ),
          ),
        ],
      ),
    );
  }
}
