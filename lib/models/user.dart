import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  /// Users's id
  String? uid;

  /// Users's premium status.
  bool isPremium;

  /// Users's full name.
  String? name;

  /// Users's email.
  String? email;

  /// Users's birthday.
  Timestamp? birthDay;

  /// Users's course that he takes.
  String? courseName;

  /// Goes from 0-4.
  String? year;

  /// Users's status.
  String? light;

  /// Users's gender.
  String? gender;

  /// Users's sexual oriantation.
  String? intrestedIn;

  /// Users's Profile picture.
  String? photoURL;

  /// Users's University that he goes to.
  String? university;

  /// Users's Quote.
  String? quote;

  /// Users's Bio.
  String? bio;

  /// List of Users's tags.
  List? tags;

  /// List of Users's photos URL.
  List? photos;

  /// List of Users's posts [ID].
  List? posts;

  /// List of Users's products.
  List<String>? products;

  /// Map of Users's settings.
  Map<String, dynamic>? settings;

  /// List of Users's bloced Userss.
  List? blocked;

  String? token;

  Users({
    this.isPremium = false,
    this.uid,
    this.name,
    this.email,
    this.birthDay,
    this.courseName,
    this.year,
    this.light,
    this.gender,
    this.intrestedIn,
    this.photoURL,
    this.university,
    this.bio,
    this.quote,
    this.tags,
    this.photos,
    this.posts,
    this.products,
    this.settings,
    this.blocked,
    this.token,
  });

  factory Users.fromSnapshot(Map<String, dynamic> data, {String? id}) => Users(
        uid: id,
        name: data["name"],
        email: data["email"],
        birthDay: data["birth_day"],
        university: data["university"],
        courseName: data["course_name"],
        year: data["year"],
        light: data["light"],
        gender: data["gender"],
        intrestedIn: data["intrested_in"],
        photoURL: data["photo_url"],
        bio: data["bio"],
        quote: data["quote"],
        tags: data["tags"],
        photos: data["photos"],
        posts: data["posts"],
        products: data["products"],
        settings: data["settings"],
        blocked: data["blocked"],
        token: data["token"],
      );

  factory Users.fromMap(Map<String, dynamic> data, {String? id}) => Users(
        uid: id,
        name: data["name"],
        email: data["email"],
        birthDay: data["birth_day"],
        university: data["university"],
        courseName: data["course_name"],
        year: data["year"],
        light: data["light"],
        gender: data["gender"],
        intrestedIn: data["intrested_in"],
        photoURL: data["photo_url"],
        bio: data["bio"],
        quote: data["quote"],
        tags: data["tags"],
        photos: data["photos"],
        posts: data["posts"],
        products: data["products"],
        settings: data["settings"],
        blocked: data["blocked"],
        isPremium: data["is_premium"] ?? false,
        token: data["token"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "email": email,
        "birth_day": birthDay,
        "university": university,
        "course_name": courseName,
        "year": year,
        "light": light,
        "gender": gender,
        "intrested_in": intrestedIn,
        "photo_url": photoURL,
        "bio": bio,
        "quote": quote,
        "tags": tags,
        "photos": photos,
        "posts": posts,
        "products": products,
        "settings": settings,
        "blocked": blocked,
        "token": token,
      };
}
