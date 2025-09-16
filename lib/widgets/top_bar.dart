import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:icons_plus/icons_plus.dart';

class TopBar extends StatelessWidget {
  final String title;
  final IconData icon;

  const TopBar({Key? key, required this.title, this.icon = FontAwesome.user})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Neumorphic(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      margin: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 24.0),
      style: NeumorphicStyle(
        color: theme.colorScheme.surface,
        boxShape: NeumorphicBoxShape.roundRect(
          const BorderRadius.only(
            topRight: Radius.circular(24.0),
            bottomRight: Radius.circular(24.0),
          ),
        ),
        depth: 4,
        intensity: 0.7,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color:
                theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  theme.brightness == Brightness.dark
                      ? Colors.white
                      : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
