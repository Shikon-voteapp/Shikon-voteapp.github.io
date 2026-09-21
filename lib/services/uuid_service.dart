// lib/services/uuid_service.dart
import 'database_service.dart';
import '../config/uuid_range.dart';
import '../config/special_ids.dart';

/// UUIDの検証結果を表す enum
enum UuidValidationResult {
  /// 有効 - 投票可能
  valid,
  /// 無効 - 書式不正（10桁数字でない）
  invalidFormat,
  /// 無効 - 発行された番号の範囲外
  outOfRange,
  /// 無効 - 管理者により無効化された番号
  invalidated,
  /// すでに投票済み（有効な番号だが既に使用済み）
  alreadyVoted,
}

class UuidService {
  final DatabaseService _dbService = DatabaseService();
  final UuidRangeService _rangeService = UuidRangeService();

  Future<bool> validateUuid(String uuid) async {
    final result = await validateUuidWithReason(uuid);
    return result == UuidValidationResult.valid;
  }

  /// 詳細な検証理由つきで検証する
  Future<UuidValidationResult> validateUuidWithReason(String uuid) async {
    try {
      // 特別IDは常に有効
      if (uuid == specialBypassUuid) {
        return UuidValidationResult.valid;
      }

      // 書式チェック
      if (!_isValidUuidFormat(uuid)) {
        return UuidValidationResult.invalidFormat;
      }

      // 範囲チェック
      if (!_rangeService.isInValidRange(uuid)) {
        return UuidValidationResult.outOfRange;
      }

      // 無効化されたUUIDかチェック
      bool isInvalidated = await _dbService.isUuidInvalidated(uuid);
      if (isInvalidated) {
        return UuidValidationResult.invalidated;
      }

      // 投票済みチェック
      bool hasVoted = await _dbService.hasVoted(uuid);
      if (hasVoted) {
        return UuidValidationResult.alreadyVoted;
      }

      return UuidValidationResult.valid;
    } catch (e) {
      print('UUID検証エラー: $e');
      return UuidValidationResult.outOfRange;
    }
  }

  /// 指定UUIDが無効化されているかをチェック
  Future<bool> isUuidInvalidated(String uuid) => _dbService.isUuidInvalidated(uuid);

  bool _isValidUuidFormat(String uuid) {
    RegExp uuidRegex = RegExp(r'^[0-9]{10}$');
    return uuidRegex.hasMatch(uuid);
  }

  // 学生検証が必要かどうかを確認
  bool requiresStudentVerification(String uuid) {
    // 特別IDは学生認証不要
    if (uuid == specialBypassUuid) return false;
    return _rangeService.requiresStudentVerification(uuid);
  }

  void setValidRanges(List<UuidRange> ranges) {
    _rangeService.clearRanges();
    for (var range in ranges) {
      _rangeService.addRange(range.start, range.end);
    }
  }

  void addValidRange(int start, int end) {
    _rangeService.addRange(start, end);
  }
}
