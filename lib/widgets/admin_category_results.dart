import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import '../models/group.dart';
import 'gaknum_text.dart';

class AdminCategoryResults extends StatelessWidget {
  final List<MapEntry<Group, int>> results;

  const AdminCategoryResults({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 同率順位（タイ順位）の計算
    final rankedEntries = <({int rank, MapEntry<Group, int> entry})>[];
    int currentRank = 1;
    for (int i = 0; i < results.length; i++) {
      if (i > 0 && results[i].value < results[i - 1].value) {
        currentRank = i + 1;
      }
      rankedEntries.add((rank: currentRank, entry: results[i]));
    }

    // 順位が3位以内の団体（同率含む）を表示。該当がない場合は上位3件
    final topEntries = rankedEntries.where((e) => e.rank <= 3).toList();
    final displayList = topEntries.isNotEmpty ? topEntries : rankedEntries.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'トップ 3',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayList.length,
          itemBuilder: (context, index) {
            final item = displayList[index];
            final group = item.entry.key;
            final voteCount = item.entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: M3ECard(
                variant: M3ECardVariant.elevated,
                elevation: 1.0,
                borderRadius: BorderRadius.circular(16.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    _buildRankBadge(context, item.rank),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (group.groupName != group.name && group.groupName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              group.groupName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          gakNumSpan(
                            '$voteCount',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const TextSpan(text: ' 票'),
                        ],
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRankBadge(BuildContext context, int rank) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color bg;
    Color fg;

    switch (rank) {
      case 1:
        bg = colorScheme.primary;
        fg = colorScheme.onPrimary;
        break;
      case 2:
        bg = colorScheme.secondaryContainer;
        fg = colorScheme.onSecondaryContainer;
        break;
      case 3:
        bg = colorScheme.tertiaryContainer;
        fg = colorScheme.onTertiaryContainer;
        break;
      default:
        bg = colorScheme.surfaceContainerHighest;
        fg = colorScheme.onSurfaceVariant;
    }

    // GakNumBoldフォントのディセンダー余白と数字の視覚的重心を円の中心に補正
    final double yOffset = 2.0;
    final double xOffset = (rank == 1) ? 0.7 : 0.0;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
      ),
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(xOffset, yOffset),
        child: Text(
          '$rank',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'GakNumBold',
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
