import 'package:package_info_plus/package_info_plus.dart';
import '../config/vote_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;

class VersionInfo {
  static String _version = '28.4.0';
  static String _buildNumber = '36';
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    if (kIsWeb) {
      // Webプラットフォームでは、直接バージョン情報を設定
      // pubspec.yamlの読み取りは信頼性が低いため、ハードコードされたバージョンを使用
      _version = '28.4.0';
      _buildNumber = '36';
      print('Web環境のため、バージョン情報を直接設定します: $_version.$_buildNumber');
    } else {
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      } catch (e) {
        print('非Webプラットフォームでのバージョン情報の取得に失敗しました: $e');
        print('デフォルトバージョン情報を使用します');
        _version = '28.4.0';
        _buildNumber = '36';
      }
    }
    
    _initialized = true;
  }

  static Future<void> _loadVersionFromPubspec() async {
    try {
      // pubspec.yamlからバージョン情報を読み取る
      final pubspecContent = await rootBundle.loadString('pubspec.yaml');
      final versionMatch = RegExp(r'version:\s*([^\s]+)').firstMatch(pubspecContent);
      
      if (versionMatch != null) {
        final versionString = versionMatch.group(1);
        if (versionString != null) {
          // 形式: 1.0.0+11
          if (versionString.contains('+')) {
            final parts = versionString.split('+');
            _version = parts[0];
            _buildNumber = parts.length > 1 ? parts[1] : '1';
          } else {
            _version = versionString;
            _buildNumber = '36';
          }
          print('pubspec.yamlからバージョン情報を読み取りました: $_version+$_buildNumber');
          return;
        }
      }
      
      // フォールバック: デフォルト値を使用
      _version = '28.4.0';
      _buildNumber = '36';
      print('pubspec.yamlからバージョン情報を読み取れませんでした。デフォルト値を使用します: $_version+$_buildNumber');
    } catch (e) {
      print('pubspec.yamlの読み取りに失敗しました: $e');
      // Web環境では、ハードコードされたバージョンを使用
      _version = '28.4.0';
      _buildNumber = '36';
      print('Web環境のため、デフォルトバージョン情報を使用します: $_version+$_buildNumber');
    }
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
