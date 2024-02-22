import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uber_driver_app/main.dart';
import 'package:uber_driver_app/static/config.dart';

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("onMessage: $message");
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("onLaunch / onResume: $message");
    });
  }

  Future<String?> getToken() async {
    try {
      String? token = await firebaseMessaging.getToken();
      if (token != null) {
        log("This is token :: $token");
        driversRef.child(currentfirebaseUser!.uid).child("token").set(token);
        firebaseMessaging.subscribeToTopic("alldrivers");
        firebaseMessaging.subscribeToTopic("allusers");
      } else {
        log("Token is null");
      }
      return token;
    } catch (e) {
      log("Error getting token: $e");
      return null;
    }
  }
}
