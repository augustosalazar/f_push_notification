import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationController extends GetxController {
  // observable counter
  final count = 0.obs;

  late FirebaseMessaging _fcm;

  @override
  void onInit() {
    super.onInit();
    _fcm = FirebaseMessaging.instance;

    // ask permission on iOS
    _fcm.requestPermission();

    // subscribe all clients to a common topic, e.g. "allUsers"
    _fcm.subscribeToTopic('allUsers');

    // foreground handler
    FirebaseMessaging.onMessage.listen(_handleMessage);
    // background & terminated handler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // optionally handle background messages:
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  // called in all cases when a message arrives
  void _handleMessage(RemoteMessage message) {
    // you can inspect message.data or message.notification
    count.value++;
  }

  // top-level background handler
  static Future<void> _firebaseBackgroundHandler(RemoteMessage msg) async {
    // IMPORTANT: initialize Firebase in here too if needed
    // Firebase.initializeApp();
    // You cannot use GetX here, so you'd rely on platform notifications only.
  }

  Future<void> sendPingHttp() async {
    final uri = Uri.parse('https://fcm-backend.openlab.uninorte.edu.co/send');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': 'increment'}),
    );
    print('http client: ${resp.statusCode} ${resp.body}');
  }
}
