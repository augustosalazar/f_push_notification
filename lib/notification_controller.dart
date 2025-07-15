import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationController extends GetxController {
  // observable counter
  final count = 0.obs;

  final subscribeToActivityUpdate = false.obs;
  final subscribeToActivityLocationRequest = false.obs;

  final activityActive = false.obs;

  late FirebaseMessaging _fcm;

  @override
  void onInit() {
    super.onInit();
    _fcm = FirebaseMessaging.instance;

    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        // handle the message when the app is opened from a terminated state
        _handleMessage(message);
      }
    });

    // ask permission on iOS
    _fcm.requestPermission();

    // subscribe all clients to a common topic, e.g. "allUsers"
    _fcm.subscribeToTopic('allUsers');

    // by default unsubscribe to activity and location topics
    //_fcm.unsubscribeFromTopic('activityUpdate');
    //_fcm.unsubscribeFromTopic('activityLocationRequest');

    // foreground handler
    FirebaseMessaging.onMessage.listen(_handleMessage);
    // background & terminated handler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // optionally handle background messages:
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  String get baseUrl {
    return 'http://10.0.2.2:5040';
    //return 'https://fcm-backend.openlab.uninorte.edu.co';
  }

  void _handleMessage(RemoteMessage message) {
    final action = message.data['action'];
    switch (action) {
      case 'updateActivity':
        updateActivity();
        break;
      case 'sendLocation':
        sendLocation();
        break;
      default:
        print('⚠️ unknown action "$action"');
    }
  }

  // top-level background handler

  static Future<void> _firebaseBackgroundHandler(RemoteMessage msg) async {
    // re-init before using any Firebase APIs
    await Firebase.initializeApp();
    final action = msg.data['action'];
    if (action == 'sendLocation') {
      // fire-and-forget: post your location
      final lat = Random().nextDouble() * 180 - 90; // random latitude
      final lon = Random().nextDouble() * 360 - 180; // random longitude
      await http.post(
        Uri.parse('\$baseUrl/location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'latitude': lat, 'longitude': lon}),
      );
    }
    // you can’t call GetX.updateActivity() here – background isolates
  }

  Future<void> registerActivityUpdate() async {
    print('registerActivityUpdate');
    final token = await _fcm.getToken();
    if (token == null) return;
    final newVal = !subscribeToActivityUpdate.value;
    subscribeToActivityUpdate.value = newVal;
    final endpoint = newVal ? 'subscribe' : 'unsubscribe';
    print('token: $token');
    print('newVal: $newVal');
    final resp = await http.post(
      Uri.parse('http://10.0.2.2:5040/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'topic': 'activityUpdate'}),
    );
    print('registerActivityUpdate → ${resp.statusCode} ${resp.body}');
  }

  Future<void> startStopActivity() async {
    final uri = Uri.parse('$baseUrl/send');

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': 'updateActivity',
        'topic': 'activityUpdate',
      }),
    );
    print('http client: ${resp.statusCode} ${resp.body}');
  }

  Future<void> registerActivityLocationRequest() async {
    final token = await _fcm.getToken();
    if (token == null) return;
    final newVal = !subscribeToActivityLocationRequest.value;
    subscribeToActivityLocationRequest.value = newVal;
    final endpoint = newVal ? 'subscribe' : 'unsubscribe';
    final resp = await http.post(
      Uri.parse('http://10.0.2.2:5040/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'topic': 'activityLocationRequest'}),
    );
    print('registerActivityLocationRequest → ${resp.statusCode} ${resp.body}');
  }

  void updateActivity() {
    activityActive.value = !activityActive.value;
  }

  Future<void> requestLocation() async {
    final uri = Uri.parse('$baseUrl/send');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': 'sendLocation',
        'topic': 'activityLocationRequest',
      }),
    );
  }

  Future<void> sendLocation() async {
    final lat = Random().nextDouble() * 180 - 90;
    final lon = Random().nextDouble() * 360 - 180;
    final resp = await http.post(
      Uri.parse('$baseUrl/location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'latitude': lat, 'longitude': lon}),
    );
    print('sendLocation → ${resp.statusCode} ${resp.body}');
  }
}
