import 'package:flutter/material.dart';
import 'package:shikon_voteapp/theme.dart';
import '../widgets/main_layout.dart';

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
    return MainLayout(
      title: '投票時間外',
      icon: Icons.timer_off_outlined,
      onHome:
          () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/scanner', (route) => false),
      helpTitle: '投票期間について',
      helpContent:
          '投票は指定された期間内でのみ可能です。\nまた、毎日深夜01:00から02:00まではサーバーメンテナンスのため投票できません。\nご了承ください。',
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 80.0, color: AppTheme.primaryColor),
            SizedBox(height: 30),
            Text(
              '投票期間外です',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '現在は投票を受け付けていません。\n以下の期間内に再度お試しください。\nなお、毎日深夜01:00～02:00はサーバーメンテナンスのため投票できません。',
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
            /*SizedBox(height: 40),
            ElevatedButton(
              onPressed: (reloadPage),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 24.0,
                ),
                child: Text('再読み込み', style: TextStyle(fontSize: 18)),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  // 日時のフォーマット
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
