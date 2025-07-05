import 'package:flutter/material.dart';
import 'dart:async';
import '../config/data_range_service.dart';
import 'out_of_period_screen.dart';
import 'selection_screen.dart';

class SplashScreen extends StatefulWidget {
  final DateRangeService dateRangeService;

  const SplashScreen({Key? key, required this.dateRangeService})
    : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _loadingMessage = '起動準備中...';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // 実際の初期化処理に合わせてメッセージを更新
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _loadingMessage = '投票期間を確認しています...';
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final DateTime now = DateTime.now();
    final bool isInPeriod = widget.dateRangeService.isWithinVotingPeriod(now);

    setState(() {
      _loadingMessage = '画面の準備をしています...';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _loadingMessage = 'まもなく起動します...';
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    if (isInPeriod) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SelectionScreen()),
      );
    } else {
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
              _loadingMessage,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
