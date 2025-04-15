import 'database_service.dart';
import '../config/uuid_range.dart';

class UuidService {
  final DatabaseService _dbService = DatabaseService();
  final UuidRangeService _rangeService = UuidRangeService();

  Future<bool> validateUuid(String uuid) async {
    try {
      // 1. UUIDの形式をチェック
      if (!_isValidUuidFormat(uuid)) {
        return false;
      }

      // 2. UUIDが有効な範囲内にあるかチェック
      if (!_rangeService.isInValidRange(uuid)) {
        return false;
      }

      // 3. 既に投票済みかチェック
      bool hasVoted = await _dbService.hasVoted(uuid);
      return !hasVoted;
    } catch (e) {
      print('UUID検証エラー: $e');
      return false;
    }
  }

  bool _isValidUuidFormat(String uuid) {
    RegExp uuidRegex = RegExp(r'^[0-9]{6}$');
    return uuidRegex.hasMatch(uuid);
  }

  // 必要に応じて範囲を動的に設定できるメソッドを追加
  void setValidRanges(List<UuidRange> ranges) {
    _rangeService.clearRanges();
    for (var range in ranges) {
      _rangeService.addRange(range.start, range.end);
    }
  }

  // 単一の範囲を追加するショートカットメソッド
  void addValidRange(int start, int end) {
    _rangeService.addRange(start, end);
  }
}
