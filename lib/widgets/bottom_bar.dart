import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shikon_voteapp/platform/platform_utils.dart';
import 'custom_dialog.dart';
import '../utils/version_info.dart';

class BottomBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? helpUrl;
  final String? helpTitle;
  final String? helpContent;
  final VoidCallback? onHome;

  const BottomBar({
    Key? key,
    this.onBack,
    this.onNext,
    this.helpUrl,
    this.helpTitle,
    this.helpContent,
    this.onHome,
  }) : super(key: key);

  void _showHelp(BuildContext context) async {
    if (helpContent != null && helpTitle != null) {
      showCustomDialog(
        context: context,
        title: helpTitle!,
        content: helpContent!,
        closeButtonText: 'OK',
        showWikiLink: true,
        imagePath: 'assets/sho_setsumei.png',
      );
    } else if (helpUrl != null && helpUrl!.isNotEmpty) {
      try {
        final content = await rootBundle.loadString(helpUrl!);
        // 簡単なHTMLタグを除去する処理
        final plainText =
            content
                .replaceAll(RegExp(r'<[^>]*>'), '\\n') // タグを改行に
                .replaceAll('\\n\\n', '\\n')
                .trim();
        final lines = plainText.split('\\n');
        final title = lines.isNotEmpty ? lines[0] : 'ヘルプ';
        final body =
            lines.length > 1 ? lines.sublist(1).join('\\n').trim() : '';

        showCustomDialog(
          context: context,
          title: title,
          content: body,
          closeButtonText: 'OK',
          showWikiLink: true,
          imagePath: 'assets/sho_setsumei.png',
        );
      } catch (e) {
        _showErrorDialog(context);
      }
    } else {
      _showErrorDialog(context);
    }
  }

  void _showCantGoBackDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      title: 'その操作は行えません',
      content: '',
      closeButtonText: 'OK',
    );
  }

  void _showErrorDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      title: '',
      content: 'ヘルプ情報を読み込めませんでした。',
      closeButtonText: 'OK',
    );
  }

  void _showReloadConfirmDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      title: '再読み込みしますか？',
      content: '入力中の内容は保存されません。',
      primaryActionText: '再読み込み',
      onPrimaryAction: () {
        Navigator.of(context).pop(); // Close dialog
        PlatformUtils.reloadApp();
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      title: 'アプリ情報',
      contentWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow(context, 'Version', VersionInfo.fullVersion),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Data Update', VersionInfo.formattedBuildDate),
          const SizedBox(height: 12),
          _buildInfoRow(context, '', '© 2025 文化祭準備委員会\n© 2025 Mamouna_inori '),
        ],
      ),
      closeButtonText: '閉じる',
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isClickable = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color:
                  isClickable
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
              decoration: isClickable ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side navigation
          Neumorphic(
            style: const NeumorphicStyle(
              color: Colors.white,
              depth: 6,
              boxShape: NeumorphicBoxShape.stadium(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6.0,
            ),
            child: Row(
              children: [
                _buildGroupedIcon(
                  context: context,
                  icon: HugeIcons.strokeRoundedHome03,
                  onPressed: onHome ?? () => _showReloadConfirmDialog(context),
                ),
                _buildGroupedDivider(),
                _buildGroupedIcon(
                  context: context,
                  icon: HugeIcons.strokeRoundedQuestion,
                  onPressed: () => _showHelp(context),
                ),
                _buildGroupedDivider(),
                _buildGroupedIcon(
                  context: context,
                  icon: HugeIcons.strokeRoundedShield01,
                  onPressed: () => showAdminLoginDialog(context: context),
                ),
                _buildGroupedDivider(),
                _buildGroupedIcon(
                  context: context,
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  onPressed: onBack ?? () => _showCantGoBackDialog(context),
                ),
              ],
            ),
          ),
          // Right side navigation
          Row(
            children: [
              // Info button (hamburger menu)
              Neumorphic(
                style: const NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 4,
                ),
                child: SizedBox(
                  width: 56.0,
                  height: 56.0,
                  child: GestureDetector(
                    onTap: () => _showInfoDialog(context),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Icon(
                        HugeIcons.strokeRoundedMenu01,
                        color: Colors.black,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Next button
              if (onNext != null)
                SizedBox(
                  height: 56.0,
                  child: NeumorphicButton(
                    onPressed: onNext,
                    style: const NeumorphicStyle(
                      color: Colors.white,
                      depth: 6,
                      boxShape: NeumorphicBoxShape.stadium(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '次へ',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          HugeIcons.strokeRoundedArrowRight01,
                          size: 16,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedIcon({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final Color iconColor =
        onPressed == null
            ? theme.colorScheme.onSurface.withOpacity(0.4)
            : Colors.black;
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Icon(icon, color: iconColor, size: 22.0),
        ),
      ),
    );
  }

  Widget _buildGroupedDivider() {
    return Container(height: 24, width: 1, color: Colors.black12);
  }
}
