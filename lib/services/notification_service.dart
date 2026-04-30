import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("--- Handling a background message: ${message.messageId}");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
  }
}
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> initNotifications(String studentRollId) async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final String? token = await _messaging.getToken();
    if (token != null) {
      if (kDebugMode) {
        print("--- My FCM Token: $token");
      }
      await saveTokenToFirestore(studentRollId, token);
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("--- Got a message while in the foreground! ---");
        print("Title: ${message.notification?.title}");
        print("Body: ${message.notification?.body}");
      }
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  Future<void> saveTokenToFirestore(String rollId, String token) async {
    try {
      final query = await _firestore
          .collection('students')
          .where('roll', isEqualTo: rollId)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        await _firestore.collection('students').doc(docId).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving token: $e");
      }
    }
  }
}