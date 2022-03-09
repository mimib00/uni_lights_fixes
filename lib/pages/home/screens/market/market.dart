// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/core/data_manager.dart';
import 'package:uni_lights/models/product.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/market_tile.dart';
import 'package:uni_lights/widgets/my_text.dart';
import 'package:url_launcher/url_launcher.dart';

class UniMarket extends StatefulWidget {
  const UniMarket({Key? key}) : super(key: key);

  @override
  _UniMarketState createState() => _UniMarketState();
}

class _UniMarketState extends State<UniMarket> {
  var currentIndex = 0;
  List sorts = [
    'Date',
    'Price',
    'Availability',
    'University',
  ];

  @override
  Widget build(BuildContext context) {
    var user = context.watch<Authentication>().user!;
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Stack(
          children: [
            Image.asset(
              'assets/images/IMG_0122.JPG',
              height: 270,
              width: kWidth(context),
              fit: BoxFit.cover,
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 20.0,
              child: Image.asset(
                'assets/images/mdi_sale.png',
                height: 50,
              ),
            ),
          ],
        ),
        MyText(
          text: 'Post and sell your own product!',
          size: 14,
          weight: FontWeight.w500,
          color: kDarkGreyColor,
          paddingTop: 15.0,
          paddingBottom: 15.0,
          align: TextAlign.center,
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed("/listing"),
          child: CircleAvatar(
            backgroundColor: kRedColor,
            foregroundColor: Colors.white,
            child: const Icon(
              Icons.add,
              size: 30,
            ),
          ),
        ),
        MyText(
          text: 'Community Discount and Deals',
          size: 14,
          paddingLeft: 15.0,
          weight: FontWeight.w500,
          color: kDarkGreyColor,
          paddingTop: 30.0,
          paddingBottom: 15.0,
        ),
        const SizedBox(
          height: 30,
        ),
        SizedBox(
          height: 21,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              Container(
                margin: const EdgeInsets.only(left: 15),
                height: 21,
                child: Center(
                  child: MyText(
                    text: 'Sorted by ',
                    size: 12,
                    color: kGreyColor,
                  ),
                ),
              ),
              ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: sorts.length,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) => sortsWidget(
                  '${sorts[index]}',
                  index,
                ),
              ),
            ],
          ),
        ),
        DiscountTile(),
        const SizedBox(
          height: 30,
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: context.read<DataManager>().fetchProducts(currentIndex, university: user.university),
          builder: (_, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/clarity_sad-face-line.png',
                      height: 35,
                    ),
                    Center(
                      child: MyText(
                        paddingTop: 15.0,
                        text: 'There are no post to see',
                        size: 12,
                        color: kGreyColor3,
                      ),
                    ),
                  ],
                );
              case ConnectionState.waiting:
                return Center(child: const Text('Loading...'));
              case ConnectionState.active:
                return ListView.builder(
                  itemCount: snapshot.data?.size,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    if (snapshot.data != null) {
                      Products product = Products.fromMap(snapshot.data!.docs[index].data(), uid: snapshot.data!.docs[index].id);
                      var temp = product.createAt!.toDate();
                      var time = "${temp.year}-${temp.month}-${temp.day}, ${temp.hour}:${temp.minute}";
                      return DiscountsTiles(
                        uid: product.id,
                        owner: product.owner,
                        time: time,
                        postImages: product.photos,
                        description: product.description,
                        tags: product.tags,
                        price: product.price,
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.asset(
                            'assets/images/clarity_sad-face-line.png',
                            height: 35,
                          ),
                          Center(
                            child: MyText(
                              paddingTop: 15.0,
                              text: 'There are no post to see',
                              size: 12,
                              color: kGreyColor3,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                );
              default:
                return Container();
            }
          },
        ),
      ],
    );
  }

  Widget sortsWidget(String sort, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 21,
        decoration: BoxDecoration(
          color: currentIndex == index ? kGreenColor : kPrimaryColor,
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: MyText(
            text: sort,
            size: 12,
            color: currentIndex == index ? kPrimaryColor : kGreyColor,
          ),
        ),
      ),
    );
  }
}

class DiscountTile extends StatelessWidget {
  DiscountTile({Key? key}) : super(key: key);

  final PageController controller = PageController(initialPage: 0);

  Future<List<Map<String, dynamic>>> fetchDiscounts() {
    var ref = FirebaseFirestore.instance.collection("discounts");
    return ref.where("start", isLessThan: Timestamp.now()).orderBy("start", descending: true).get().then((snap) {
      if (snap.docs.isEmpty) return [];
      List<Map<String, dynamic>> list = [];
      for (var i = 0; i < snap.docs.length; i++) {
        var temp = snap.docs[i].data();

        temp.addAll({
          "index": i
        });
        list.add(temp);
      }

      list.removeWhere((element) {
        Timestamp end = element["end"];
        return end.millisecondsSinceEpoch < Timestamp.now().millisecondsSinceEpoch;
      });

      return list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchDiscounts(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/clarity_sad-face-line.png',
                  height: 35,
                ),
                Center(
                  child: MyText(
                    paddingTop: 15.0,
                    text: 'There are no post to see',
                    size: 12,
                    color: kGreyColor3,
                  ),
                ),
              ],
            );
          case ConnectionState.waiting:
            return Center(child: const Text('Loading...'));
          case ConnectionState.done:
            if (!snapshot.hasData) return Container();
            var data = snapshot.data!;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              height: 146,
              child: Swiper(
                loop: false,
                pagination: SwiperPagination(
                  alignment: Alignment.bottomCenter,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      launch(data[index]["url"]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: data[index]["photo"],
                              width: kWidth(context),
                              height: kHeight(context),
                              fit: BoxFit.cover,
                            ),
                            Center(
                              child: Text(
                                data[index]["name"],
                                style: TextStyle(
                                  fontSize: 20,
                                  color: kPrimaryColor,
                                  fontFamily: 'Roboto Mono',
                                  fontWeight: FontWeight.w500,
                                  backgroundColor: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          default:
            return Container();
        }
      },
    );
  }
}
