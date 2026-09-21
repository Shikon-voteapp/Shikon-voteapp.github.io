import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'dart:async';
import '../config/data_range_service.dart';
import 'selection_screen.dart';
import '../utils/font_loading_stub.dart'
    if (dart.library.html) '../utils/font_loading_web.dart';

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
    // Webフォントの読み込み完了まで待機（非Webは即時）
    await waitForWebFonts();
    // 実際の初期化処理に合わせてメッセージを更新
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _loadingMessage = '起動準備をしています...';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SelectionScreen()),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.how_to_vote,
              size: 150,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
            ),
            SizedBox(height: 30),
            Text(
              '紫紺祭投票アプリ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
              ),
            ),
            const SizedBox(height: 50),
            const M3ELoadingIndicator(
              variant: M3ELoadingIndicatorVariant.defaultStyle,
              elevation: 0,
            ),
            SizedBox(height: 20),
            Text(
              _loadingMessage,
              style: TextStyle(
                fontSize: 16,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
