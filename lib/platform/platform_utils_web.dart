import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'platform_utils.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PlatformUtilsImpl {
  static Future<PermissionResult> requestCameraPermission() async {
    try {
      final userMedia = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': true,
        'audio': false,
      });

      if (userMedia != null) {
        userMedia.getTracks().forEach((track) => track.stop());
        return PermissionResult(granted: true);
      }
      return PermissionResult(granted: false, errorMessage: 'カメラへのアクセスができません');
    } catch (e) {
      return PermissionResult(granted: false, errorMessage: e.toString());
    }
  }

  static void reloadApp() {
    html.window.location.reload();
  }

  static void downloadFile(String content, String filename) {
    try {
      // Create blob
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);

      // Create download URL
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create and trigger download
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', filename)
            ..click();

      // Cleanup
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('ファイルダウンロードエラー: $e');
    }
  }
}
