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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => Text(
              'Activity: ${nc.activityActive.value ? "Active" : "Inactive"}',
              style: TextStyle(fontSize: 32),
            ),
          ),
          SizedBox(height: 20),
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async => await nc.registerActivityUpdate(),
                      child: nc.subscribeToActivityUpdate.value
                          ? Text('Unsubscribe Activity Update')
                          : Text('Subscribe Activity Update'),
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: nc.registerActivityLocationRequest,
                      child: nc.subscribeToActivityLocationRequest.value
                          ? Text('Unsubscribe Activity Location Req.')
                          : Text('Subscribe Activity Location Req.'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: nc.startStopActivity,
                  child: nc.activityActive.value
                      ? Text('Stop Activity')
                      : Text('Start Activity'),
                ),

                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: nc.requestLocation,
                  child: Text('Request Location'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
