import 'package:flutter/material.dart';
import 'liquid_glass.dart';

class TopBar extends StatelessWidget {
  final String title;
  final IconData icon;

  const TopBar({Key? key, required this.title, this.icon = Icons.person})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glassColor = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);

    return Transform.translate(
      offset: const Offset(-24.0, 0),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: LiquidGlassLayer(
          settings: LiquidGlassSettings(
            glassColor: glassColor,
            thickness: 15.0,
            blur: 20.0,
          ),
          child: LiquidGlass(
            shape: LiquidRoundedRectangle(
              borderRadius: 24.0,
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 40.0, right: 16.0, top: 8.0, bottom: 8.0),
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
            ),
          ),
        ),
      ),
    );
  }
}
