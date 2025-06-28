// lib/screens/student_verification_screen.dart
import 'package:flutter/material.dart';
import '../services/student_verification_service.dart';
import '../models/student.dart';
import '../platform/platform_utils.dart';
import '../widgets/main_layout.dart';
import '../widgets/message_area.dart';
import 'vote_screen.dart';

class StudentVerificationScreen extends StatefulWidget {
  final String uuid;

  const StudentVerificationScreen({Key? key, required this.uuid})
    : super(key: key);

  @override
  _StudentVerificationScreenState createState() =>
      _StudentVerificationScreenState();
}

class _StudentVerificationScreenState extends State<StudentVerificationScreen> {
  final StudentVerificationService _verificationService =
      StudentVerificationService();
  final List<String> _grades = ['中1', '中2', '中3', '高Ⅰ', '高Ⅱ', '高Ⅲ'];
  final List<String> _classes = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
  final List<int> _numbers = List.generate(45, (index) => index + 1);

  String? _selectedGrade;
  String? _selectedClass;
  int? _selectedNumber;
  bool _isVerifying = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '生徒認証',
      onHome: () => PlatformUtils.reloadApp(),
      child: Column(
        children: [
          MessageArea(message: '学年、クラス、出席番号を選択してください。', title: ''),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDropdown(
                    '学年',
                    _grades,
                    _selectedGrade,
                    (value) => setState(() => _selectedGrade = value),
                  ),
                  SizedBox(height: 16),
                  _buildDropdown(
                    'クラス',
                    _classes,
                    _selectedClass,
                    (value) => setState(() => _selectedClass = value),
                  ),
                  SizedBox(height: 16),
                  _buildNumberDropdown(),
                  SizedBox(height: 24),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyStudent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child:
                          _isVerifying
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('確認', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedValue,
                hint: Text('選択してください'),
                onChanged: onChanged,
                items:
                    items.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '出席番号',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedNumber,
                hint: Text('選択してください'),
                onChanged: (value) => setState(() => _selectedNumber = value),
                items:
                    _numbers.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _verifyStudent() async {
    if (_selectedGrade == null ||
        _selectedClass == null ||
        _selectedNumber == null) {
      setState(() {
        _errorMessage = 'すべての項目を選択してください';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      Student student = Student(
        grade: _selectedGrade!,
        className: _selectedClass!,
        number: _selectedNumber!,
      );

      bool isValid = await _verificationService.verifyStudent(
        widget.uuid,
        student,
      );

      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => VoteScreen(uuid: widget.uuid, categoryIndex: 0),
          ),
        );
      } else {
        setState(() {
          _errorMessage = '認証情報が一致しません。正しい情報を入力してください。';
          _isVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'エラーが発生しました: ${e.toString()}';
        _isVerifying = false;
      });
    }
  }
}
