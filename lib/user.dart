import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  if (Platform.isAndroid) {
    if (await _isAndroid11OrAbove()) {
      if (!await Permission.manageExternalStorage.isGranted) {
        await Permission.manageExternalStorage.request();
      }
    } else {
      if (!await Permission.storage.isGranted) {
        await Permission.storage.request();
      }
    }
  }
}

ValueNotifier<double> progress = ValueNotifier(0.0);

Future<bool> _isAndroid11OrAbove() async {
  return (await Permission.manageExternalStorage.isGranted) ||
      Platform.version.contains('API 30');
}

Future<String> getProcessorType() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.supportedAbis[0];
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.utsname.machine;
  }
  return "can't find processor type";
}

Future<void> downloadApk(String url, String savePath) async {
  final dio = Dio();
  dio.options.receiveTimeout = const Duration(minutes: 5);
  dio.options.connectTimeout = const Duration(minutes: 5);
  dio.options.responseDecoder = (responseBytes, options, responseBody) {
    return utf8.decode(responseBytes, allowMalformed: true);
  };
  final processorType = await getProcessorType();
  final response = await dio.get(
    url,
    data: {'processor': processorType},
    onReceiveProgress: (received, total) {
      if (total != -1) {
        progress.value = received / total * 100;
      }
    },
    options: Options(responseType: ResponseType.bytes),
  );

  await requestStoragePermission();

  final file = File(savePath);
  await file.writeAsBytes(response.data);
  final result = await OpenFile.open(file.path);

  if (result.type == ResultType.done) {
    final opendfile = File(file.path);
    if (await opendfile.exists()) {
      await Future.delayed(const Duration(minutes: 5));
      await opendfile.delete();
    }
  } else {
    if (kDebugMode) {
      print('File not opened, skipping deletion.');
    }
  }
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Future<void> requestAndDownload() async {
    String adminIp = "192.168.137.199"; // Replace with admin IP
    await downloadApk("http://$adminIp:8080/request-apk",
        "/storage/emulated/0/Download/test1.png");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: progress,
          builder: (BuildContext context, double value, Widget? child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "APK Downloader",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE3F2FD),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: requestAndDownload,
                    icon: const Icon(
                      Icons.download,
                      size: 20,
                      color: Color(0xFFE3F2FD),
                    ),
                    label: const Text(
                      "Request APK",
                      style: TextStyle(
                        color: Color(0xFFE3F2FD),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: const Color(0x33FFFFFF),
                      shadowColor: Colors.transparent,
                      side: const BorderSide(
                        color: Color(0x99FFFFFF),
                        width: 1.5,
                      ),
                      elevation: 3,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      minHeight: 12,
                      backgroundColor: const Color(0x33FFFFFF),
                      color: const Color(0xFFE3F2FD),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Downloading... ${value.toInt()}%",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xB3FFFFFF),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
