import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shikon_voteapp/platform/platform_utils.dart';
import 'custom_dialog.dart';
import '../utils/version_info.dart';
import '../services/accessibility_service.dart';

class NavBarActions {
  // ─── ヘルプダイアログ ───────────────────────────────────────────
  static void showHelp({
    required BuildContext context,
    String? helpContent,
    String? helpTitle,
    String? helpUrl,
  }) async {
    if (helpContent != null && helpTitle != null) {
      showCustomDialog(
        context: context,
        title: helpTitle,
        content: helpContent,
        closeButtonText: 'OK',
        showWikiLink: true,
      );
    } else if (helpUrl != null && helpUrl.isNotEmpty) {
      try {
        final content = await rootBundle.loadString(helpUrl);
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
        showErrorDialog(context);
      }
    } else {
      showErrorDialog(context);
    }
  }

  static void showCantGoBackDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      title: 'その操作は行えません',
      content: '',
      closeButtonText: 'OK',
    );
  }

  static void showErrorDialog(BuildContext context) {
    showCustomDialog(
      context: context,
      title: '',
      content: 'ヘルプ情報を読み込めませんでした。',
      closeButtonText: 'OK',
    );
  }

  static void showReloadConfirmDialog(BuildContext context, VoidCallback? onHome) {
    showCustomDialog(
      context: context,
      title: '再読み込みしますか？',
      content: '入力中の内容は保存されません。',
      primaryActionText: '再読み込み',
      onPrimaryAction: () {
        Navigator.of(context).pop();
        if (onHome != null) {
          onHome();
        } else {
          PlatformUtils.reloadApp();
        }
      },
    );
  }

  // ─── アプリ情報ダイアログ ─────────────────────────────────────────
  static void showInfoDialog(
    BuildContext context, {
    String? infoExtraText,
    String? infoExtra2Text,
  }) {
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
              return buildMenuButton(
                context: context,
                icon: isZoomed ? Icons.zoom_out : Icons.zoom_in,
                label: isZoomed ? '文字サイズを元に戻す (100%)' : '文字サイズを大きくする (150%)',
                onTap: () {
                  AccessibilityService.toggleZoom();
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showInfoDialog(context, infoExtraText: infoExtraText, infoExtra2Text: infoExtra2Text);
                  });
                },
              );
            },
          ),
          const SizedBox(height: 12),
          buildInfoRow(context, 'Version', VersionInfo.fullVersion),
          const SizedBox(height: 12),
          buildInfoRow(context, 'Data Update', VersionInfo.formattedBuildDate),
          const SizedBox(height: 12),
          buildInfoRow(
            context,
            '',
            '© 2025 明治大学付属明治高等学校　文化祭準備委員会\n© 2025 Mamouna_inori ',
          ),
          if (infoExtraText != null && infoExtraText.isNotEmpty) ...[
            const SizedBox(height: 12),
            buildInfoRow(context, '', infoExtraText),
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
                        buildSmallSNSButton(
                          context: context,
                          icon: FontAwesomeIcons.xTwitter,
                          onPressed: () => PlatformUtils.openUrl('https://x.com/meidai_meiji'),
                        ),
                        buildSmallSNSButton(
                          context: context,
                          icon: FontAwesomeIcons.instagram,
                          onPressed: () => PlatformUtils.openUrl('https://www.instagram.com/meidai_meiji/'),
                        ),
                        buildSmallSNSButton(
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
                        buildSmallSNSButton(
                          context: context,
                          icon: FontAwesomeIcons.xTwitter,
                          onPressed: () => PlatformUtils.openUrl('https://x.com/Mamouna_inori'),
                        ),
                        buildSmallSNSButton(
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

  // ─── ≡ メニューダイアログ ───────────────────────────────────────────
  static void showMenuDialog({
    required BuildContext context,
    VoidCallback? onHome,
    String? helpContent,
    String? helpTitle,
    String? helpUrl,
    String? infoExtraText,
    String? infoExtra2Text,
  }) {
    showCustomDialog(
      context: context,
      title: 'メニュー',
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildMenuButton(
            context: context,
            icon: Icons.home_outlined,
            label: 'ホーム（再読み込み）',
            onTap: () {
              Navigator.of(context).pop();
              showReloadConfirmDialog(context, onHome);
            },
          ),
          const SizedBox(height: 10),
          buildMenuButton(
            context: context,
            icon: Icons.help_outline,
            label: 'ヘルプ',
            onTap: () {
              Navigator.of(context).pop();
              showHelp(
                context: context,
                helpContent: helpContent,
                helpTitle: helpTitle,
                helpUrl: helpUrl,
              );
            },
          ),
          const SizedBox(height: 10),
          buildMenuButton(
            context: context,
            icon: Icons.admin_panel_settings,
            label: '管理者ログイン',
            onTap: () {
              Navigator.of(context).pop();
              showAdminLoginDialog(context: context);
            },
          ),
          const SizedBox(height: 10),
          buildMenuButton(
            context: context,
            icon: Icons.info_outline,
            label: 'アプリ情報',
            onTap: () {
              Navigator.of(context).pop();
              showInfoDialog(
                context,
                infoExtraText: infoExtraText,
                infoExtra2Text: infoExtra2Text,
              );
            },
          ),
        ],
      ),
      closeButtonText: '閉じる',
    );
  }

  static Widget buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: M3ECard(
        variant: M3ECardVariant.filled,
        borderRadius: BorderRadius.circular(20.0),
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
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
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildInfoRow(
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

  static Widget buildSmallSNSButton({
    required BuildContext context,
    required dynamic icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: theme.colorScheme.surface,
        elevation: 2,
        padding: EdgeInsets.zero,
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

  static Widget buildCircleButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return M3EIconButton(
      icon: Icon(icon, size: 22.0),
      onPressed: onPressed,
      size: M3EIconButtonSize.sm,
      variant: M3EIconButtonVariant.tonal,
      shape: M3EIconButtonShapeVariant.round,
    );
  }
}

// ─── 横型ボトムバー（スマートフォン用） ────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    final bool hasNext = onNext != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ─ 左：戻るボタン ─────────────────────────
            NavBarActions.buildCircleButton(
              context: context,
              icon: Icons.arrow_back,
              onPressed: onBack ?? () => NavBarActions.showCantGoBackDialog(context),
            ),

            // ─ 中央：アクションピルボタン ──────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  height: 48.0,
                  child: M3EButton(
                    onPressed: hasNext ? onNext : null,
                    style: hasNext ? M3EButtonStyle.filled : M3EButtonStyle.tonal,
                    size: M3EButtonSize.md,
                    shape: M3EButtonShape.round,
                    child: Center(
                      child: nextLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: M3ELoadingIndicator(
                                variant: M3ELoadingIndicatorVariant.defaultStyle,
                                elevation: 0,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  nextLabel,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (hasNext) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, size: 16),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // ─ 右：≡ メニューボタン ──────────────────
            NavBarActions.buildCircleButton(
              context: context,
              icon: Icons.menu,
              onPressed: () => NavBarActions.showMenuDialog(
                context: context,
                onHome: onHome,
                helpContent: helpContent,
                helpTitle: helpTitle,
                helpUrl: helpUrl,
                infoExtraText: infoExtraText,
                infoExtra2Text: infoExtra2Text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 縦型ナビゲーションバー（Fold・タブレット・PC用：右端設置） ──────────────────
class VerticalNavBar extends StatelessWidget {
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

  const VerticalNavBar({
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasNext = onNext != null;

    return Container(
      width: 76.0,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          left: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        left: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─ 上：≡ メニューボタン ──────────────────
              NavBarActions.buildCircleButton(
                context: context,
                icon: Icons.menu,
                onPressed: () => NavBarActions.showMenuDialog(
                  context: context,
                  onHome: onHome,
                  helpUrl: helpUrl,
                  helpTitle: helpTitle,
                  helpContent: helpContent,
                  infoExtraText: infoExtraText,
                  infoExtra2Text: infoExtra2Text,
                ),
              ),
              const SizedBox(height: 12.0),

              // ─ 中央：縦型アクションピルボタン（上下全幅） ──────────
              Expanded(
                child: SizedBox(
                  width: 52.0,
                  height: double.infinity,
                  child: Material(
                    color: hasNext
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(26.0),
                    elevation: hasNext ? 2.0 : 0.0,
                    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.35),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: hasNext ? onNext : null,
                      child: Center(
                        child: nextLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: M3ELoadingIndicator(
                                  variant: M3ELoadingIndicatorVariant.defaultStyle,
                                  elevation: 0,
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...nextLabel.characters.map(
                                    (char) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                                      child: Text(
                                        char,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: hasNext
                                              ? theme.colorScheme.onPrimary
                                              : theme.colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 18.0,
                                    color: hasNext
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSecondaryContainer,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),

              // ─ 下：戻るボタン ─────────────────────────
              NavBarActions.buildCircleButton(
                context: context,
                icon: Icons.arrow_back,
                onPressed: onBack ?? () => NavBarActions.showCantGoBackDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
