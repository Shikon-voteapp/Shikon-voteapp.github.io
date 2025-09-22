import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:icons_plus/icons_plus.dart';
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
      );
    } else if (helpUrl != null && helpUrl!.isNotEmpty) {
      try {
        final content = await rootBundle.loadString(helpUrl!);
        // 簡単なHTMLタグを除去する処理
        final plainText =
            content
                .replaceAll(RegExp(r'<[^>]*>'), '\n') // タグを改行に
                .replaceAll('\n\n', '\n')
                .trim();
        final lines = plainText.split('\n');
        final title = lines.isNotEmpty ? lines[0] : 'ヘルプ';
        final body = lines.length > 1 ? lines.sublist(1).join('\n').trim() : '';

        showCustomDialog(
          context: context,
          title: title,
          content: body,
          closeButtonText: 'OK',
          showWikiLink: true,
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
    final theme = Theme.of(context);
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
          _buildInfoRow(
            context,
            '',
            '© 2025 明治大学付属明治高等学校　文化祭準備委員会\n© 2025 Mamouna_inori ',
          ),
          const SizedBox(height: 16),
          // SNSリンク（横並び）
          Row(
            children: [
              // Meiji Official セクション
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Meiji Official',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSmallSNSButton(
                          context: context,
                          icon: FontAwesome.x_twitter_brand,
                          onPressed:
                              () => PlatformUtils.openUrl(
                                'https://x.com/meidai_meiji',
                              ),
                        ),
                        const SizedBox(width: 8),
                        _buildSmallSNSButton(
                          context: context,
                          icon: FontAwesome.instagram_brand,
                          onPressed:
                              () => PlatformUtils.openUrl(
                                'https://www.instagram.com/meidai_meiji/',
                              ),
                        ),
                        const SizedBox(width: 8),
                        _buildSmallSNSButton(
                          context: context,
                          icon: FontAwesome.globe_solid,
                          onPressed:
                              () => PlatformUtils.openUrl(
                                'https://www.meiji.ac.jp/ko_chu/',
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Developer セクション
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Developer',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSmallSNSButton(
                          context: context,
                          icon: FontAwesome.x_twitter_brand,
                          onPressed:
                              () => PlatformUtils.openUrl(
                                'https://x.com/Mamouna_inori',
                              ),
                        ),
                        const SizedBox(width: 8),
                        _buildSmallSNSButton(
                          context: context,
                          icon: FontAwesome.instagram_brand,
                          onPressed:
                              () => PlatformUtils.openUrl(
                                'https://www.instagram.com/mamouna.inori/',
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildSmallSNSButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color backgroundColor =
        isDark ? theme.colorScheme.surface : theme.colorScheme.surface;
    final Color iconColor =
        isDark ? theme.colorScheme.onSurface : theme.colorScheme.onSurface;

    return NeumorphicButton(
      onPressed: onPressed,
      style: NeumorphicStyle(
        boxShape: const NeumorphicBoxShape.circle(),
        depth: 2,
        intensity: 0.6,
        color: backgroundColor,
      ),
      child: SizedBox(
        width: 28.0,
        height: 28.0,
        child: Center(child: Icon(icon, color: iconColor, size: 14.0)),
      ),
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
            style: NeumorphicStyle(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
              depth: 6,
              boxShape: const NeumorphicBoxShape.stadium(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6.0,
            ),
            child: Row(
              children: [
                _buildGroupedIcon(
                  context: context,
                  icon: FontAwesome.house_solid,
                  onPressed: onHome ?? () => _showReloadConfirmDialog(context),
                ),
                _buildGroupedDivider(context),
                _buildGroupedIcon(
                  context: context,
                  icon: FontAwesome.circle_question_solid,
                  onPressed: () => _showHelp(context),
                ),
                _buildGroupedDivider(context),
                _buildGroupedIcon(
                  context: context,
                  icon: FontAwesome.shield_halved_solid,
                  onPressed: () => showAdminLoginDialog(context: context),
                ),
                _buildGroupedDivider(context),
                _buildGroupedIcon(
                  context: context,
                  icon: FontAwesome.arrow_left_solid,
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
                style: NeumorphicStyle(
                  boxShape: const NeumorphicBoxShape.circle(),
                  depth: 4,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E1E1E)
                          : null,
                ),
                child: SizedBox(
                  width: 56.0,
                  height: 56.0,
                  child: GestureDetector(
                    onTap: () => _showInfoDialog(context),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Icon(
                        FontAwesome.bars_solid,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
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
                    style: NeumorphicStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                      depth: 6,
                      boxShape: const NeumorphicBoxShape.stadium(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '次へ',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          FontAwesome.arrow_right_solid,
                          size: 16,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
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
    final bool isDark = theme.brightness == Brightness.dark;
    final Color iconColor =
        onPressed == null
            ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
            : (isDark ? Colors.white : Colors.black);
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

  Widget _buildGroupedDivider(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      color:
          Theme.of(context).brightness == Brightness.dark
              ? Colors.white24
              : Colors.black12,
    );
  }
}
