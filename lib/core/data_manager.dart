import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/models/post.dart';
import 'package:uni_lights/models/product.dart';
import 'package:uni_lights/models/user.dart';

class DataManager extends ChangeNotifier {
  /// Hold a [CollectionReference] to the posts collention in firestore.
  final CollectionReference<Map<String, dynamic>> _posts = FirebaseFirestore.instance.collection('posts');

  final CollectionReference<Map<String, dynamic>> _products = FirebaseFirestore.instance.collection('products');

  final Reference _storage = FirebaseStorage.instance.ref();

  Stream<QuerySnapshot<Map<String, dynamic>>> posts(Users user) {
    if (_currentIndex == 0) {
      return _posts.orderBy('created_at', descending: true).snapshots();
    } else {
      return _posts.where("university", isEqualTo: user.university).orderBy('created_at', descending: true).snapshots();
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> comments(String postId) => _posts.doc(postId).snapshots();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  int _swipes = 10;
  int get swipes => _swipes;

  int index = 0;

  setIndex(int i) {
    index = i;
    notifyListeners();
  }

  toggleOrder(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void addPost(Users user, Post post) async {
    post.ownerId = user.uid;
    if (post.attachment.isNotEmpty) {
      var path = "posts/${user.uid}/${DateTime.now().microsecondsSinceEpoch}";
      TaskSnapshot snapshot = await _storage.child(path).putFile(File(post.attachment));
      if (snapshot.state == TaskState.success) {
        var imageUrl = await snapshot.ref.getDownloadURL();
        post.attachment = imageUrl;
      }
    }
    _posts.add(post.toMap()['data']);
  }

  void deletePost(String uid) {
    _posts.doc(uid).delete();
  }

  void deleteProduct(String uid) {
    _products.doc(uid).delete();
  }

  Future<Products> addProduct(Products product) async {
    List<String> images = [];
    var data = product.toMap()["data"];
    var user = data["owner"] as DocumentReference;
    var owner = await user.get();

    for (var image in data["photos"]) {
      var path = "/products/${owner.id}/${DateTime.now().microsecondsSinceEpoch}";
      TaskSnapshot snapshot = await _storage.child(path).putFile(image);
      if (snapshot.state == TaskState.success) {
        var imageUrl = await snapshot.ref.getDownloadURL();
        images.add(imageUrl);
      } else {
        return product;
      }
    }
    product.photos = images;
    var doc = await _products.add(product.toMap()["data"]);
    product.id = doc.id;

    return product;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchProducts(int filter, {String? university}) {
    switch (filter) {
      case 0:
        return _products.orderBy("created_at", descending: true).snapshots();

      case 1:
        return _products.orderBy("price").snapshots();

      case 2:
        return _products.where("is_sold", isEqualTo: false).orderBy("created_at").snapshots();

      case 3:
        return _products.where("university", arrayContains: university).orderBy("created_at").snapshots();

      default:
        return _products.orderBy("created_at").snapshots();
    }
  }

  _restLimits(SharedPreferences prefs) async {
    await prefs.setInt("date", DateTime.now().day);
    await prefs.setInt("swipes", 10);
  }

  Future<String?> swipe() async {
    return await SharedPreferences.getInstance().then((prefs) {
      if (swipes > 0) {
        prefs.setInt("swipes", _swipes - 1);
      } else {
        return "limit";
      }
      notifyListeners();
      return null;
    });
  }

  checkLimits(BuildContext context) async {
    SharedPreferences.getInstance().then((prefs) {
      var user = context.read<Authentication>().user;
      var date = prefs.getInt("date");

      // check if they don't exist
      if (date == null) {
        _restLimits(prefs);
      }

      if (user == null) return;

      // check if user is premium then skip
      if (user.isPremium) prefs.setInt("swipes", 9999999);

      // reset every day
      if (date != DateTime.now().day) {
        _restLimits(prefs);
      }

      _swipes = prefs.getInt("swipes") ?? 0;
    });
  }
}
