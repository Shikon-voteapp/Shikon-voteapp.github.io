import '../models/student.dart';

class StudentMapping {
  static Map<String, Student> getMappings() {
    return {
      // サンプルデータ（実際の使用時は生成されたデータに置き換えられます）
      '2000000001': Student(grade: '中1', className: 'A', number: 1),
      '2000000002': Student(grade: '中1', className: 'A', number: 2),
      '2000000003': Student(grade: '中1', className: 'A', number: 3),
      // ...その他のマッピング
    };
  }
}
