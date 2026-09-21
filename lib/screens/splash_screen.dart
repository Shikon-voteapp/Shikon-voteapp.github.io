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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutBack,
      ),
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
    // Webフォントの読み込み完了まで待機（非Webは即時）
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
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
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // アプリアイコン（M3E角丸スタイル）
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.how_to_vote_rounded,
                    size: 56,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  '紫紺祭投票アプリ',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 48),
                // M3E Expressive ローディングインジケーター（Containedモーフィングアニメーション）
                M3ELoadingIndicator(
                  variant: M3ELoadingIndicatorVariant.contained,
                  elevation: 2,
                  color: colorScheme.primary,
                  containerColor: colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _loadingMessage,
                    key: ValueKey(_loadingMessage),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
