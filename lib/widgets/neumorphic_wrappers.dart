import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// 共通のカードラッパー（Material 3 Expressive M3ECard）
Widget neumorphicCard({
  required BuildContext context,
  required Widget child,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
  double depth = 6.0,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
}) {
  return Container(
    margin: margin,
    child: M3ECard(
      variant: M3ECardVariant.elevated,
      elevation: (depth * 0.25).clamp(1.0, 3.0),
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.all(12),
      child: child,
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
