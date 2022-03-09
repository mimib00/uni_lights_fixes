// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:location/location.dart';
import 'package:uni_lights/models/user.dart';
import 'package:uni_lights/utils/helper.dart';

class MatchMaker extends ChangeNotifier {
  Stream<dynamic>? fetchNearByUsers(LocationData locationData, double radius) => Geofire.queryAtLocation(locationData.latitude!, locationData.longitude!, radius);

  List<Users> _users = [];

  List<Users> get users => _users;

  List<Users> mates = [];
  List<Users> dates = [];

  setMates(List<Users> user) {
    mates.clear();
    mates.addAll(user);
  }

  setDates(List<Users> user) {
    dates.clear();
    dates.addAll(user);
  }

  /// Query users data only if you havn't liked them before.
  void queryUsers(String uid, Users user) async {
    var mates = await FirebaseFirestore.instance.collection("mates").doc(getId(uid, user.uid!)).get();
    var dates = await FirebaseFirestore.instance.collection("dates").doc(getId(uid, user.uid!)).get();
    if (dates.data()?[user.uid!] == true || mates.data()?[user.uid!] == true) {
      return;
    }
    FirebaseFirestore.instance.collection("users").doc(uid).get().then((doc) {
      var data = doc.data()!;

      if (data["gender"] == user.intrestedIn && data["intrested_in"] == user.gender || data["intrested_in"] == "Both" && user.intrestedIn == "Both") {
        _users.add(Users.fromSnapshot(doc.data()!, id: doc.id));
        notifyListeners();
      }
    });
  }

  Future<bool> dateExist(String id, bool isDate) async {
    CollectionReference ref = isDate ? FirebaseFirestore.instance.collection("dates") : FirebaseFirestore.instance.collection("mates");

    var res = await ref.doc(id).get();
    if (res.exists) {
      return true;
    }
    return false;
  }

  /// This function matches you with other dates/mates.
  ///
  /// and by matching mean liking them and if both users like each other they get a notification
  void match(String uid, String dateId, bool isDate) {
    var id = getId(uid, dateId);
    dateExist(id, isDate).then((value) {
      CollectionReference ref = isDate ? FirebaseFirestore.instance.collection("dates") : FirebaseFirestore.instance.collection("mates");
      Map<String, dynamic> data = {
        "users": [
          uid,
          dateId
        ],
        uid: true,
        dateId: false,
      };
      if (value) {
        ref.doc(id).update(
          {
            uid: true
          },
        );
      } else {
        ref.doc(id).set(data);
      }
    });
    // _users.removeWhere((element) => element.uid == dateId);

    notifyListeners();
  }

  void unmatch(String uid, String dateId, bool isDate) {
    var id = getId(uid, dateId);
    CollectionReference ref = isDate ? FirebaseFirestore.instance.collection("dates") : FirebaseFirestore.instance.collection("mates");
    ref.doc(id).update({
      uid: false
    });
    notifyListeners();
  }

  /// This function queries the [mates], and [dates] collections in firestore and fetch the ones that you already have a match
  ///
  /// and get the user info of the dates/mates.
  Future<List<Users>> fetchMatches(String uid, bool isDate) async {
    if (isDate) {
      var ref = FirebaseFirestore.instance.collection("dates");
      return await ref.where("users", arrayContains: uid).get().then((QuerySnapshot<Map<String, dynamic>> snap) async {
        if (snap.docs.isNotEmpty) {
          List users = List.from(snap.docs.first.data()["users"]);
          users.removeWhere((e) => e == uid);
          var query = await ref.where("users", arrayContains: uid).where(uid, isEqualTo: true).where(users.first, isEqualTo: true).get();
          List<Users> dates = [];
          for (var doc in query.docs) {
            List usersList = doc.data()["users"];
            usersList.removeWhere((e) => e == uid);
            var userRef = await FirebaseFirestore.instance.collection("users").doc(usersList.first).get();

            dates.add(Users.fromMap(userRef.data()!, id: userRef.id));
          }
          return dates;
        } else {
          return [];
        }
      });
    } else {
      var ref = FirebaseFirestore.instance.collection("mates");
      // get the mates info.
      return await ref.where("users", arrayContains: uid).get().then((QuerySnapshot<Map<String, dynamic>> snap) async {
        if (snap.docs.isNotEmpty) {
          List users = List.from(snap.docs.first.data()["users"]);
          users.removeWhere((e) => e == uid);
          var query = await ref.where("users", arrayContains: uid).where(uid, isEqualTo: true).where(users.first, isEqualTo: true).get();
          List<Users> mates = [];
          for (var doc in query.docs) {
            List usersList = doc.data()["users"];
            usersList.removeWhere((e) => e == uid);
            var userRef = await FirebaseFirestore.instance.collection("users").doc(usersList.first).get();

            mates.add(Users.fromMap(userRef.data()!, id: userRef.id));
          }
          return mates;
        } else {
          return [];
        }
      });
    }
  }
}
