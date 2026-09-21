import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'liquid_glass.dart';

enum AdminMode {
  menu,
  results,
  userManagement,
  batchVote,
  invalidateVote,
}

class AdminModeSelection extends StatelessWidget {
  final Function(AdminMode) onSelectMode;
  final VoidCallback onDownloadManual;
  final int voteCount;
  final int adminUserCount;

  const AdminModeSelection({
    super.key,
    required this.onSelectMode,
    required this.onDownloadManual,
    this.voteCount = 0,
    this.adminUserCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ヘッダーセクション
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '管理者メニュー',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '実行したい操作を選択してください',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // モード選択カード一覧
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 650;
                  final cardWidth = isWide ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth;

                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildModeCard(
                        context: context,
                        width: cardWidth,
                        icon: Icons.bar_chart_rounded,
                        title: '投票結果の確認',
                        subtitle: '各賞の得票数集計、グラフ表示、Excel形式でのデータ出力',
                        badgeText: '$voteCount 票集計済',
                        accentColor: const Color(0xFF2563EB),
                        actionLabel: '開く',
                        onTap: () => onSelectMode(AdminMode.results),
                      ),
                      _buildModeCard(
                        context: context,
                        width: cardWidth,
                        icon: Icons.playlist_add_check_rounded,
                        title: '投票の一括追加',
                        subtitle: '10件までの投票データをマトリックス形式で一括入力・登録',
                        badgeText: '新機能',
                        accentColor: const Color(0xFF059669),
                        actionLabel: '開く',
                        onTap: () => onSelectMode(AdminMode.batchVote),
                      ),
                      _buildModeCard(
                        context: context,
                        width: cardWidth,
                        icon: Icons.manage_accounts_rounded,
                        title: '管理者ユーザー管理',
                        subtitle: '管理者アカウントの一覧、新規管理者の追加',
                        badgeText: '$adminUserCount 名登録済',
                        accentColor: const Color(0xFFD97706),
                        actionLabel: '開く',
                        onTap: () => onSelectMode(AdminMode.userManagement),
                      ),
                      _buildModeCard(
                        context: context,
                        width: cardWidth,
                        icon: Icons.block_rounded,
                        title: '投票番号の無効化',
                        subtitle: '紛失・汚損・再発行・不正利用等の投票番号を無効化および復元',
                        badgeText: '新機能',
                        accentColor: const Color(0xFFDC2626),
                        actionLabel: '開く',
                        onTap: () => onSelectMode(AdminMode.invalidateVote),
                      ),
                      _buildModeCard(
                        context: context,
                        width: cardWidth,
                        icon: Icons.picture_as_pdf_rounded,
                        title: 'マニュアルダウンロード',
                        subtitle: '文化祭セットアップマニュアル(PDF)を新しいタブで表示・ダウンロード',
                        badgeText: 'PDF',
                        accentColor: const Color(0xFFE11D48),
                        actionLabel: '別タブで開く',
                        actionIcon: Icons.open_in_new_rounded,
                        onTap: onDownloadManual,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required double width,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color accentColor,
    required String actionLabel,
    IconData actionIcon = Icons.arrow_forward_rounded,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: M3ECard(
          variant: M3ECardVariant.elevated,
          elevation: 2.0,
          borderRadius: BorderRadius.circular(20.0),
          onPressed: onTap,
          padding: const EdgeInsets.all(22.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  actionLabel,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  actionIcon,
                  color: accentColor,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
