import 'package:package_info_plus/package_info_plus.dart';
import '../config/vote_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class VersionInfo {
  static String _version = '1.6.3';
  static String _buildNumber = '21';
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      // Webプラットフォームでは、直接バージョン情報を設定
      // pubspec.yamlの読み取りは信頼性が低いため、ハードコードされたバージョンを使用
      _version = '1.6.3';
      _buildNumber = '21';
      print('Web環境のため、バージョン情報を直接設定します: $_version.$_buildNumber');
    } else {
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      } catch (e) {
        print('非Webプラットフォームでのバージョン情報の取得に失敗しました: $e');
        print('デフォルトバージョン情報を使用します');
        _version = '1.6.3';
        _buildNumber = '21';
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

  static DateTime get buildDate => dataUpdateDate;

  static String get formattedBuildDate {
    return '${dataUpdateDate.year}年${dataUpdateDate.month}月${dataUpdateDate.day}日';
  }
}
