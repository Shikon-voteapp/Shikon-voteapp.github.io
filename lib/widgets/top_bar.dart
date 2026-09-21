import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

class TopBar extends StatelessWidget {
  final String title;
  final IconData icon;

  const TopBar({super.key, required this.title, this.icon = Icons.person});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Transform.translate(
      offset: const Offset(-24.0, 0),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: M3ECard(
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
        ),
      ),
    );
  }
}
