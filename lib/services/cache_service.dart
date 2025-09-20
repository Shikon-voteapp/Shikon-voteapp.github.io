import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static const String _cachePrefix = 'cache_';
  static const String _cacheTimestampPrefix = 'cache_timestamp_';
  static const Duration _defaultCacheDuration = Duration(hours: 1);

  // キャッシュにデータを保存
  static Future<void> setCache(
    String key,
    dynamic data, {
    Duration? duration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';

      final cacheDuration = duration ?? _defaultCacheDuration;
      final expiryTime =
          DateTime.now().add(cacheDuration).millisecondsSinceEpoch;

      await prefs.setString(cacheKey, json.encode(data));
      await prefs.setInt(timestampKey, expiryTime);
    } catch (e) {
      print('キャッシュ保存エラー: $e');
    }
  }

  // キャッシュからデータを取得
  static Future<T?> getCache<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';

      final cachedData = prefs.getString(cacheKey);
      final expiryTime = prefs.getInt(timestampKey);

      if (cachedData == null || expiryTime == null) {
        return null;
      }

      // キャッシュの有効期限をチェック
      if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
        await clearCache(key);
        return null;
      }

      return json.decode(cachedData) as T?;
    } catch (e) {
      print('キャッシュ取得エラー: $e');
      return null;
    }
  }

  // キャッシュをクリア
  static Future<void> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';

      await prefs.remove(cacheKey);
      await prefs.remove(timestampKey);
    } catch (e) {
      print('キャッシュクリアエラー: $e');
    }
  }

  // 全キャッシュをクリア
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (String key in keys) {
        if (key.startsWith(_cachePrefix) ||
            key.startsWith(_cacheTimestampPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('全キャッシュクリアエラー: $e');
    }
  }

  // キャッシュの有効性をチェック
  static Future<bool> isCacheValid(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = '$_cacheTimestampPrefix$key';
      final expiryTime = prefs.getInt(timestampKey);

      if (expiryTime == null) {
        return false;
      }

      return DateTime.now().millisecondsSinceEpoch < expiryTime;
    } catch (e) {
      print('キャッシュ有効性チェックエラー: $e');
      return false;
    }
  }
}
