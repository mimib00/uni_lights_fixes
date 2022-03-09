// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/core/data_manager.dart';
import 'package:uni_lights/models/product.dart';
import 'package:uni_lights/pages/home/screens/market/post_uploaded.dart';
import 'package:uni_lights/utils/constants.dart';
import 'package:uni_lights/widgets/my_app_bar.dart';
import 'package:uni_lights/widgets/my_button.dart';
import 'package:uni_lights/widgets/my_text.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingUpload extends StatefulWidget {
  const ListingUpload({Key? key}) : super(key: key);

  @override
  State<ListingUpload> createState() => _ListingUploadState();
}

class _ListingUploadState extends State<ListingUpload> {
  String value = '£';
  TextEditingController description = TextEditingController();

  TextEditingController tag = TextEditingController();

  TextEditingController price = TextEditingController();

  List<String> tags = [];

  List<File> images = [];

  bool _validateForm() {
    if (description.text.trim().isEmpty || description.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must provide a description for the product that is at least 10 characters long.'),
          backgroundColor: kRedColor,
        ),
      );
      return false;
    } else if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must provide at least 1 image (max 2).'),
          backgroundColor: kRedColor,
        ),
      );
      return false;
    } else if (price.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must provide a price to your product (if free put 0).'),
          backgroundColor: kRedColor,
        ),
      );
      return false;
    }
    return true;
  }

  void _getImage() async {
    final ImagePicker _picker = ImagePicker();
    var temp = await _picker.pickMultiImage();
    if (temp == null) return;
    for (var i = 0; i < 2; i++) {
      setState(() {
        images.add(File(temp[i].path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: const MyAppBar(
          haveBackButton: true,
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Image.asset(
              'assets/images/upload.jpeg',
              fit: BoxFit.cover,
              width: kWidth(context),
              height: 235,
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/icon-park-outline_attention.png',
                        height: 20,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: GestureDetector(
                    onTap: () => {
                      launch("https://bit.ly/3ACCpfJ"),
                      launch("https://bit.ly/3nYhkXX"),
                      launch("https://bit.ly/3IEeUFJ")
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: kDarkGreyColor,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          TextSpan(
                            text: 'Before completing the form below,\nplease verify the ',
                          ),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: ' !',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: 'Write a short description of your product',
                    size: 12,
                    color: kDarkGreyColor,
                    paddingBottom: 10.0,
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: description,
                      cursorColor: kGreyColor,
                      style: const TextStyle(
                        color: kGreyColor,
                        fontSize: 12,
                      ),
                      maxLength: 200,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        hintText: "Description",
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  MyText(
                    paddingTop: 20.0,
                    text: 'Attach representative pictures (Max 2)',
                    size: 12,
                    color: kDarkGreyColor,
                    paddingBottom: 10.0,
                  ),
                  images.isEmpty
                      ? GestureDetector(
                          onTap: _getImage,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Rectangle 173.png',
                                height: 100,
                                width: kWidth(context),
                                fit: BoxFit.fill,
                              ),
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/images/entypo_upload.png',
                                    height: 50,
                                  ),
                                  MyText(
                                    paddingTop: 10.0,
                                    text: 'Browse files',
                                    size: 11,
                                    color: kRedColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Row(
                          children: images
                              .map<Widget>(
                                (image) => Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(
                                        image,
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            images.removeWhere((element) => element == image);
                                          });
                                        },
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(180),
                                            color: Colors.red,
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                  MyText(
                    paddingTop: 5.0,
                    text: 'Accepted File Types: JPG, PNG',
                    size: 11,
                    color: kGreyColor3,
                    paddingBottom: 10.0,
                  ),
                  MyText(
                    paddingTop: 10.0,
                    text: 'Choose the best tags that describe your product',
                    size: 12,
                    color: kDarkGreyColor,
                    paddingBottom: 10.0,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Card(
                      margin: EdgeInsets.zero,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: tag,
                        cursorColor: kRedColor,
                        style: const TextStyle(
                          color: kGreyColor,
                          fontSize: 12,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          hintText: "Tags",
                          hintStyle: TextStyle(
                            color: kGreyColor,
                            fontSize: 12,
                          ),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        setState(() {
                          tags.add(tag.text.trim());
                        });

                        tag.clear();
                      },
                      child: const CircleAvatar(
                        backgroundColor: kRedColor,
                        foregroundColor: Colors.white,
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  MyText(
                    paddingTop: 10.0,
                    text: tags.map((e) => "#$e").toList().join(" | "),
                    color: kRedColor,
                    size: 11,
                    paddingBottom: 20.0,
                  ),
                  MyText(
                    paddingTop: 10.0,
                    text: 'Write the price of your product',
                    size: 12,
                    color: kDarkGreyColor,
                    paddingBottom: 10.0,
                  ),
                  Row(
                    children: [
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SizedBox(
                          child: TextFormField(
                            controller: price,
                            cursorColor: kRedColor,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: kGreyColor,
                              fontSize: 12,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 15),
                              hintText: "Price",
                              hintStyle: TextStyle(
                                color: kGreyColor,
                                fontSize: 12,
                              ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: kRedColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: PopupMenuButton<String>(
                          initialValue: value,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              children: [
                                MyText(
                                  text: value,
                                  size: 24,
                                  weight: FontWeight.w500,
                                  color: kPrimaryColor,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: kPrimaryColor,
                                  size: 40,
                                )
                              ],
                            ),
                          ),
                          onSelected: (currency) {
                            setState(() {
                              value = currency;
                            });
                          },
                          itemBuilder: (_) {
                            return [
                              const PopupMenuItem(
                                child: Text("£"),
                                value: "£",
                              ),
                            ];
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: SizedBox(
                      width: kWidth(context) * 0.3,
                      child: MyButton(
                        text: 'POST',
                        shadowColor: kRedColor,
                        textSize: 14,
                        fontFamily: 'Roboto Mono',
                        onPressed: () {
                          if (_validateForm()) {
                            var user = context.read<Authentication>().user!;
                            Products product = Products.fromMap(
                              {
                                "owner": FirebaseFirestore.instance.collection("users").doc(user.uid),
                                "description": description.text,
                                "price": double.parse(price.text.trim()),
                                "currency": value,
                                "photos": images,
                                "is_sold": false,
                                "tags": tags,
                                "created_at": Timestamp.now(),
                              },
                            );

                            context.read<DataManager>().addProduct(product).then(
                              (_product) {
                                if (_product.id != null) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => PostUploaded(
                                        product: _product,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          }

                          //
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
