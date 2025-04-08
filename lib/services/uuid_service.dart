import 'database_service.dart';

class UuidService {
  final DatabaseService _dbService = DatabaseService();
  Future<bool> validateUuid(String uuid) async {
    try {
      if (!_isValidUuidFormat(uuid)) {
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
    RegExp uuidRegex = RegExp(r'^[0-9]{6}$');
    return uuidRegex.hasMatch(uuid);
  }
}
