// lib/services/uuid_service.dart
import 'database_service.dart';
import '../config/uuid_range.dart';

class UuidService {
  final DatabaseService _dbService = DatabaseService();
  final UuidRangeService _rangeService = UuidRangeService();

  Future<bool> validateUuid(String uuid) async {
    try {
      if (!_isValidUuidFormat(uuid)) {
        return false;
      }

      if (!_rangeService.isInValidRange(uuid)) {
        return false;
      }

      bool hasVoted = await _dbService.hasVoted(uuid);
      return !hasVoted;
    } catch (e) {
      print('UUID検証エラー: $e');
      return false;
    }
  }

  bool _isValidUuidFormat(String uuid) {
    RegExp uuidRegex = RegExp(r'^[0-9]{10}$');
    return uuidRegex.hasMatch(uuid);
  }

  // 学生検証が必要かどうかを確認
  bool requiresStudentVerification(String uuid) {
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
