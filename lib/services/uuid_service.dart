// services/uuid_service.dart
import 'dart:math';
import 'database_service.dart';

class UuidService {
  final DatabaseService _dbService = DatabaseService();
  final Random _random = Random();

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

  // 正しいUUID形式かをチェック（6桁の数字）
  bool _isValidUuidFormat(String uuid) {
    // 6桁の数字かどうかチェック
    RegExp uuidRegex = RegExp(r'^[0-9]{6}$');
    return uuidRegex.hasMatch(uuid);
  }

  // 6桁の数字IDを生成
  String generateUuid() {
    // 100000から999999までの範囲でランダムな数字を生成
    int number = 100000 + _random.nextInt(900000);
    return number.toString();
  }
}
