import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getDownloadPath() async {
  final directory = await getExternalStorageDirectory();
  return "${directory!.path}/downloaded_apk.apk";
}

Future<void> downloadApk(String url, String savePath) async {
  Dio dio = Dio();
  try {
    await dio.download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          print(
              "Download Progress: ${(received / total * 100).toStringAsFixed(0)}%");
        }
      },
    );
    print("Download completed successfully!");
  } catch (e) {
    print("Download failed: $e");
  }
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  double progress = 0.0;

  Future<void> requestAndDownload() async {
    String adminIp = "192.168.8.5"; // Replace with admin IP
    await downloadApk("http://$adminIp:8080/request-apk", adminIp);
    setState(() {
      progress = 100.0; // Update UI when done
    });
  }

  void getProcessorType() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (kDebugMode) {
        print('CPU architecture: ${androidInfo.supportedAbis}');
      }
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      if (kDebugMode) {
        print('CPU architecture: ${iosInfo.utsname.machine}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: requestAndDownload,
          child: Text("Request APK"),
        ),
        SizedBox(height: 20),
        LinearProgressIndicator(value: progress / 100),
        Text("${progress.toStringAsFixed(0)}%"),
      ],
    );
  }

  Future<String> downloadData() async {
    String url = "https://example.com/your_apk_file.apk";
    String savePath = await getDownloadPath();
    await downloadApk(url, savePath);
    return Future.value("Data download successfully"); // return your response
  }
}
