import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

class LiquidGlassSettings {
  final Color? glassColor;
  final double thickness;
  final double blur;

  const LiquidGlassSettings({
    this.glassColor,
    this.thickness = 0.0,
    this.blur = 0.0,
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

/// Material 3 Expressive M3ECard コンテナ
/// 透明効果を完全に無効化し、ソリッドなM3Eトナルサーフェスとエレベーションを提供
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
    return M3ECard(
      variant: M3ECardVariant.elevated,
      elevation: 2.0,
      borderRadius: shape.borderRadius,
      padding: EdgeInsets.zero,
      child: child,
    );
  }
}
