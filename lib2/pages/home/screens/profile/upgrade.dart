import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_app_bar.dart';
import 'package:uni_lights/widgets/my_button.dart';
import 'package:uni_lights/widgets/my_text.dart';

class UpgradeAccount extends StatefulWidget {
  const UpgradeAccount({Key? key}) : super(key: key);

  @override
  State<UpgradeAccount> createState() => _UpgradeAccountState();
}

class _UpgradeAccountState extends State<UpgradeAccount> {
  Package? package;

  getProducts() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings
          .getOffering("subscriptions")!
          .availablePackages
          .isNotEmpty) {
        setState(() {
          package = offerings.current!.monthly!;
        });

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const MyAppBar(
        haveBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              'assets/images/verify pic.png',
              fit: BoxFit.cover,
              width: kWidth(context),
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyText(
                  paddingLeft: 30.0,
                  paddingRight: 30.0,
                  text: 'Do you want to fully enjoy the unilights experience?'
                      .toUpperCase(),
                  size: 16,
                  align: TextAlign.center,
                  weight: FontWeight.w700,
                  fontFamily: 'Roboto Mono',
                  color: kBlackColor,
                ),
                Image.asset(
                  'assets/images/carbon_upgrade.png',
                  height: 60,
                ),
                MyText(
                  paddingLeft: 40.0,
                  paddingRight: 40.0,
                  text: 'With UniLights PRO you get:',
                  size: 16,
                  align: TextAlign.center,
                  weight: FontWeight.w500,
                  fontFamily: 'Roboto',
                  color: kBlackColor,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset(
                          'assets/images/ic_baseline-swipe.png',
                          height: 30,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: MyText(
                        paddingLeft: 15.0,
                        text: 'Unlimited swipes',
                        size: 16,
                        fontFamily: 'Roboto',
                        color: kBlackColor,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset(
                          'assets/images/ant-design_like-filled.png',
                          height: 30,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: MyText(
                        paddingLeft: 15.0,
                        text: 'See who already likes you',
                        size: 16,
                        fontFamily: 'Roboto',
                        color: kBlackColor,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Image.asset(
                          'assets/images/bx_bxs-message-rounded-check.png',
                          height: 30,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: MyText(
                        paddingLeft: 15.0,
                        text: 'Get and send messages to the people you like',
                        size: 16,
                        fontFamily: 'Roboto',
                        color: kBlackColor,
                      ),
                    )
                  ],
                ),
                Container(),
                package == null
                    ? const CircularProgressIndicator.adaptive()
                    : SizedBox(
                        width: kWidth(context) * 0.55,
                        child: MyButton(
                          text: 'UPGRADE NOW',
                          shadowColor: kRedColor,
                          textSize: 14,
                          fontFamily: 'Roboto',
                          onPressed: () async {
                            try {
                              var user = context.read<Authentication>().user!;
                              await Purchases.setEmail(user.email!);
                              await Purchases.setDisplayName(user.name!);
                              await Purchases.setAttributes({"id": user.uid!});
                              await Purchases.purchasePackage(package!);

                              context.read<Authentication>().checkSub();
                            } on PlatformException catch (e) {
                              var errorCode =
                                  PurchasesErrorHelper.getErrorCode(e);
                              if (errorCode !=
                                  PurchasesErrorCode.purchaseCancelledError) {
                                return;
                              }
                            }
                          },
                        ),
                      ),
                Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
