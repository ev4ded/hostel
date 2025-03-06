import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart' as auth;

class FCMService {
  static Future<void> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    final String projectId =
        dotenv.env['FIREBASE_PROJECT_ID']!; // Replace with your project ID
    final String endpoint =
        "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";

    // Get access token from Firebase Service Account
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
  }

  // 🔥 Generate Access Token from Service Account
  static Future<String> getAccessToken() async {
    try {
      // Load Service Account JSON from assets
      final String serviceAccountJson =
          await rootBundle.loadString('assets/service-account.json');
      final Map<String, dynamic> serviceAccount =
          jsonDecode(serviceAccountJson);

      // Authenticate using Google OAuth2
      final auth.ServiceAccountCredentials credentials =
          auth.ServiceAccountCredentials.fromJson(serviceAccount);

      final auth.AutoRefreshingAuthClient client =
          await auth.clientViaServiceAccount(
        credentials,
        [
          'https://www.googleapis.com/auth/firebase.messaging'
        ], // Required scope
      );

      return client.credentials.accessToken.data; // ✅ Auto-refresh enabled
    } catch (e) {
      print("❌ Error getting access token: $e");
      return "";
    }
  }
}
