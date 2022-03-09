import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_button.dart';
import 'package:uni_lights/widgets/my_text.dart';

class NoLikes extends StatefulWidget {
  const NoLikes({Key? key}) : super(key: key);

  @override
  State<NoLikes> createState() => _NoLikesState();
}

class _NoLikesState extends State<NoLikes> {
  Package? package;
  getProducts() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.getOffering("subscriptions")!.availablePackages.isNotEmpty) {
        package = offerings.current!.monthly!;
      }
    } on PlatformException {
      // optional error handling
    }
  }

  @override
  void initState() {
    getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Rectangle 96.png'),
          fit: BoxFit.fill,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyText(
            align: TextAlign.center,
            text: 'My Likes'.toUpperCase(),
            size: 16,
            fontFamily: 'Roboto Mono',
            weight: FontWeight.w700,
            color: kBlackColor,
          ),
          Column(
            children: [
              Image.asset(
                'assets/images/ic_sharp-heart-broken.png',
                height: 60,
              ),
              MyText(
                align: TextAlign.center,
                paddingTop: 20.0,
                paddingBottom: 20.0,
                text: 'No likes yet'.toUpperCase(),
                size: 16,
                fontFamily: 'Roboto Mono',
                weight: FontWeight.w700,
                color: kBlackColor,
                lineHeight: 1.5,
              ),
              MyText(
                align: TextAlign.center,
                paddingTop: 20.0,
                paddingBottom: 50.0,
                text: 'Upgrade to UNILIGHTS PRO\nTO SEE WHO ALREADY LIKES YOU!'.toUpperCase(),
                size: 16,
                fontFamily: 'Roboto Mono',
                weight: FontWeight.w700,
                color: kBlackColor,
                lineHeight: 1.5,
              ),
              Center(
                child: SizedBox(
                  width: kWidth(context) * 0.5,
                  child: MyButton(
                    text: 'UPGRADE NOW',
                    fontFamily: 'Roboto',
                    weight: FontWeight.w500,
                    shadowColor: kOrangeColor,
                    onPressed: () async {
                      try {
                        var user = context.read<Authentication>().user!;
                        await Purchases.setEmail(user.email!);
                        await Purchases.setDisplayName(user.name!);
                        await Purchases.setAttributes({
                          "id": user.uid!
                        });
                        await Purchases.purchasePackage(package!);

                        context.read<Authentication>().checkSub();
                      } on PlatformException catch (e) {
                        var errorCode = PurchasesErrorHelper.getErrorCode(e);
                        if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
                          return;
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Container(),
          Container(),
        ],
      ),
    );
  }
}
