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

  static void closeTab() {
    try {
      html.window.close();
      // window.close() は直接開いたタブでは無視されるため、
      // 100ms後にまだページが生きていたらフォールバック画面を表示する
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          final body = html.document.body;
          if (body != null) {
            body.style.margin = '0';
            body.style.padding = '0';
            body.style.background = 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)';
            body.style.minHeight = '100vh';
            body.style.display = 'flex';
            body.style.alignItems = 'center';
            body.style.justifyContent = 'center';
            body.style.fontFamily = "'Noto Sans JP', 'M PLUS Rounded 1c', sans-serif";
            body.innerHtml = '''
              <div style="text-align:center;color:#fff;padding:40px;max-width:480px;">
                <div style="font-size:72px;margin-bottom:24px;">✅</div>
                <h1 style="font-size:26px;font-weight:700;margin:0 0 12px;letter-spacing:0.02em;">
                  投票が完了しました
                </h1>
                <p style="font-size:16px;opacity:0.75;line-height:1.7;margin:0 0 32px;">
                  ご協力ありがとうございました。<br>
                  このタブを閉じてください。
                </p>
                <div style="
                  background:rgba(255,255,255,0.12);
                  border:1.5px solid rgba(255,255,255,0.25);
                  border-radius:16px;
                  padding:20px 28px;
                  font-size:14px;
                  opacity:0.85;
                  line-height:1.6;
                ">
                  <strong>タブの閉じ方</strong><br>
                  タブ右上の <strong>✕</strong> ボタン<br>
                  またはショートカット <strong>Ctrl + W</strong>（Windows）<br>
                  <strong>⌘ + W</strong>（Mac）を押してください。
                </div>
              </div>
            ''';
          }
        } catch (_) {}
      });
    } catch (e) {
      print('タブを閉じるエラー: $e');
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
