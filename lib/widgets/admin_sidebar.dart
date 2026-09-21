import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'admin_mode_selection.dart';

class AdminSidebar extends StatelessWidget {
  final AdminMode currentMode;
  final Function(AdminMode) onSelectMode;
  final VoidCallback onDownloadManual;
  final VoidCallback onRefresh;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  final bool isDark;

  const AdminSidebar({
    super.key,
    required this.currentMode,
    required this.onSelectMode,
    required this.onDownloadManual,
    required this.onRefresh,
    required this.onToggleTheme,
    required this.onLogout,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarBg = theme.colorScheme.surfaceContainer;
    final borderColor = theme.colorScheme.outlineVariant;

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: sidebarBg,
        border: Border(
          right: BorderSide(color: borderColor, width: 1.2),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // 上部アプリアイコン（添付画像の最上部ピル）
            _buildTopIcon(theme),
            const SizedBox(height: 20),

            // ナビゲーションアイテム一覧
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildNavItem(
                      icon: Icons.home_rounded,
                      label: 'ホーム',
                      isSelected: currentMode == AdminMode.menu,
                      onTap: () => onSelectMode(AdminMode.menu),
                      theme: theme,
                    ),
                    const SizedBox(height: 14),
                    _buildNavItem(
                      icon: Icons.bar_chart_rounded,
                      label: '投票結果',
                      isSelected: currentMode == AdminMode.results,
                      onTap: () => onSelectMode(AdminMode.results),
                      theme: theme,
                    ),
                    const SizedBox(height: 14),
                    _buildNavItem(
                      icon: Icons.playlist_add_check_rounded,
                      label: '一括追加',
                      isSelected: currentMode == AdminMode.batchVote,
                      onTap: () => onSelectMode(AdminMode.batchVote),
                      theme: theme,
                    ),
                    const SizedBox(height: 14),
                    _buildNavItem(
                      icon: Icons.manage_accounts_rounded,
                      label: 'ユーザー',
                      isSelected: currentMode == AdminMode.userManagement,
                      onTap: () => onSelectMode(AdminMode.userManagement),
                      theme: theme,
                    ),
                    const SizedBox(height: 14),
                    _buildNavItem(
                      icon: Icons.block_rounded,
                      label: '番号無効化',
                      isSelected: currentMode == AdminMode.invalidateVote,
                      onTap: () => onSelectMode(AdminMode.invalidateVote),
                      theme: theme,
                    ),
                    const SizedBox(height: 14),
                    _buildNavItem(
                      icon: Icons.menu_book_rounded,
                      label: 'マニュアル',
                      isSelected: false,
                      badgeDot: true,
                      onTap: onDownloadManual,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),

            // 下部アクションボタングループ（添付画像の下部丸型ボタン）
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  _buildCircleActionButton(
                    icon: Icons.refresh_rounded,
                    tooltip: 'データ更新',
                    onTap: onRefresh,
                    theme: theme,
                  ),
                  const SizedBox(height: 14),
                  _buildCircleActionButton(
                    icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    tooltip: isDark ? 'ライトモード' : 'ダークモード',
                    onTap: onToggleTheme,
                    theme: theme,
                  ),
                  const SizedBox(height: 14),
                  _buildCircleActionButton(
                    icon: Icons.logout_rounded,
                    tooltip: 'ログアウト',
                    onTap: onLogout,
                    theme: theme,
                    isDanger: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 添付画像の一番上の丸角正方形アイコン
  Widget _buildTopIcon(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF6D28D9).withValues(alpha: 0.35)
            : const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark
              ? const Color(0xFFA78BFA).withValues(alpha: 0.4)
              : const Color(0xFFDDD6FE),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.admin_panel_settings_rounded,
          color: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9),
          size: 24,
        ),
      ),
    );
  }

  // 各ナビゲーションアイテム（アイコンが上、ラベルが下、選択時はアイコンに角丸ピル背景）
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    bool badgeDot = false,
  }) {
    final activeBg = theme.colorScheme.primaryContainer;
    final activeColor = theme.colorScheme.onPrimaryContainer;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return Tooltip(
      message: label,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: 46,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? activeBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 22,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
                    ),
                  ),
                  if (badgeDot)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 添付画像下部の丸型アクションボタン
  Widget _buildCircleActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isDanger = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: M3EIconButton(
        icon: Icon(
          icon,
          size: 20,
          color: isDanger ? theme.colorScheme.error : null,
        ),
        onPressed: onTap,
        size: M3EIconButtonSize.sm,
        variant: isDanger ? M3EIconButtonVariant.outlined : M3EIconButtonVariant.tonal,
        shape: M3EIconButtonShapeVariant.round,
      ),
    );
  }
}
