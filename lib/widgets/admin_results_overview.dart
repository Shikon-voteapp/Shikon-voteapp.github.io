import 'package:flutter/material.dart';
import '../config/vote_options.dart';
import '../models/group.dart' hide VoteCategory;
import '../models/vote_category.dart';

/// 投票結果のサマリー（各賞のトップ順位と総投票数）一覧画面
class AdminResultsOverview extends StatelessWidget {
  final List<dynamic>? votes;
  final bool excludeShikonTop2;
  final ValueChanged<bool> onExcludeShikonTop2Changed;
  final void Function(int categoryIndex) onSelectCategory;
  final List<MapEntry<Group, int>> Function(String categoryId, {bool? applyShikonExclusion}) getSortedResults;
  final int Function(String categoryId) getTotalCategoryVotes;
  final Set<String> Function() getShikonTop2GroupIds;

  const AdminResultsOverview({
    super.key,
    required this.votes,
    required this.excludeShikonTop2,
    required this.onExcludeShikonTop2Changed,
    required this.onSelectCategory,
    required this.getSortedResults,
    required this.getTotalCategoryVotes,
    required this.getShikonTop2GroupIds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalBallots = votes?.length ?? 0;

    // 紫紺賞とそれ以外の賞を分離
    final shikonIndex = voteCategories.indexWhere((c) => c.id == 'Shikon_award');
    final shikonCategory = shikonIndex != -1 ? voteCategories[shikonIndex] : null;

    final otherCategories = <MapEntry<int, VoteCategory>>[];
    for (int i = 0; i < voteCategories.length; i++) {
      if (i != shikonIndex) {
        otherCategories.add(MapEntry(i, voteCategories[i]));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── ヘッダー案内 ──────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.insights_rounded, color: colorScheme.onPrimaryContainer, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '投票結果サマリー',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '各賞の上位順位と総投票数一覧です。カードをタップすると詳細結果を表示します。',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.how_to_vote_rounded, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '総投票者: $totalBallots 人',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── 1. 紫紺賞カード ───────────────────────────
              if (shikonCategory != null) ...[
                _buildAwardCard(
                  context: context,
                  category: shikonCategory,
                  categoryIndex: shikonIndex,
                  isShikon: true,
                  results: getSortedResults(shikonCategory.id, applyShikonExclusion: false),
                  totalVotes: getTotalCategoryVotes(shikonCategory.id),
                  maxDisplayRank: 2, // 紫紺賞は1位・2位
                ),
                const SizedBox(height: 12),
              ],

              // ─── 2. 紫紺賞除外トグルバー ──────────────────────
              _buildExclusionToggleBar(context),
              const SizedBox(height: 16),

              // ─── 3. その他の賞カード一覧 ──────────────────────
              ...otherCategories.map((entry) {
                final categoryIndex = entry.key;
                final category = entry.value;
                final results = getSortedResults(category.id);
                final totalVotes = getTotalCategoryVotes(category.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: _buildAwardCard(
                    context: context,
                    category: category,
                    categoryIndex: categoryIndex,
                    isShikon: false,
                    results: results,
                    totalVotes: totalVotes,
                    maxDisplayRank: 3, // 他の賞は1位・2位・3位
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// 賞カードの構築
  Widget _buildAwardCard({
    required BuildContext context,
    required VoteCategory category,
    required int categoryIndex,
    required bool isShikon,
    required List<MapEntry<Group, int>> results,
    required int totalVotes,
    required int maxDisplayRank,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bool isShikonCard = isShikon == true;

    // 紫紺賞カードは特別感のあるボーダーと背景
    final borderColor = isShikonCard
        ? (isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5))
        : colorScheme.outlineVariant.withValues(alpha: 0.6);

    final cardBgColor = isShikonCard
        ? (isDark
            ? colorScheme.surfaceContainerHigh
            : const Color(0xFFF5F3FF)) // ほんのり紫がかった背景
        : colorScheme.surfaceContainer;

    // 上位ランクの抽出
    final displayEntries = results.take(maxDisplayRank).toList();

    return Material(
      color: cardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: borderColor,
          width: isShikonCard ? 1.8 : 1.0,
        ),
      ),
      elevation: isShikonCard ? 2 : 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onSelectCategory(categoryIndex),
        hoverColor: colorScheme.primary.withValues(alpha: 0.05),
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // カードヘッダー（賞の名前）
              Row(
                children: [
                  Text(
                    category.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isShikonCard
                          ? (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA))
                          : colorScheme.onSurface,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // カード本体（左：順位リスト、右：総投票数 & ▶ ボタン）
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 左側：順位（1位、2位、3位）
                  Expanded(
                    child: displayEntries.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              '投票データがありません',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(displayEntries.length, (idx) {
                              final entry = displayEntries[idx];
                              final rank = idx + 1;
                              final group = entry.key;
                              final votes = entry.value;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3.0),
                                child: Row(
                                  children: [
                                    _buildRankTag(context, rank),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: group.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            if (group.groupName != group.name && group.groupName.isNotEmpty)
                                              TextSpan(
                                                text: ' (${group.groupName})',
                                                style: TextStyle(
                                                  color: colorScheme.onSurfaceVariant,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            TextSpan(
                                              text: '  $votes票',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: votes > 0
                                                    ? (rank == 1 ? colorScheme.primary : colorScheme.onSurfaceVariant)
                                                    : colorScheme.outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                  ),

                  const SizedBox(width: 16),

                  // 右側：総投票数 : nnnn票 と ▶ ボタン
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '総投票数 : $totalVotes 票',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      // モック画像に合わせた黒/アクセントの ▶ ボタン
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isShikon
                              ? (isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5))
                              : colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (isShikon ? const Color(0xFF4F46E5) : colorScheme.primary).withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 順位バッジの構築
  Widget _buildRankTag(BuildContext context, int rank) {
    Color bg;
    Color fg;

    switch (rank) {
      case 1:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case 2:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        break;
      case 3:
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFC2410C);
        break;
      default:
        bg = Theme.of(context).colorScheme.surfaceContainerHighest;
        fg = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        '$rank位 :',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  /// 「紫紺賞1位・2位を除外する」トグルバー
  Widget _buildExclusionToggleBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bool isExcluded = excludeShikonTop2 == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isExcluded
            ? (isDark ? const Color(0xFF1E1B4B).withValues(alpha: 0.5) : const Color(0xFFEEF2FF))
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExcluded
              ? (isDark ? const Color(0xFF6366F1).withValues(alpha: 0.5) : const Color(0xFFC7D2FE))
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: isExcluded ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isExcluded
                  ? (isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF))
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.filter_alt_rounded,
              size: 20,
              color: isExcluded
                  ? (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA))
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '紫紺賞1位・2位を除外する',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isExcluded
                        ? (isDark ? const Color(0xFFE0E7FF) : const Color(0xFF3730A3))
                        : colorScheme.onSurface,
                  ),
                ),
                Text(
                  isExcluded
                      ? 'ON: 紫紺賞の上位2団体を以下の部門賞から除外して集計中'
                      : 'OFF: すべての部門賞で除外を行わずに集計中',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isExcluded,
            activeColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
            onChanged: onExcludeShikonTop2Changed,
          ),
        ],
      ),
    );
  }
}
