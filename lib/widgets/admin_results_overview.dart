import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import '../config/vote_options.dart';
import '../models/group.dart' hide VoteCategory;
import '../models/vote_category.dart';

/// 投票結果サマリー一覧画面（Material 3 Expressive 準拠）
class AdminResultsOverview extends StatelessWidget {
  final List<dynamic>? votes;
  final bool excludeShikonTop2;
  final ValueChanged<bool> onExcludeShikonTop2Changed;
  final void Function(int categoryIndex) onSelectCategory;
  final List<MapEntry<Group, int>> Function(String categoryId, {bool? applyShikonExclusion}) getSortedResults;
  final int Function(String categoryId) getTotalCategoryVotes;
  final Set<String> Function() getShikonTop2GroupIds;
  final int? selectedCategoryIndex;
  final bool isCompact;

  const AdminResultsOverview({
    super.key,
    required this.votes,
    required this.excludeShikonTop2,
    required this.onExcludeShikonTop2Changed,
    required this.onSelectCategory,
    required this.getSortedResults,
    required this.getTotalCategoryVotes,
    required this.getShikonTop2GroupIds,
    this.selectedCategoryIndex,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isExcluded = excludeShikonTop2 == true;

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
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isCompact ? double.infinity : 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── 1. 紫紺賞カード ───────────────────────────
              if (shikonCategory != null) ...[
                _buildAwardCard(
                  context: context,
                  category: shikonCategory,
                  categoryIndex: shikonIndex,
                  results: getSortedResults(shikonCategory.id, applyShikonExclusion: false),
                  totalVotes: getTotalCategoryVotes(shikonCategory.id),
                  maxDisplayRank: 2, // 紫紺賞は1位・2位
                ),
              ],

              // ─── 2. 紫紺賞除外トグルスイッチ ──────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '紫紺賞1位・2位を除外する',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: isExcluded,
                      onChanged: onExcludeShikonTop2Changed,
                    ),
                  ],
                ),
              ),

              // ─── 3. その他の賞カード一覧 ──────────────────────
              ...otherCategories.map((entry) {
                final categoryIndex = entry.key;
                final category = entry.value;
                final results = getSortedResults(category.id);
                final totalVotes = getTotalCategoryVotes(category.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildAwardCard(
                    context: context,
                    category: category,
                    categoryIndex: categoryIndex,
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

  /// 賞カード（モック準拠・MUI3 Expressiveカード）
  Widget _buildAwardCard({
    required BuildContext context,
    required VoteCategory category,
    required int categoryIndex,
    required List<MapEntry<Group, int>> results,
    required int totalVotes,
    required int maxDisplayRank,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayEntries = results.take(maxDisplayRank).toList();
    final bool isSelected = selectedCategoryIndex == categoryIndex;

    return Container(
      decoration: isSelected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: colorScheme.primary,
                width: 2.0,
              ),
            )
          : null,
      child: M3ECard(
        variant: isSelected ? M3ECardVariant.filled : M3ECardVariant.elevated,
        elevation: isSelected ? 2.0 : 1.0,
        borderRadius: BorderRadius.circular(24.0),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 18.0 : 24.0,
          vertical: isCompact ? 16.0 : 20.0,
        ),
        onPressed: () => onSelectCategory(categoryIndex),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 表題（賞名）
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // コンテンツ部（左：順位、右：総投票数と ▶）
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 順位一覧
                Expanded(
                  child: displayEntries.isEmpty
                      ? Text(
                          '1位 : -',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(maxDisplayRank, (idx) {
                            final rank = idx + 1;
                            final entry = idx < displayEntries.length ? displayEntries[idx] : null;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                              child: _buildRankRow(
                                context,
                                rank: rank,
                                entry: entry,
                              ),
                            );
                          }),
                        ),
                ),

                const SizedBox(width: 14),

                // 総投票数と ▶ アイコン
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '総投票数 : $totalVotes票',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 26,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 1行ごとの順位表示
  Widget _buildRankRow(
    BuildContext context, {
    required int rank,
    MapEntry<Group, int>? entry,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (entry == null) {
      return Text(
        '$rank位 : -',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.outline,
        ),
      );
    }

    final group = entry.key;
    final votes = entry.value;

    return Row(
      children: [
        Text(
          '$rank位 : ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Expanded(
          child: Text(
            group.name + (votes > 0 ? ' ($votes票)' : ''),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
