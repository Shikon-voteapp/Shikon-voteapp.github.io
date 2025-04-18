import 'dart:html' as html;
import 'platform_utils.dart';

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
}
