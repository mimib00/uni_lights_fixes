import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:uni_lights/utils/constants.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    Key? key,
    required this.image,
    required this.status,
    required this.width,
    required this.height,
    this.onTap,
  }) : super(key: key);
  final String? status;
  final String image;
  final double height, width;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Color bgColor = kGreenColor;
    switch (status) {
      case "It's complicated":
        bgColor = kOrangeColor;

        break;
      case "Signle":
        bgColor = kGreenColor;

        break;
      case "In a relationship":
        bgColor = kRedColor;

        break;
      default:
    }
    return GestureDetector(
      onTap: () {
        onTap!();
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: bgColor,
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0.0, 2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
            cardColor: Colors.transparent,
          ),
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.all(6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: image,
                  height: kHeight(context),
                  width: kWidth(context),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
