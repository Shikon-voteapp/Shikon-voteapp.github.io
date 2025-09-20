// lib/services/student_verification_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/student.dart';

class StudentVerificationService {
  final String _localMappingKey = 'student_mappings';

  // 学生情報を検証（ローカルのみ）
  Future<bool> verifyStudent(String uuid, Student student) async {
    try {
      // ローカルストレージから確認
      final prefs = await SharedPreferences.getInstance();
      final localMappingsJson = prefs.getString(_localMappingKey);

      if (localMappingsJson != null) {
        final Map<String, dynamic> localMappings = json.decode(
          localMappingsJson,
        );
        if (localMappings.containsKey(uuid)) {
          final mappedData = localMappings[uuid];
          final mappedStudent = Student.fromJson(mappedData);
          return student == mappedStudent;
        }
      }

      // ローカルにデータがない場合はfalseを返す
      return false;
    } catch (e) {
      print('学生検証エラー: $e');
      return false;
    }
  }

  // 単一の学生マッピングを保存（ローカルのみ）
  Future<void> saveStudentMapping(String uuid, Student student) async {
    try {
      // ローカルストレージに保存
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> localMappings = {};

      final localMappingsJson = prefs.getString(_localMappingKey);
      if (localMappingsJson != null) {
        localMappings = json.decode(localMappingsJson);
      }

      localMappings[uuid] = student.toJson();
      await prefs.setString(_localMappingKey, json.encode(localMappings));
    } catch (e) {
      print('学生マッピング保存エラー: $e');
      throw e;
    }
  }

  // 学生マッピングの一括インポート（ローカルのみ）
  Future<void> importStudentMappings(Map<String, Student> mappings) async {
    try {
      // ローカルストレージに保存
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> localMappings = {};

      mappings.forEach((uuid, student) {
        localMappings[uuid] = student.toJson();
      });

      await prefs.setString(_localMappingKey, json.encode(localMappings));
    } catch (e) {
      print('学生マッピングインポートエラー: $e');
      throw e;
    }
  }

  // 学生マッピングのエクスポート（ローカルのみ）
  Future<Map<String, Student>> exportStudentMappings() async {
    try {
      // ローカルストレージから読み込む
      final prefs = await SharedPreferences.getInstance();
      final localMappingsJson = prefs.getString(_localMappingKey);
      Map<String, Student> mappings = {};

      if (localMappingsJson != null) {
        final Map<String, dynamic> localMappings = json.decode(
          localMappingsJson,
        );

        localMappings.forEach((uuid, studentData) {
          mappings[uuid] = Student.fromJson(
            Map<String, dynamic>.from(studentData),
          );
        });
      }

      return mappings;
    } catch (e) {
      print('学生マッピングエクスポートエラー: $e');
      return {};
    }
  }
}
