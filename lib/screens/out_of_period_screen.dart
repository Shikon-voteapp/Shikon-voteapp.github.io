// screens/out_of_period_screen.dart
import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class OutOfPeriodScreen extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const OutOfPeriodScreen({
    Key? key,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(title: '投票期間外'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 80.0, color: Colors.orange),
                  SizedBox(height: 30),
                  Text(
                    '投票期間外です',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '現在は投票を受け付けていません。\n以下の期間内に再度お試しください。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 30),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.play_arrow, color: Colors.green),
                              SizedBox(width: 10),
                              Text(
                                '開始：',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Text(_formatDateTime(startDate))),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.stop, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                '終了：',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Text(_formatDateTime(endDate))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 24.0,
                      ),
                      child: Text('戻る', style: TextStyle(fontSize: 18)),
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

  // 日時のフォーマット
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
