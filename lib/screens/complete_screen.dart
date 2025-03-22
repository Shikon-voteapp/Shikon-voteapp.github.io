// screens/complete_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/top_bar.dart';
import '../widgets/message_area.dart';
import '../widgets/bottom_bar.dart';
import 'scanner_screen.dart';

class CompleteScreen extends StatefulWidget {
  final String uuid;

  CompleteScreen({required this.uuid});

  @override
  _CompleteScreenState createState() => _CompleteScreenState();
}

class _CompleteScreenState extends State<CompleteScreen> {
  int _countdown = 10; // 10秒カウントダウン
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // カウントダウンタイマー開始
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer.cancel();
          _resetToScannerScreen();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _resetToScannerScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ScannerScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(title: '投票完了'),
          MessageArea(
            title: '完了',
            titleColor: Colors.green,
            message: '投票が完了しました。ありがとうございました。',
            icon: Icons.check_circle,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 120,
                    color: Colors.green,
                  ),
                  SizedBox(height: 32),
                  Text(
                    '投票ありがとうございました',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'この画面は $_countdown 秒後に自動的に閉じます',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _resetToScannerScreen,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text('トップに戻る'),
                  ),
                ],
              ),
            ),
          ),
          BottomBar(uuid: widget.uuid, showNextButton: false),
        ],
      ),
    );
  }
}
