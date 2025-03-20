import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



class NotificationServices {
  NotificationServices._();
  static final NotificationServices instance = NotificationServices._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationInitialized = false;

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    print("✅ Permission status: ${settings.authorizationStatus}");
  }

Future<void> setupFlutterNotifications(BuildContext context) async {
  if (_isFlutterLocalNotificationInitialized) return;

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    "high_importance_channel",
    "High Importance Notifications",
    description: "This channel is used for important notifications.",
    importance: Importance.high,
  );

  await _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await _localNotifications.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        // Convert JSON string back to Map
        Map<String, dynamic> data = jsonDecode(response.payload!);
        RemoteMessage message = RemoteMessage(data: data);
        handleNotificationClick(message, context); // ✅ Handle local notification click
      }
    },
  );

  _isFlutterLocalNotificationInitialized = true;
}



  Future<void> showNotification(RemoteMessage message) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "high_importance_channel",
      "High Importance Notifications",
      channelDescription: "This channel is used for important notifications.",
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: jsonEncode(message.data), // ✅ Store notification data
    );
  }
}


  void handleNotificationClick(RemoteMessage message, BuildContext context) {
    if (message.data["type"] == "complaint_update") {
      String complaintId = message.data["request_id"];
      Navigator.pushNamed(context, "Complaints", arguments: complaintId);
    }
    else if (message.data["type"] == "maintenance_update") {
      String maintenanceId = message.data["request_id"];
      Navigator.pushNamed(context, "Maintenance", arguments: maintenanceId);
  }
   else if (message.data["type"] == "room_change") {
    String requestId = message.data['requestId'];
    Navigator.pushNamed(context, "RoomChange", arguments: requestId);
  }
  }

void listenToFCM() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 Foreground Notification: ${message.notification?.title}");
    showNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("📩 Notification Clicked: ${message.notification?.title}");

    // Instead of context-based navigation, store the last notification
    lastNotification = message; 
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print("📩 Opened from Terminated State: ${message.notification?.title}");
      lastNotification = message; 
    }
  });
}

// Add a variable to store last notification
RemoteMessage? lastNotification;


    }
  

