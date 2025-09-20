// lib/utils/cache_manager.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:js/js_util.dart' as js_util;
// ignore: deprecated_member_use
import 'dart:html' as html;

/// アプリのキャッシュを管理するクラス
class CacheManager {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// アプリ起動時にすべてのキャッシュをクリアする
  static Future<void> clearAllCache() async {
    try {
      print('キャッシュクリアを開始します...');

      // SharedPreferencesのクリア
      await _clearSharedPreferences();

      // FlutterSecureStorageのクリア
      await _clearSecureStorage();

      // Webの場合はブラウザキャッシュもクリア
      if (kIsWeb) {
        await _clearWebCache();
      }

      print('キャッシュクリアが完了しました');
    } catch (e) {
      print('キャッシュクリア中にエラーが発生しました: $e');
    }
  }

  /// SharedPreferencesのキャッシュをクリア
  static Future<void> _clearSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('SharedPreferencesキャッシュをクリアしました');
    } catch (e) {
      print('SharedPreferencesクリアエラー: $e');
    }
  }

  /// FlutterSecureStorageのキャッシュをクリア
  static Future<void> _clearSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
      print('FlutterSecureStorageキャッシュをクリアしました');
    } catch (e) {
      print('FlutterSecureStorageクリアエラー: $e');
    }
  }

  /// Webブラウザのキャッシュをクリア
  static Future<void> _clearWebCache() async {
    try {
      // Service Workerのキャッシュをクリア
      if (js_util.hasProperty(html.window, 'caches')) {
        final caches = js_util.getProperty(html.window, 'caches');
        if (caches != null) {
          final cacheNames = await js_util.promiseToFuture(
            js_util.callMethod(caches, 'keys', []),
          );

          for (final cacheName in cacheNames) {
            await js_util.promiseToFuture(
              js_util.callMethod(caches, 'delete', [cacheName]),
            );
          }
        }
      }

      // LocalStorageをクリア
      html.window.localStorage.clear();

      // SessionStorageをクリア
      html.window.sessionStorage.clear();

      print('Webブラウザキャッシュをクリアしました');
    } catch (e) {
      print('Webキャッシュクリアエラー: $e');
    }
  }

  /// 特定のキーのキャッシュのみをクリア
  static Future<void> clearSpecificCache(List<String> keys) async {
    try {
      // SharedPreferencesから特定のキーを削除
      final prefs = await SharedPreferences.getInstance();
      for (final key in keys) {
        await prefs.remove(key);
      }

      // FlutterSecureStorageから特定のキーを削除
      for (final key in keys) {
        await _secureStorage.delete(key: key);
      }

      print('指定されたキーのキャッシュをクリアしました: $keys');
    } catch (e) {
      print('特定キャッシュクリアエラー: $e');
    }
  }

  /// キャッシュサイズを取得（デバッグ用）
  static Future<Map<String, int>> getCacheSize() async {
    final Map<String, int> sizes = {};

    try {
      // SharedPreferencesのキー数を取得
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      sizes['SharedPreferences'] = keys.length;

      // FlutterSecureStorageのサイズは直接取得できないため、概算
      sizes['FlutterSecureStorage'] = 0; // 実際のサイズは取得困難

      print('キャッシュサイズ: $sizes');
    } catch (e) {
      print('キャッシュサイズ取得エラー: $e');
    }

    return sizes;
  }
}
