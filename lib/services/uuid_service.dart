// services/uuid_service.dart
import 'package:uuid/uuid.dart';
import 'database_service.dart';

class UuidService {
  final DatabaseService _dbService = DatabaseService();
  final Uuid _uuid = Uuid();

  // UUIDが有効かどうか（既に投票済みでないか）をチェック
  Future<bool> validateUuid(String uuid) async {
    try {
      // UUIDの形式チェック
      if (!_isValidUuidFormat(uuid)) {
        return false;
      }
      // データベースで投票済みかチェック
      bool hasVoted = await _dbService.hasVoted(uuid);
      return !hasVoted; // 投票済みでなければtrue
    } catch (e) {
      print('UUID検証エラー: $e');
      return false;
    }
  }

  // 正しいUUID形式かをチェック
  bool _isValidUuidFormat(String uuid) {
    // 簡易的なチェック - 実際のアプリではもっと厳密に
    RegExp uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  // デモ用：新しいUUIDを生成
  String generateUuid() {
    return _uuid.v4();
  }
}
