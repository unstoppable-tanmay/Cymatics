import 'dart:io';

import 'package:cymatics/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:cymatics/consts/themedata.dart';
import 'package:flutter/services.dart';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late var Entry = false;
  var status;

  checkPermission() async {
    status = await Permission.storage.status;
    if (await Permission.storage.request().isDenied) {
      SystemNavigator.pop();
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      Fluttertoast.showToast(
        msg: "This is Center Short Toast",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black45,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      openAppSettings();
    } else if (await Permission.storage.request().isGranted) {
      print("Go to App");
      Entry = true;
    }
  }

  @override
  void initState() {
    checkPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cymatics',
        theme: themeData,
        home: AnimatedSplashScreen(
            centered: true,
            duration: 500,
            splash: Image.asset(
              "./assets/images/loader.gif",
              width: 180,
              fit: BoxFit.cover,
            ),
            nextScreen: Home(),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.fade,
            backgroundColor: Colors.white));
  }
}
// flutter run --no-sound-null-safety
