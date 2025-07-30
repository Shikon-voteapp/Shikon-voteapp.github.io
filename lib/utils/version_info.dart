import 'package:package_info_plus/package_info_plus.dart';
import '../config/vote_options.dart';

class VersionInfo {
  static String _version = '1.0.0';
  static String _buildNumber = '1';

  static Future<void> initialize() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    } catch (e) {
      // エラーの場合はデフォルト値を使用
      print('バージョン情報の取得に失敗しました: $e');
    }
  }

  static String get version => _version;
  static String get buildNumber => _buildNumber;
  static String get fullVersion => '$_version+$_buildNumber';
  static DateTime get buildDate => dataUpdateDate;

  static String get formattedBuildDate {
    return '${dataUpdateDate.year}年${dataUpdateDate.month}月${dataUpdateDate.day}日';
  }
}
