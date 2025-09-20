// lib/screens/student_verification_screen.dart
import 'package:flutter/material.dart';
import '../services/student_verification_service.dart';
import 'package:flutter/services.dart';
import '../models/student.dart';
import '../widgets/main_layout.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../widgets/neumorphic_wrappers.dart';
import 'vote_screen.dart';
import '../widgets/custom_dialog.dart';
import 'package:icons_plus/icons_plus.dart';
import '../platform/platform_utils.dart';

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
  // 数値入力へ変更したため未使用

  String? _selectedGrade;
  String? _selectedClass;
  int? _selectedNumber;
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MainLayout(
      title: '本人確認',
      icon: FontAwesome.id_card_solid,
      onHome: () => PlatformUtils.reloadApp(),
      helpTitle: '生徒の本人確認',
      helpContent: '投票権に記載された学年・クラス・番号を選択してください。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 32,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    neumorphicCard(
                      context: context,
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        '投票券に記載された 学年・クラス・番号を選択してください。\nこの情報が正しくない場合、ログインできません。',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
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
                    _buildDropdownContainer('番号', _buildNumberField()),
                    const Spacer(),
                    NeumorphicButton(
                      onPressed: _isVerifying ? null : _verifyStudent,
                      style: NeumorphicStyle(
                        color:
                            _isVerifying
                                ? null
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                        depth: _isVerifying ? -4 : 6,
                        intensity: 0.8,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Center(
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
                                : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ログイン',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.black
                                                : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      FontAwesome.arrow_right_solid,
                                      size: 16,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.black
                                              : Colors.white,
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdownContainer(String label, Widget dropdown) {
    final theme = Theme.of(context);
    return neumorphicCard(
      context: context,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      borderRadius: BorderRadius.circular(16.0),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildNumberField() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '番号',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Neumorphic(
          style: NeumorphicStyle(
            depth: -4,
            intensity: 0.8,
            boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.all(Radius.circular(12)),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: '番号を入力...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                onChanged: (value) {
                  final trimmed =
                      value.length > 2 ? value.substring(0, 2) : value;
                  if (trimmed != value) {
                    // TextFieldが自動で切り詰めるため、stateだけ更新
                  }
                  setState(() => _selectedNumber = int.tryParse(trimmed));
                },
                textAlign: TextAlign.center,
                maxLength: 2,
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_selectedNumber?.toString().length ?? 0}/2',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
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

    // 1.1秒の待機時間
    await Future.delayed(const Duration(milliseconds: 1100));

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
