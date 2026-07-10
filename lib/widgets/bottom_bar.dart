import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
import 'liquid_glass.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shikon_voteapp/platform/platform_utils.dart';
import 'custom_dialog.dart';
import '../utils/version_info.dart';
import '../services/accessibility_service.dart';

class BottomBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool nextLoading;
  final String? helpUrl;
  final String? helpTitle;
  final String? helpContent;
  final VoidCallback? onHome;
  final String? infoExtraText;
  final String? infoExtra2Text;

  const BottomBar({
    Key? key,
    this.onBack,
    this.onNext,
    this.nextLabel = '次へ',
    this.nextLoading = false,
    this.helpUrl,
    this.helpTitle,
    this.helpContent,
    this.onHome,
    this.infoExtraText,
    this.infoExtra2Text,
  }) : super(key: key);

  // ─── ヘルプダイアログ ───────────────────────────────────────────
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
        final plainText =
            content
                .replaceAll(RegExp(r'<[^>]*>'), '\n')
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
        Navigator.of(context).pop();
        PlatformUtils.reloadApp();
      },
    );
  }

  // ─── アプリ情報ダイアログ ─────────────────────────────────────────
  void _showInfoDialog(BuildContext context) {
    final theme = Theme.of(context);
    showCustomDialog(
      context: context,
      title: 'アプリ情報',
      contentWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: AccessibilityService.isZoomed,
            builder: (context, isZoomed, _) {
              return _buildMenuButton(
                context: context,
                icon: isZoomed ? Icons.zoom_out : Icons.zoom_in,
                label: isZoomed ? '文字サイズを元に戻す (100%)' : '文字サイズを大きくする (150%)',
                onTap: () {
                  AccessibilityService.toggleZoom();
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showInfoDialog(context);
                  });
                },
              );
            },
          ),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Version', VersionInfo.fullVersion),
          const SizedBox(height: 12),
          _buildInfoRow(context, 'Data Update', VersionInfo.formattedBuildDate),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            '',
            '© 2025 明治大学付属明治高等学校　文化祭準備委員会\n© 2025 Mamouna_inori ',
          ),
          if (infoExtraText != null && infoExtraText!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(context, '', infoExtraText!),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Meiji Official',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSmallSNSButton(
                          context: context,
                          icon: FontAwesomeIcons.xTwitter,
                          onPressed: () => PlatformUtils.openUrl('https://x.com/meidai_meiji'),
                        ),
                        _buildSmallSNSButton(
                          context: context,
                          icon: FontAwesomeIcons.instagram,
                          onPressed: () => PlatformUtils.openUrl('https://www.instagram.com/meidai_meiji/'),
                        ),
                        _buildSmallSNSButton(
                          context: context,
                          icon: Icons.public,
                          onPressed: () => PlatformUtils.openUrl('https://www.meiji.ac.jp/ko_chu/'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Developer',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSmallSNSButton(
                          context: context,
                          icon: FontAwesomeIcons.xTwitter,
                          onPressed: () => PlatformUtils.openUrl('https://x.com/Mamouna_inori'),
                        ),
                        _buildSmallSNSButton(
                          context: context,
                          icon: FontAwesomeIcons.instagram,
                          onPressed: () => PlatformUtils.openUrl('https://www.instagram.com/mamouna.inori/'),
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

  // ─── ≡ メニューダイアログ（ホーム・ヘルプ・ログイン・詳細情報） ─────────
  void _showMenuDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      title: 'メニュー',
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMenuButton(
            context: context,
            icon: Icons.home_outlined,
            label: 'ホーム（再読み込み）',
            onTap: () {
              Navigator.of(context).pop();
              if (onHome != null) {
                onHome!();
              } else {
                _showReloadConfirmDialog(context);
              }
            },
          ),
          const SizedBox(height: 10),
          _buildMenuButton(
            context: context,
            icon: Icons.help_outline,
            label: 'ヘルプ',
            onTap: () {
              Navigator.of(context).pop();
              _showHelp(context);
            },
          ),
          const SizedBox(height: 10),
          _buildMenuButton(
            context: context,
            icon: Icons.admin_panel_settings,
            label: '管理者ログイン',
            onTap: () {
              Navigator.of(context).pop();
              showAdminLoginDialog(context: context);
            },
          ),
          const SizedBox(height: 10),
          _buildMenuButton(
            context: context,
            icon: Icons.info_outline,
            label: 'アプリ情報',
            onTap: () {
              Navigator.of(context).pop();
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      closeButtonText: '閉じる',
    );
  }

  // ─── ユーティリティ Widget ────────────────────────────────────────
  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return LiquidGlassLayer(
      settings: LiquidGlassSettings(
        glassColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04),
        thickness: 8.0,
        blur: 10.0,
      ),
      child: LiquidGlass(
        shape: LiquidRoundedRectangle(borderRadius: 24.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.onSurface),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
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
              color: isClickable ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              decoration: isClickable ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallSNSButton({
    required BuildContext context,
    required dynamic icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return NeumorphicButton(
      onPressed: onPressed,
      style: NeumorphicStyle(
        boxShape: const NeumorphicBoxShape.circle(),
        depth: 2,
        intensity: 0.6,
        color: theme.colorScheme.surface,
      ),
      child: SizedBox(
        width: 28.0,
        height: 28.0,
        child: Center(
          child: icon is IconData
              ? Icon(icon, color: theme.colorScheme.onSurface, size: 14.0)
              : FaIcon(icon, color: theme.colorScheme.onSurface, size: 14.0),
        ),
      ),
    );
  }

  // ─── ボトムバーの丸アイコンボタン ──────────────────────────────────
  Widget _buildCircleButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glassColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
    final iconColor = onPressed == null
        ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
        : (isDark ? Colors.white : Colors.black);

    return LiquidGlassLayer(
      settings: LiquidGlassSettings(
        glassColor: glassColor,
        thickness: 12.0,
        blur: 18.0,
      ),
      child: LiquidGlass(
        shape: LiquidRoundedRectangle(borderRadius: 28.0),
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 56.0,
            height: 56.0,
            child: Center(
              child: Icon(icon, color: iconColor, size: 24.0),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    // 中央ピルのスタイル（フロアフィルターと同じガラス系）
    final bool hasNext = onNext != null;

    // コンテナのガラスベース色（フロアフィルターと同じ）
    final Color pillGlassBase = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);

    // アクティブ時の薄い紫オーバーレイ
    final Color pillActiveOverlay = hasNext
        ? primary.withValues(alpha: 0.30)
        : Colors.transparent;

    // テキスト・アイコン色
    final Color pillFg = hasNext
        ? (isDark ? Colors.white : primary)
        : theme.colorScheme.onSurface.withValues(alpha: 0.35);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─ 左：戻るボタン ─────────────────────────
          _buildCircleButton(
            context: context,
            icon: Icons.arrow_back,
            onPressed: onBack ?? () => _showCantGoBackDialog(context),
          ),

          // ─ 中央：アクションピルボタン ──────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: LiquidGlassLayer(
                settings: LiquidGlassSettings(
                  glassColor: pillGlassBase,
                  thickness: 15.0,
                  blur: 20.0,
                ),
                child: LiquidGlass(
                  shape: LiquidRoundedRectangle(borderRadius: 28.0),
                  child: InkWell(
                    onTap: hasNext ? onNext : null,
                    borderRadius: BorderRadius.circular(28.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 56.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: pillActiveOverlay,
                        borderRadius: BorderRadius.circular(28.0),
                        border: Border.all(
                          color: hasNext
                              ? primary.withValues(alpha: 0.5)
                              : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      child: nextLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: pillFg,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  nextLabel,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: pillFg,
                                  ),
                                ),
                                if (hasNext) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 16, color: pillFg),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─ 右：≡ メニューボタン ──────────────────
          _buildCircleButton(
            context: context,
            icon: Icons.menu,
            onPressed: () => _showMenuDialog(context),
          ),
        ],
      ),
    );
  }
}
