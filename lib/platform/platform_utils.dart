import 'dart:async';
import 'package:flutter/foundation.dart';
import 'platform_utils_web.dart'
    if (dart.library.io) 'platform_utils_desktop.dart';

class PermissionResult {
  final bool granted;
  final String? errorMessage;

  PermissionResult({required this.granted, this.errorMessage});
}

abstract class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => !kIsWeb && (isWindows || isMacOS || isLinux);
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;
  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  // This will be implemented in platform-specific files
  static Future<PermissionResult> requestCameraPermission() async {
    return PlatformUtilsImpl.requestCameraPermission();
  }

  // Reload application - platform specific implementation
  static void reloadApp() {
    PlatformUtilsImpl.reloadApp();
  }

  // Download file - platform specific implementation
  static void downloadFile(String content, String filename) {
    PlatformUtilsImpl.downloadFile(content, filename);
  }
}
