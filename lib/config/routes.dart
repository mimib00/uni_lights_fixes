import 'package:flutter/material.dart';
import 'package:uni_lights/pages/auth/login.dart';
import 'package:uni_lights/pages/auth/signup.dart';
import 'package:uni_lights/pages/home/root.dart';

import 'package:uni_lights/pages/home/screens/market/listing_upload.dart';
import 'package:uni_lights/pages/home/screens/market/view_products.dart';
import 'package:uni_lights/pages/home/screens/profile/view_profile.dart';
import 'package:uni_lights/pages/welcome.dart';

Map<String, Widget Function(BuildContext)> routes = {
  "/": (context) => const Welcome(),
  "/login": (context) => const SignIn(),
  "/signup": (context) => SignUp(),
  "/root": (context) => const RootScreen(),
  "/view": (context) => const ViewProfile(),
  "/listing": (context) => const ListingUpload(),
  "/listing/uploaded/view": (context) => const ViewProducts(),
};
