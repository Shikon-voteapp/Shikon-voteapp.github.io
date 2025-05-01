// lib/config/student_mapping_init.dart
import '../services/student_verification_service.dart';
import '../models/student.dart';
import 'student_mapping.dart';

class StudentMappingInitializer {
  final StudentVerificationService _verificationService =
      StudentVerificationService();

  Future<void> initializeMappings() async {
    try {
      // 学生マッピングをデータベースにインポート
      Map<String, Student> mappings = StudentMapping.getMappings();
      await _verificationService.importStudentMappings(mappings);
      print('学生マッピングが正常に初期化されました。合計: ${mappings.length} 件');
    } catch (e) {
      print('学生マッピング初期化エラー: $e');
    }
  }
}
