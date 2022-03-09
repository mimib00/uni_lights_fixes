import 'package:flutter/material.dart';
import 'package:uni_lights/models/product.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/market_tile.dart';
import 'package:uni_lights/widgets/my_app_bar.dart';
import 'package:uni_lights/widgets/my_button.dart';
import 'package:uni_lights/widgets/my_text.dart';

class PostUploaded extends StatelessWidget {
  final Products product;
  const PostUploaded({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const MyAppBar(
        haveBackButton: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Image.asset(
            'assets/images/upload.png',
            fit: BoxFit.cover,
            width: kWidth(context),
            height: 235,
          ),
          const SizedBox(
            height: 15,
          ),
          MyText(
            text: 'Your selling announcement has been posted! ',
            size: 14,
            paddingBottom: 30.0,
            color: kDarkGreyColor,
            align: TextAlign.center,
          ),
          DiscountsTiles(
            uid: product.id,
            owner: product.owner,
            time: product.createAt?.toDate().day.toString(),
            postImages: product.photos,
            description: product.description,
            tags: product.tags,
            price: product.price,
          ),
          MyText(
            text: 'Do you want to view all your\nannouncements?',
            size: 14,
            paddingBottom: 30.0,
            color: kDarkGreyColor,
            align: TextAlign.center,
          ),
          Center(
            child: SizedBox(
              width: kWidth(context) * 0.45,
              child: MyButton(
                text: 'VIEW MY PRODUCTS',
                shadowColor: kRedColor,
                textSize: 14,
                fontFamily: 'Roboto Mono',
                onPressed: () => Navigator.of(context).pushNamed("/listing/uploaded/view"),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
