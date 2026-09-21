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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String _loadingMessage = '起動準備中...';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _initialize();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await waitForWebFonts();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _loadingMessage = '起動準備をしています...');
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loadingMessage = '画面の準備をしています...');
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _loadingMessage = 'まもなく起動します...');
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アイコン
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.how_to_vote_rounded,
                  size: 52,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '紫紺祭投票アプリ',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 48),
              // M3E Expressive ローディングインジケーター
              const M3ELoadingIndicator(
                variant: M3ELoadingIndicatorVariant.defaultStyle,
                elevation: 0,
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _loadingMessage,
                  key: ValueKey(_loadingMessage),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
