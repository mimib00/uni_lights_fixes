import 'package:flutter/material.dart';
import 'package:uni_lights/utils/constants.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? backButtonOnTap, menuButtonOnTap;
  final bool haveMenuButton;
  final bool haveBackButton;
  final GlobalKey<ScaffoldState>? globalKey;
  final double? height;

  const MyAppBar({
    Key? key,
    this.globalKey,
    this.backButtonOnTap,
    this.menuButtonOnTap,
    this.haveMenuButton = false,
    this.haveBackButton = false,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: kPrimaryColor,
      leading: haveBackButton
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: backButtonOnTap ?? () => Navigator.of(context).pop(),
                  child: Image.asset(
                    'assets/images/arrow.png',
                    height: 20,
                  ),
                ),
              ],
            )
          : const SizedBox(),
      title: Image.asset(
        'assets/images/logo_2.png',
        height: 52,
      ),
      actions: [
        haveMenuButton == true
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      onTap: () => globalKey!.currentState!.openEndDrawer(),
                      child: Image.asset(
                        'assets/images/menu.png',
                        height: 15,
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      ],
    );
  }

  @override
  Size get preferredSize => Size(0, height ?? 65);
}
