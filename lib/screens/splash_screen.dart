import 'package:flutter/material.dart';
import 'dart:async';
import '../config/data_range_service.dart';
import 'out_of_period_screen.dart';
import 'scanner_screen.dart';

class SplashScreen extends StatefulWidget {
  final DateRangeService dateRangeService;

  const SplashScreen({Key? key, required this.dateRangeService})
    : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // スプラッシュスクリーンを表示する時間
    Timer(Duration(milliseconds: 2000), () {
      _checkVotingPeriod();
    });
  }

  void _checkVotingPeriod() {
    // 投票期間をチェック
    final DateTime now = DateTime.now();
    final bool isInPeriod = widget.dateRangeService.isWithinVotingPeriod(now);

    if (isInPeriod) {
      // 投票期間内の場合
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          //builder: (context) => CameraPermissionWrapper(child: ScannerScreen()),
          builder: (context) => ScannerScreen(),
        ),
      );
    } else {
      // 投票期間外の場合
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => OutOfPeriodScreen(
                startDate: widget.dateRangeService.startDate,
                endDate: widget.dateRangeService.endDate,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.deepPurple),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.how_to_vote, size: 150, color: Colors.white),
            SizedBox(height: 30),
            Text(
              '紫紺祭投票アプリ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              '読み込み中...',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
