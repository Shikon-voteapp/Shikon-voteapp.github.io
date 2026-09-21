import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

class LiquidGlassSettings {
  final Color glassColor;
  final double thickness;
  final double blur;

  const LiquidGlassSettings({
    this.glassColor = const Color(0x1AFFFFFF),
    this.thickness = 15.0,
    this.blur = 20.0,
  });
}

class LiquidGlassLayer extends StatelessWidget {
  final LiquidGlassSettings settings;
  final Widget child;

  const LiquidGlassLayer({
    super.key,
    required this.settings,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

abstract class LiquidShape {
  BorderRadius get borderRadius;
}

class LiquidRoundedRectangle extends LiquidShape {
  final double borderRadiusValue;

  LiquidRoundedRectangle({required double borderRadius})
      : borderRadiusValue = borderRadius;

  @override
  BorderRadius get borderRadius => BorderRadius.circular(borderRadiusValue);
}

/// Material 3 Expressive に刷新された Expressive Surface コンテナ
/// Liquid Glass (BackdropFilter) を廃止し、M3Eの表現力豊かなトナルサーフェスと角丸シェイプを提供
class LiquidGlass extends StatelessWidget {
  final LiquidShape shape;
  final Widget child;

  const LiquidGlass({
    super.key,
    required this.shape,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final layer = context.findAncestorWidgetOfExactType<LiquidGlassLayer>();
    final settings = layer?.settings;

    // Material 3 Expressive トナルサーフェス装飾
    var surfaceColor = isDark
        ? Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.surfaceContainerHigh,
          )
        : Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.05),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.75),
          );

    if (settings != null && settings.glassColor != const Color(0x1AFFFFFF)) {
      surfaceColor = Color.alphaBlend(settings.glassColor, surfaceColor);
    }

    final borderColor = isDark
        ? colorScheme.outlineVariant.withValues(alpha: 0.25)
        : colorScheme.outlineVariant.withValues(alpha: 0.4);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: shape.borderRadius,
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
