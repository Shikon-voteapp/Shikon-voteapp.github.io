import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    final layer = context.findAncestorWidgetOfExactType<LiquidGlassLayer>();
    final settings = layer?.settings ?? const LiquidGlassSettings();

    final Color glassColor = settings.glassColor;
    final double blur = settings.blur;

    final boxDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          glassColor.withAlpha((glassColor.alpha * 1.3).clamp(0, 255).toInt()),
          glassColor.withAlpha((glassColor.alpha * 0.85).clamp(0, 255).toInt()),
        ],
      ),
      borderRadius: shape.borderRadius,
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.4),
        width: 1.2,
      ),
    );

    // Web環境ではBackdropFilterが大量のGPUメモリリーク(1.5GB超)を引き起こすため、
    // 軽量かつ高速な半透明グラデーション装飾を使用
    if (kIsWeb || blur <= 0) {
      return Container(
        decoration: boxDecoration,
        child: child,
      );
    }

    return ClipRRect(
      borderRadius: shape.borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: boxDecoration,
          child: child,
        ),
      ),
    );
  }
}
