import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:rscoder_task/admin.dart';
import 'package:rscoder_task/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String deviceId = await getDeviceId();
  runApp(MyApp(deviceId: deviceId));
}

Future<String> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } else {
    return "";
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.deviceId});
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    print("Device ID: $deviceId");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: deviceId == "UP1A.231005.007"
              ? const AdminScreen()
              : const UserScreen()),
      theme: ThemeData.dark(),
    );
  }
}
