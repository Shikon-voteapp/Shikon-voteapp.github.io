import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import 'scanner_screen.dart';
import '../platform/platform_utils.dart';
import '../widgets/custom_dialog.dart';
import '../config/vote_options.dart';
import '../widgets/liquid_glass.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final glassColor = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);

    return MainLayout(
      title: 'ようこそ',
      icon: Icons.pan_tool_alt,
      onHome: () => PlatformUtils.reloadApp(),
      helpTitle: '投票について',
      helpContent: '「投票を開始する」ボタンを押して、投票を開始してください。パンフレットに同封された投票券をご準備ください。',
      onNext: () {
        final now = DateTime.now();
        final isOutdated = now.difference(dataUpdateDate).inDays >= 180;
        if (isOutdated) {
          bool didReload = false;
          showCustomDialog(
            context: context,
            title: '再読み込みをしてください',
            content:
                'このアプリのデータが古い可能性があります。最新のデータを取得するため、キャッシュを破棄して再読み込みを行ってください。\n3秒後に再読み込みをします...',
            closeButtonText: null,
            primaryActionText: 'キャッシュを破棄して再読み込み',
            enablePrimaryLoading: true,
            minLoadingMs: 800,
            maxLoadingMs: 1400,
            onPrimaryAction: () {
              if (!didReload) {
                didReload = true;
                PlatformUtils.clearCacheAndReload();
              }
            },
          );
          Timer(const Duration(seconds: 3), () {
            if (!didReload) {
              didReload = true;
              PlatformUtils.clearCacheAndReload();
            }
          });
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ScannerScreen(),
          ),
        );
      },
      nextLabel: '投票を開始する',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              LiquidGlassLayer(
                settings: LiquidGlassSettings(
                  glassColor: glassColor,
                  thickness: 15.0,
                  blur: 20.0,
                ),
                child: LiquidGlass(
                  shape: LiquidRoundedRectangle(
                    borderRadius: 24.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.how_to_vote,
                            size: 40,
                            color: isDark ? Colors.white : colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '紫紺祭投票アプリ',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '紫紺祭へのご来場ありがとうございます。パンフレットに同封された投票券をお手元にご準備の上、下の「投票を開始する」ボタンから進んでください。',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildCreditText(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditText(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: '© 2025 明治高校文化祭準備委員会',
          style: TextStyle(
            fontSize: 11,
            height: 1.6,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

