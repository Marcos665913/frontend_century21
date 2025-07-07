// lib/core/services/firebase_messaging_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Notificación en segundo plano recibida: ${message.messageId}");
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String?> getToken() async {
    try {
      final fcmToken = await _firebaseMessaging.getToken();
      print("====================================");
      print("FCM Token del dispositivo: $fcmToken");
      print("====================================");
      return fcmToken;
    } catch (e) {
      print("Error al obtener el token FCM: $e");
      return null;
    }
  }
}
