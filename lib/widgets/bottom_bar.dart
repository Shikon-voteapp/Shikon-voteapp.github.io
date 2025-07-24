import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shikon_voteapp/platform/platform_utils.dart';
import '../theme.dart';
import 'custom_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side navigation
          Container(
            height: 56.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(28.0),
            ),
            child: Row(
              children: [
                _buildIconButton(
                  context,
                  Icons.home_outlined,
                  onHome ?? () => _showReloadConfirmDialog(context),
                ),
                _buildDivider(context),
                _buildIconButton(
                  context,
                  Icons.help_outline,
                  () => _showHelp(context),
                ),
                _buildDivider(context),
                _buildIconButton(
                  context,
                  Icons.admin_panel_settings_outlined,
                  () => showAdminLoginDialog(context: context),
                ),
                _buildDivider(context),
                _buildIconButton(
                  context,
                  Icons.arrow_back_ios_new,
                  onBack ?? () => _showCantGoBackDialog(context),
                ),
              ],
            ),
          ),
          // Right side navigation
          if (onNext != null)
            SizedBox(
              height: 56.0,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('次へ', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback? onPressed,
  ) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(icon, color: theme.colorScheme.primary, size: 24.0),
      onPressed: onPressed,
      splashRadius: 24.0,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Container(height: 24, width: 1, color: theme.dividerColor);
  }
}
