import 'package:firebase_database/firebase_database.dart';

/// Checks issued voting numbers against the authoritative Realtime Database
/// registry at `valid_uuids/{10-digit-number}`.
class UuidRangeService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<bool> isInValidRange(String uuidStr) async {
    if (!RegExp(r'^[0-9]{10}$').hasMatch(uuidStr)) return false;
    final snapshot = await _database.ref('valid_uuids/$uuidStr').get();
    return snapshot.exists && snapshot.value == true;
  }

  bool requiresStudentVerification(String uuidStr) {
    try {
      final uuid = int.parse(uuidStr);
      return uuid >= 2000000000 && uuid <= 2999999999;
    } catch (e) {
      print('学生検証範囲チェックエラー: $e');
      return false;
    }
  }
}
