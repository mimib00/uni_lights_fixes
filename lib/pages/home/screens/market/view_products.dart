import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/models/product.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/market_tile.dart';
import 'package:uni_lights/widgets/my_app_bar.dart';
import 'package:uni_lights/widgets/my_text.dart';

class ViewProducts extends StatefulWidget {
  const ViewProducts({Key? key}) : super(key: key);

  @override
  State<ViewProducts> createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts> {
  Future<List<Products>> fetchMyProducts() async {
    var user = context.read<Authentication>().user!;

    return FirebaseFirestore.instance.collection("products").where("owner", isEqualTo: FirebaseFirestore.instance.collection("users").doc(user.uid)).get().then((snapshot) async {
      List<Products> products = [];
      if (snapshot.docs.isEmpty) return [];
      for (var doc in snapshot.docs) {
        products.add(Products.fromMap(doc.data()));
      }
      return products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const MyAppBar(
        haveBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
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
              text: 'Your selling announcement',
              size: 16,
              weight: FontWeight.w700,
              paddingBottom: 30.0,
              color: kDarkGreyColor,
              fontFamily: 'Roboto Mono',
              align: TextAlign.center,
            ),
            FutureBuilder<List<Products>>(
              future: fetchMyProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
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
                    return const Text('Loading...');
                  case ConnectionState.done:
                    var data = snapshot.data;

                    return ListView.builder(
                        itemCount: data?.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          var product = data![index];
                          var temp = product.createAt!.toDate();
                          var time = "${temp.year}-${temp.month}-${temp.day}, ${temp.hour}:${temp.minute}";
                          return DiscountsTiles(
                            time: time,
                            owner: product.owner,
                            postImages: product.photos,
                            description: product.description,
                            tags: product.tags,
                            price: product.price,
                          );
                        });

                  default:
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
            ),
            // const DiscountsTiles(
            //   bgColor: kOrangeColor,
            //   pic: 'assets/images/boy.png',
            //   name: 'Sam Jones',
            //   time: 'Monday, 17:30',
            //   postImages: [],
            //   description: ' Est voluptate in esse tempor velit ut irure duis sit anim ea officia ea officia ea officia ea officia aliquip.Aute elit minim elit esse laboris...',
            //   tags: [],
            //   price: 17.55,
            // ),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
