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
    final topCount = results.length > 3 ? 3 : results.length;

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
          itemCount: topCount,
          itemBuilder: (context, index) {
            final entry = results[index];
            final group = entry.key;
            final voteCount = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: M3ECard(
                variant: M3ECardVariant.elevated,
                elevation: 1.0,
                borderRadius: BorderRadius.circular(16.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    _buildRankBadge(context, index),
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
      case 0:
        bg = colorScheme.primary;
        fg = colorScheme.onPrimary;
        break;
      case 1:
        bg = colorScheme.secondaryContainer;
        fg = colorScheme.onSecondaryContainer;
        break;
      case 2:
        bg = colorScheme.tertiaryContainer;
        fg = colorScheme.onTertiaryContainer;
        break;
      default:
        bg = colorScheme.surfaceContainerHighest;
        fg = colorScheme.onSurfaceVariant;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
      ),
      child: Center(
        child: Text(
          '${rank + 1}',
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
