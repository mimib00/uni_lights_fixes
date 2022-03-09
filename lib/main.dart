import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:uni_lights/config/routes.dart';
import 'package:uni_lights/core/authentication.dart';
import 'package:uni_lights/core/data_manager.dart';
import 'package:uni_lights/core/match_making.dart';
import 'package:uni_lights/utils/constants.dart';

const AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
  "high_importance_channel",
  "High Importance Notification",
  description: "This channel is used for important notifications",
  importance: Importance.high,
  playSound: true,
);

Future<void> firebaseMessagingBackgoundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signOut();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgoundHandler);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(androidNotificationChannel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

  if (Platform.isIOS) {
    await Purchases.setup("appl_JNnfWDqjgYOFrOTBxPhDnEeofcz");
  } else {
    await Purchases.setup("goog_auKOGwwRIdbYuUdLHNBCiMnMbjh");
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Authentication(),
        ),
        ChangeNotifierProvider(
          create: (_) => MatchMaker(),
        ),
        ChangeNotifierProvider(
          create: (_) => DataManager(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    Geofire.initialize("dates");
    context.read<Authentication>().hasService();
    context.read<Authentication>().hasPermission();

    FirebaseAuth.instance.authStateChanges().listen(
      (User? user) {
        if (user != null) {
          context.read<Authentication>().getUserData().then((value) => _navigatorKey.currentState!.pushNamedAndRemoveUntil('/root', (route) => false));
        } else {
          _navigatorKey.currentState!.pushNamedAndRemoveUntil('/', (route) => false);
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;

      if (notification != null && androidNotification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              androidNotificationChannel.id,
              androidNotificationChannel.name,
              channelDescription: androidNotificationChannel.description,
              color: Colors.blue,
              playSound: true,
              icon: "@mipmap/ic_launcher",
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = message.notification?.android;

      if (notification != null && androidNotification != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(notification.title!),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.body!)
                ],
              ),
            ),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni Light',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: kPrimaryColor,
        ),
        scaffoldBackgroundColor: kPrimaryColor,
        fontFamily: 'Poppins',
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/' : '/root',
      routes: routes,
    );
  }
}
