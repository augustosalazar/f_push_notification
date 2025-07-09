import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'notification_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext _) {
    final NotificationController nc = Get.find();
    return Scaffold(
      appBar: AppBar(title: Text('Ping Counter')),
      body: Center(
        child: Obx(
          () => Text(
            'Counter: ${nc.count.value}',
            style: TextStyle(fontSize: 32),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: nc.sendPingHttp,
        child: Icon(Icons.send),
      ),
    );
  }
}
