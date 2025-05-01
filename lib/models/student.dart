// lib/models/student.dart
class Student {
  final String grade; // 学年（中1～高3）
  final String className; // クラス（A～G）
  final int number; // 出席番号（1～41）

  Student({required this.grade, required this.className, required this.number});

  Map<String, dynamic> toJson() {
    return {'grade': grade, 'className': className, 'number': number};
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      grade: json['grade'],
      className: json['className'],
      number: json['number'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Student &&
        other.grade == grade &&
        other.className == className &&
        other.number == number;
  }

  @override
  int get hashCode => grade.hashCode ^ className.hashCode ^ number.hashCode;
}
