import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'gaknum_text.dart';

class TopBar extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final IconData icon;
  final Widget? trailing;
  final double? progressValue;

  const TopBar({
    super.key,
    this.title = '',
    this.titleWidget,
    this.icon = Icons.person,
    this.trailing,
    this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasProgress = progressValue != null;

    final titleCard = M3ECard(
      variant: M3ECardVariant.elevated,
      elevation: 2.0,
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(28.0)),
      padding: const EdgeInsets.only(left: 40.0, right: 20.0, top: 10.0, bottom: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10.0),
          if (titleWidget != null)
            titleWidget!
          else
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
        ],
      ),
    );

    Widget rowContent;
    if (hasProgress) {
      final clampedProgress = progressValue!.clamp(0.0, 1.0);
      final percent = (clampedProgress * 100).round();

      rowContent = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          titleCard,
          const SizedBox(width: 16.0),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: clampedProgress),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubicEmphasized,
              builder: (context, animVal, _) {
                return M3EProgressIndicator.linearWavy(
                  value: animVal,
                  linearSize: M3EProgressIndicatorSize.s,
                  strokeWidth: 2.5,
                  trackStrokeWidth: 2.5,
                  wavelength: 28.0,
                  color: theme.colorScheme.primary,
                  trackColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                );
              },
            ),
          ),
          const SizedBox(width: 12.0),
          Text.rich(
            TextSpan(
              children: [
                gakNumSpan(
                  '$percent',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                TextSpan(
                  text: '%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
        ],
      );
    } else {
      rowContent = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          titleCard,
          if (trailing != null) ...[
            const SizedBox(width: 14.0),
            trailing!,
          ],
        ],
      );
    }

    return Transform.translate(
      offset: const Offset(-24.0, 0),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: rowContent,
      ),
    );
  }
}
