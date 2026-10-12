import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class VersionInfo {
  static String _version = '4.3.1';
  static String _buildNumber = '95';
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      // Webプラットフォームでは、直接バージョン情報を設定
      // pubspec.yamlの読み取りは信頼性が低いため、ハードコードされたバージョンを使用
      _version = '4.3.1';
      _buildNumber = '95';
      print('Web環境のため、バージョン情報を直接設定します: $_version.$_buildNumber');
    } else {
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      } catch (e) {
        print('非Webプラットフォームでのバージョン情報の取得に失敗しました: $e');
        print('デフォルトバージョン情報を使用します');
        _version = '4.3.1';
        _buildNumber = '95';
      }
    }

    _initialized = true;
  }

  static String get version => _version;
  static String get buildNumber => _buildNumber;
  static String get fullVersion {
    final currentYear = DateTime.now().year;
    return '$_version+$_buildNumber-$currentYear';
  }

  static DateTime get buildDate => DateTime.now();

  static String get formattedBuildDate {
    final date = DateTime.now();
    return '${date.year}年${date.month}月${date.day}日';
  }
}
