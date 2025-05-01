// lib/services/student_verification_service.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/student.dart';

class StudentVerificationService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final String _studentMappingPath = 'student_mapping';
  final String _localMappingKey = 'student_mappings';

  // 学生情報を検証
  Future<bool> verifyStudent(String uuid, Student student) async {
    try {
      // まずはローカルストレージから確認
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

      // FirebaseからUUIDに対応する学生情報を取得
      final snapshot = await _database.ref('$_studentMappingPath/$uuid').get();

      if (!snapshot.exists) {
        return false;
      }

      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      Student mappedStudent = Student(
        grade: data['grade'],
        className: data['className'],
        number: data['number'],
      );

      // 学生情報を比較
      return student == mappedStudent;
    } catch (e) {
      print('学生検証エラー: $e');
      return false;
    }
  }

  // 単一の学生マッピングを保存
  Future<void> saveStudentMapping(String uuid, Student student) async {
    try {
      // ローカルストレージにも保存
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> localMappings = {};

      final localMappingsJson = prefs.getString(_localMappingKey);
      if (localMappingsJson != null) {
        localMappings = json.decode(localMappingsJson);
      }

      localMappings[uuid] = student.toJson();
      await prefs.setString(_localMappingKey, json.encode(localMappings));

      // Firebaseに保存
      await _database.ref('$_studentMappingPath/$uuid').set(student.toJson());
    } catch (e) {
      print('学生マッピング保存エラー: $e');
      throw e;
    }
  }

  // 学生マッピングの一括インポート
  Future<void> importStudentMappings(Map<String, Student> mappings) async {
    try {
      // ローカルストレージに保存
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> localMappings = {};

      mappings.forEach((uuid, student) {
        localMappings[uuid] = student.toJson();
      });

      await prefs.setString(_localMappingKey, json.encode(localMappings));

      // Firebaseに保存
      Map<String, Map<String, dynamic>> data = {};
      mappings.forEach((uuid, student) {
        data[uuid] = student.toJson();
      });

      await _database.ref(_studentMappingPath).set(data);
    } catch (e) {
      print('学生マッピングインポートエラー: $e');
      throw e;
    }
  }

  // 学生マッピングのエクスポート
  Future<Map<String, Student>> exportStudentMappings() async {
    try {
      // まずFirebaseから取得を試みる
      final snapshot = await _database.ref(_studentMappingPath).get();
      Map<String, Student> mappings = {};

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          String uuid = key.toString();
          Map<String, dynamic> studentData = Map<String, dynamic>.from(value);
          mappings[uuid] = Student.fromJson(studentData);
        });

        return mappings;
      }

      // Firebaseにデータがなければローカルストレージから読み込む
      final prefs = await SharedPreferences.getInstance();
      final localMappingsJson = prefs.getString(_localMappingKey);

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
