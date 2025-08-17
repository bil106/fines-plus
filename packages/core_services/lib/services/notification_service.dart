import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static Future<void> init(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

   
    await FirebaseMessaging.instance.requestPermission();
  }

  static Future<void> saveToken(String carNumber) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('cars')
          .doc(carNumber)
          .set({'fcmToken': token}, SetOptions(merge: true));
    }
  }

  static Future<void> showLocalNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin, RemoteMessage message) async {
    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("🔔 Background message: ${message.messageId}");
  }
}
