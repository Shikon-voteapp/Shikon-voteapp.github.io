import 'package:flutter/material.dart';
import 'package:shikon_voteapp/platform/platform_utils.dart';
import 'package:shikon_voteapp/screens/help_screen.dart';
import '../theme.dart';
import 'custom_dialog.dart';

class BottomBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? helpUrl;

  const BottomBar({Key? key, this.onBack, this.onNext, this.helpUrl})
    : super(key: key);

  void _showHelp(BuildContext context) {
    if (helpUrl != null && helpUrl!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => HelpScreen(url: helpUrl!)),
      );
    } else {
      _showErrorDialog(context);
    }
  }

  void _showCantGoBackDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      title: 'これ以上戻れません',
      content: 'この画面が最初の画面です。',
      closeButtonText: 'OK',
    );
  }

  void _showErrorDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      title: 'エラー',
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
              color: AppTheme.widgetBackgroundColor,
              borderRadius: BorderRadius.circular(28.0),
            ),
            child: Row(
              children: [
                _buildIconButton(
                  Icons.home_outlined,
                  () => _showReloadConfirmDialog(context),
                ),
                _buildDivider(),
                _buildIconButton(Icons.help_outline, () => _showHelp(context)),
                _buildDivider(),
                _buildIconButton(
                  Icons.admin_panel_settings_outlined,
                  () => showAdminLoginDialog(context: context),
                ),
                _buildDivider(),
                _buildIconButton(
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
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
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

  Widget _buildIconButton(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      icon: Icon(icon, color: AppTheme.primaryColor, size: 24.0),
      onPressed: onPressed,
      splashRadius: 24.0,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.grey.shade300);
  }
}
