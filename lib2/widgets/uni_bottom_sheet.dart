import 'package:flutter/material.dart';

class UniBottomSheet extends StatelessWidget {
  /// A custom buttom sheet made for labels design language.

  const UniBottomSheet({
    Key? key,
    required this.title,
    this.content,
    this.contentPadding,
    this.height,
  }) : super(key: key);

  final String title;
  final Widget? content;
  final EdgeInsets? contentPadding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    Widget header = Column(
      children: [
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(45)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                  color: Theme.of(context).textTheme.headline6!.color!.withOpacity(0.7),
                ),
          ),
        ),
        const Divider(thickness: 2),
      ],
    );

    return Container(
      height: height ?? MediaQuery.of(context).size.height / 2,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          header,
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: contentPadding ?? EdgeInsets.zero,
                  child: content,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
