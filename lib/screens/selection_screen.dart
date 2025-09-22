import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import 'scanner_screen.dart';
import '../platform/platform_utils.dart';
import '../widgets/custom_dialog.dart';
import '../config/vote_options.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'ようこそ',
      icon: Icons.pan_tool_alt,
      onHome: () => PlatformUtils.reloadApp(),
      helpTitle: '投票について',
      helpContent: '「投票を開始する」ボタンを押して、投票を開始してください。パンフレットに同封された投票券をご準備ください。',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildModeButton(
              context: context,
              title: '投票を開始する',
              subtitle: '投票を行います。パンフレットに同封された投票券をご準備ください。',
              icon: Icons.how_to_vote,
              onPressed: () {
                final now = DateTime.now();
                final isOutdated = now.difference(dataUpdateDate).inDays >= 365;
                if (isOutdated) {
                  showCustomDialog(
                    context: context,
                    title: '再読み込みをしてください',
                    content:
                        'このアプリのデータが古い可能性があります。最新のデータを取得するため、キャッシュを破棄して再読み込みを行ってください。',
                    closeButtonText: null,
                    primaryActionText: 'キャッシュを破棄して再読み込み',
                    enablePrimaryLoading: true,
                    minLoadingMs: 800,
                    maxLoadingMs: 1400,
                    onPrimaryAction: () {
                      PlatformUtils.clearCacheAndReload();
                    },
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScannerScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            _buildCreditText(context),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isDark
                ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    spreadRadius: 2,
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: Neumorphic(
        style: NeumorphicStyle(color: Colors.transparent, depth: 0),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: isDark ? Colors.white : colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
          style: TextStyle(
            fontSize: 12,
            height: 1.6,
            fontFamily: 'A-OTF-ShinGoPr6',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          children: const [
            TextSpan(
              text: '本アプリケーションは、生徒有志により開発・運営されています。\n',
              style: TextStyle(fontFamily: 'A-OTF-ShinGoPr6'),
            ),
            TextSpan(
              text: 'オープンソースで開発されており、ソースコードはGitHubにて公開されています。',
              style: TextStyle(fontFamily: 'A-OTF-ShinGoPr6'),
            ),
          ],
        ),
      ),
    );
  }
}
