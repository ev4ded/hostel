import 'package:minipro/warden/services/FCMservices.dart';

void sendComplaintUpdate(String token) {
  
  FCMService.sendNotification(
    fcmToken: token,
    title: "title",
    body: "Your complaint has been resolved.",
  );
}
