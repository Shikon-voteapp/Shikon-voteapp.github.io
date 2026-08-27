import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'liquid_glass.dart';

/// 共通のカードラッパー（NeumorphicからLiquidGlassへ変更）
Widget neumorphicCard({
  required BuildContext context,
  required Widget child,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
  double depth = 6.0, // Used for shadow intensity now
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(14)),
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final glassColor = isDark
      ? Colors.black.withValues(alpha: 0.15)
      : Colors.white.withValues(alpha: 0.25);

  return Container(
    margin: margin,
    decoration: BoxDecoration(
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05 + (depth * 0.005)),
          blurRadius: 10 + depth,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: LiquidGlassLayer(
      settings: LiquidGlassSettings(
        glassColor: glassColor,
        blur: 15.0,
      ),
      child: LiquidGlass(
        shape: LiquidRoundedRectangle(
          borderRadius: borderRadius.topLeft.x,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(8),
          child: child,
        ),
      ),
    ),
  );
}

// リスト/グリッド要素のフェード＋スライドの基本アニメーション
Widget animatedItem({
  required int index,
  required Widget child,
  Duration duration = const Duration(milliseconds: 350),
  double verticalOffset = 24,
}) {
  return AnimationConfiguration.staggeredList(
    position: index,
    duration: duration,
    child: SlideAnimation(
      verticalOffset: verticalOffset,
      curve: Curves.easeOutCubic,
      child: FadeInAnimation(child: child),
    ),
  );
}
