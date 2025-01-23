import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

Middleware timeoutMiddleware(Duration timeout) {
  return (Handler handler) {
    return (Request request) async {
      try {
        final responseFuture = Future<Response>.value(handler(request));
        return await responseFuture.timeout(
          timeout,
          onTimeout: () => Response(HttpStatus.requestTimeout,
              body: 'Request timed out. Please try again later.'),
        );
      } catch (e) {
        return Response.internalServerError(body: 'Error: $e');
      }
    };
  };
}

Future<void> startServer() async {
  var handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(timeoutMiddleware(const Duration(minutes: 5)))
      .addHandler((Request request) async {
    if (request.method == 'GET' && request.url.path == 'request-apk') {
      try {
        final processorType = request.url.queryParameters['processor'] ?? '';
        File apkFile =
            File('/storage/emulated/0/Processors-Apks/$processorType.apk');

        if (await apkFile.exists()) {
          final fileBytes = await apkFile.readAsBytes();
          return Response.ok(
            apkFile.openRead(),
            headers: {
              'Content-Type': 'application/vnd.android.package-archive',
              'Content-Disposition':
                  'attachment; filename=${processorType}_app.apk',
              'Content-Length': fileBytes.length.toString()
            },
          );
        } else {
          return Response.notFound(
              'APK for processor type $processorType not found.');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error processing request: $e');
        }
        return Response.internalServerError(
          body: 'Internal Server Error: $e',
        );
      }
    }
    return Response.notFound('Invalid endpoint');
  });
  await io.serve(handler, '0.0.0.0', 8080, shared: true);
}

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    startServer();
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_download_outlined,
              size: 120,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              "APK Server is Running",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "The server is waiting for requests...",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
