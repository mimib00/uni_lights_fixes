import 'package:cloud_firestore/cloud_firestore.dart';

class Products {
  /// Product ID.
  String? id;

  /// Product owner id.
  DocumentReference<Map<String, dynamic>>? owner;

  /// Product description.
  String? description;

  /// Product Hashtags.
  List tags;

  /// Product creation date.
  Timestamp? createAt;

  /// Product price.
  double price;

  /// Product currency.
  String? currency;

  /// Product photos.
  List photos;

  /// Product status.
  bool isSold;

  Products({
    this.id,
    required this.owner,
    required this.description,
    required this.price,
    required this.photos,
    required this.currency,
    this.isSold = false,
    this.tags = const [],
    this.createAt,
  });

  factory Products.fromMap(Map<String, dynamic> data, {String? uid, Map<String, dynamic>? owner}) => Products(
        id: uid,
        description: data["description"],
        price: data["price"],
        photos: data["photos"],
        currency: data["currency"],
        owner: data["owner"],
        isSold: data["is_sold"],
        tags: data["tags"],
        createAt: data["created_at"],
      );
  Map<String, dynamic> toMap() => {
        "id": id,
        "data": {
          "owner": owner,
          "description": description,
          "price": price,
          "currency": currency,
          "photos": photos,
          "is_sold": isSold,
          "tags": tags,
          "created_at": createAt ?? Timestamp.now(),
        }
      };
}
