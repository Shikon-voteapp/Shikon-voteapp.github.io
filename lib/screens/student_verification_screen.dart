// lib/screens/student_verification_screen.dart
import 'package:flutter/material.dart';
import '../services/student_verification_service.dart';
import '../models/student.dart';
import '../platform/platform_utils.dart';
import '../widgets/main_layout.dart';
import 'vote_screen.dart';
import '../widgets/custom_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: '生徒認証',
      icon: Icons.badge_outlined,
      onHome: () => PlatformUtils.reloadApp(),
      helpTitle: '生徒情報の入力について',
      helpContent:
          '投票券に記載されているご自身の学年、クラス、出席番号を正しく選択してください。この情報が間違っていると投票に進むことができません。',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Text(
                '投票券に記載された 学年・クラス・番号を選択してください。\nこの情報が正しくない場合、ログインできません。',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            _buildDropdownContainer(
              '学年',
              _buildDropdown(
                _grades,
                _selectedGrade,
                (value) => setState(() => _selectedGrade = value),
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownContainer(
              'クラス',
              _buildDropdown(
                _classes,
                _selectedClass,
                (value) => setState(() => _selectedClass = value),
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownContainer('番号', _buildNumberDropdown()),
            const Spacer(),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyStudent,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: const Color(0xFF592C7A),
                elevation: 0,
              ),
              child:
                  _isVerifying
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                      : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ログイン',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownContainer(String label, Widget dropdown) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          dropdown,
        ],
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedValue,
        hint: const Text(''),
        onChanged: onChanged,
        items:
            items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
        icon: const Icon(Icons.arrow_drop_down),
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((String item) {
            return Center(
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildNumberDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        isExpanded: true,
        value: _selectedNumber,
        hint: const Text(''),
        onChanged: (value) => setState(() => _selectedNumber = value),
        items:
            _numbers.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                alignment: Alignment.center,
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
        icon: const Icon(Icons.arrow_drop_down),
        selectedItemBuilder: (BuildContext context) {
          return _numbers.map<Widget>((int item) {
            return Center(
              child: Text(
                item.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Future<void> _verifyStudent() async {
    if (_selectedGrade == null ||
        _selectedClass == null ||
        _selectedNumber == null) {
      showCustomDialog(
        context: context,
        title: '入力エラー',
        content: 'すべての項目を選択してください',
      );
      return;
    }

    setState(() {
      _isVerifying = true;
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
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => VoteScreen(uuid: widget.uuid, categoryIndex: 0),
            ),
          );
        }
      } else {
        if (mounted) {
          showCustomDialog(
            context: context,
            title: '認証エラー',
            content: '認証情報が一致しません。正しい情報を入力してください。',
          );
        }
        setState(() {
          _isVerifying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showCustomDialog(
          context: context,
          title: 'エラー',
          content: 'エラーが発生しました: ${e.toString()}',
        );
      }
      setState(() {
        _isVerifying = false;
      });
    }
  }
}
