import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:convert';
import 'dart:typed_data';
import 'platform_utils.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PlatformUtilsImpl {
  static Future<PermissionResult> requestCameraPermission() async {
    try {
      final mediaDevices = web.window.navigator.mediaDevices;
      final constraints = web.MediaStreamConstraints(
        video: true.toJS,
        audio: false.toJS,
      );
      final userMedia = await mediaDevices.getUserMedia(constraints).toDart;
      final tracks = userMedia.getTracks().toDart;
      for (final track in tracks) {
        track.stop();
      }
      return PermissionResult(granted: true);
    } catch (e) {
      return PermissionResult(granted: false, errorMessage: e.toString());
    }
  }

  static void reloadApp() {
    // DDC 開発モードでのモジュール初期化エラーを避けるため、
    // `reload()` ではなくアプリのルートURLへ遷移する。
    final href = web.window.location.origin + (web.window.location.pathname.isEmpty ? '/' : web.window.location.pathname);
    web.window.location.assign(href);
  }

  static void downloadFile(String content, String filename) {
    try {
      final bytes = utf8.encode(content);
      downloadBytes(bytes, filename, mimeType: 'text/plain');
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
      final blob = web.Blob(
        [Uint8List.fromList(bytes).toJS].toJS,
        web.BlobPropertyBag(type: mimeType),
      );
      final url = web.URL.createObjectURL(blob);
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = filename;
      web.document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(url);
    } catch (e) {
      print('ファイルダウンロードエラー: $e');
    }
  }

  static void openUrl(String url) {
    try {
      web.window.open(url, '_blank');
    } catch (e) {
      print('URLを開くエラー: $e');
    }
  }

  static void closeTab() {
    try {
      // ブラウザのセキュリティ制限を回避: _selfで開いてからclose()する
      web.window.open('', '_self', '');
      web.window.close();
    } catch (e) {
      // フォールバック: ユーザーに手動で閉じるよう案内
      web.window.alert('投票が完了しました。このタブを手動で閉じてください。\n（ブラウザの制限により自動では閉じられない場合があります）');
    }
  }

  static Future<void> clearCacheAndReload() async {
    try {
      // Unregister all service workers
      try {
        final sw = web.window.navigator.serviceWorker;
        final registrations = await sw.getRegistrations().toDart;
        final regList = registrations.toDart;
        for (final reg in regList) {
          await reg.unregister().toDart;
        }
      } catch (_) {}

      // Delete all caches
      try {
        final caches = web.window.caches;
        final cacheKeys = await caches.keys().toDart;
        final keysList = cacheKeys.toDart;
        for (final key in keysList) {
          await caches.delete(key.toDart).toDart;
        }
      } catch (_) {}

      // Clear localStorage/sessionStorage as a safety (optional)
      try {
        web.window.localStorage.clear();
        web.window.sessionStorage.clear();
      } catch (_) {}

      // キャッシュ削除後も同じ理由でルートURLへ遷移する。
      final href = web.window.location.origin + (web.window.location.pathname.isEmpty ? '/' : web.window.location.pathname);
      web.window.location.assign(href);
    } catch (e) {
      print('キャッシュ破棄に失敗しました: $e');
      final href = web.window.location.origin + (web.window.location.pathname.isEmpty ? '/' : web.window.location.pathname);
      web.window.location.assign(href);
    }
  }
}
