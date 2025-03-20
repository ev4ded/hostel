import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 🔹 Initialize Local Notifications
  static Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("🔔 Local Notification Clicked: ${response.payload}");
    });

    print("✅ Local Notifications Initialized");
  }

  static Future<void> configureFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions for iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("❌ Notification permissions denied");
      return;
    }

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    print("✅ Firebase Messaging Configured");
  }

  // 🔥 Listen for FCM Messages (Triggers Local Notification)
  static void listenToFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 New FCM Message Received: ${message.notification?.title}");

      if (message.notification != null) {
        // ✅ Ensure Local Notification is triggered
        showLocalNotification(
          title: message.notification!.title ?? "New Notification",
          body: message.notification!.body ?? "You have a new message",
        );
      } else {
        print("⚠️ No notification payload in FCM message.");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📩 User Clicked Notification: ${message.notification?.title}");
    });
  }

  // 🔔 Show Local Notification
  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
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
      0, // Notification ID
      title,
      body,
      platformDetails,
      payload: "local_notification",
    );
  }

  // 🔥 Send FCM Push Notification (Your Working API)
  static Future<void> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    final String? projectId = dotenv.env['FIREBASE_PROJECT_ID'];
    if (projectId == null) {
      print("❌ FIREBASE_PROJECT_ID is not set in .env file");
      return;
    }

    final String endpoint =
        "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";

    final String accessToken = await getAccessToken();

    if (accessToken.isEmpty) {
      print("❌ Failed to get access token.");
      return;
    }

    Map<String, dynamic> notificationData = {
      "message": {
        "token": fcmToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "type": "complaint_update",
        },
        "android": {
          "priority": "high",
        }
      }
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(notificationData),
      );

      if (response.statusCode == 200) {
        print("✅ Notification sent successfully!");
      } else {
        print("❌ Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }

  // 🔥 Generate Access Token for Firebase Cloud Messaging (Your Working Code)
  static Future<String> getAccessToken() async {
    try {
      final String serviceAccountJson =
          await rootBundle.loadString('assets/service-account.json');
      final Map<String, dynamic> serviceAccount =
          jsonDecode(serviceAccountJson);

      final auth.ServiceAccountCredentials credentials =
          auth.ServiceAccountCredentials.fromJson(serviceAccount);

      final client = await auth.clientViaServiceAccount(
        credentials, ['https://www.googleapis.com/auth/firebase.messaging']
      );

      return client.credentials.accessToken.data;
    } catch (e) {
      print("❌ Error getting access token: $e");
      return "";
    }
  }
}
