import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rscoder_task/admin.dart';
import 'package:rscoder_task/user.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

Future<void> startServer() async {
  var handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler((Request request) async {
    if (request.url.path == 'send-apk') {
      String processorType = request.url.queryParameters['processor'] ?? '';
      File apkFile = File('apks/$processorType.apk');
      if (await apkFile.exists()) {
        return Response.ok(apkFile.openRead(), headers: {
          'Content-Type': 'application/vnd.android.package-archive',
        });
      } else {
        return Response.notFound('APK not found');
      }
    }
    return Response.notFound('Invalid endpoint');
  });

  // Enable `shared` flag
  await io.serve(handler, '0.0.0.0', 8080, shared: true);
}

void main() async {
  await startServer();
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
    print(deviceId);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: deviceId == "RP1A.200720.011"
              ? const AdminScreen()
              : const UserScreen()),
      theme: ThemeData.dark(),
    );
  }
}
