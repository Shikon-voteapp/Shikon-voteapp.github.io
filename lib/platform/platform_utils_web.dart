import 'package:flutter/material.dart';
// TODO: Migrate to package:web when stable
// ignore: deprecated_member_use
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
      html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();

      // Cleanup
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('ファイルダウンロードエラー: $e');
    }
  }

  static void downloadBytes(
    List<int> bytes,
    String filename, {
    String mimeType = 'application/octet-stream',
  }) {
    try {
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('ファイルダウンロードエラー: $e');
    }
  }

  static void openUrl(String url) {
    try {
      html.window.open(url, '_blank');
    } catch (e) {
      print('URLを開くエラー: $e');
    }
  }

  static Future<void> clearCacheAndReload() async {
    try {
      // Unregister all service workers
      if (html.window.navigator.serviceWorker != null) {
        final registrations =
            await html.window.navigator.serviceWorker!.getRegistrations();
        for (final reg in registrations) {
          await reg.unregister();
        }
      }

      // Delete all caches
      if (html.window.caches != null) {
        final cacheNames = await html.window.caches!.keys();
        for (final name in cacheNames) {
          await html.window.caches!.delete(name);
        }
      }

      // Clear localStorage/sessionStorage as a safety (optional)
      try {
        html.window.localStorage.clear();
        html.window.sessionStorage.clear();
      } catch (_) {}

      // Finally reload
      html.window.location.reload();
    } catch (e) {
      print('キャッシュ破棄に失敗しました: $e');
      html.window.location.reload();
    }
  }
}
