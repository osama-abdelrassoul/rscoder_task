import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Future<void> startServer() async {
    var handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler((Request request) async {
      if (request.method == 'POST' && request.url.path == 'request-apk') {
        // Parse processor type from user request
        final payload = await request.readAsString();
        final processorType = Uri.splitQueryString(payload)['processor'] ?? '';

        // Check if APK exists for the given processor
        File apkFile = File('/storage/emulated/0/Download/Clock.apk');
        if (await apkFile.exists()) {
          // Send APK file
          return Response.ok(apkFile.openRead(), headers: {
            'Content-Type': 'application/vnd.android.package-archive',
            'Content-Disposition':
                'attachment; filename=${processorType}_app.apk',
          });
        } else {
          // Return error if APK not found
          return Response.notFound(
              'APK for processor type $processorType not found');
        }
      }
      return Response.notFound('Invalid endpoint');
    });

    // Start the server
    await io.serve(handler, '0.0.0.0', 8080, shared: true);
    print('Admin server running at http://0.0.0.0:8080/');
  }

  @override
  Widget build(BuildContext context) {
    startServer2();
    return Container(
      color: Colors.black,
    );
  }
}

Future<void> startServer2() async {
  final server =
      await HttpServer.bind(InternetAddress.anyIPv4, 8080, shared: true);
  print('Server running on http://0.0.0.0:8080/');

  await for (HttpRequest request in server) {
    if (request.method == 'POST' && request.uri.path == '/request-apk') {
      try {
        // Parse processor type from request
        final content = await utf8.decoder.bind(request).join();
        final queryParams = Uri.splitQueryString(content);
        final processorType = queryParams['processor'] ?? '';

        // Path to the APK file
        final apkFile = File('/storage/emulated/0/Download/Clock.apk');

        if (await apkFile.exists()) {
          // Stream the APK file
          request.response.headers.contentType =
              ContentType('application', 'vnd.android.package-archive');
          request.response.headers.set('Content-Disposition',
              'attachment; filename=${processorType}_app.apk');

          // Stream the file to the response
          await apkFile.openRead().pipe(request.response);
        } else {
          // Respond with a 404 if the file is not found
          request.response.statusCode = HttpStatus.notFound;
          request.response
              .write('APK for processor type $processorType not found');
          await request.response.close();
        }
      } catch (e) {
        // Handle errors
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.write('An error occurred: $e');
        await request.response.close();
      }
    } else {
      // Respond with a 404 for invalid endpoints
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Invalid endpoint');
      await request.response.close();
    }
  }
}
