import 'package:flutter/material.dart';
import 'platform_utils.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Navigator key that needs to be added to main.dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PlatformUtilsImpl {
  static Future<PermissionResult> requestCameraPermission() async {
    // On desktop, we don't need explicit permission requests like on web
    // Camera permissions are typically handled by the OS when the camera is accessed

    try {
      // This is where you could add platform-specific camera checks if needed
      return PermissionResult(granted: true);
    } catch (e) {
      return PermissionResult(
        granted: false,
        errorMessage: 'カメラの権限が確認できません: ${e.toString()}',
      );
    }
  }

  static void reloadApp() {
    // For desktop, we navigate back to the initial route
    if (navigatorKey.currentState != null) {
      // Reset to splash screen
      navigatorKey.currentState!.pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      // Fallback if navigator key is not properly set up
      print(
        'Warning: navigatorKey not set up correctly. Unable to reset app state.',
      );

      // Try to find the current context if available
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  static void downloadFile(String content, String filename) async {
    try {
      // Get downloads directory
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);
        print('ファイルが保存されました: ${file.path}');
      } else {
        // Fallback to documents directory
        final documentsDirectory = await getApplicationDocumentsDirectory();
        final file = File('${documentsDirectory.path}/$filename');
        await file.writeAsString(content);
        print('ファイルが保存されました: ${file.path}');
      }
    } catch (e) {
      print('ファイル保存エラー: $e');
    }
  }
}
