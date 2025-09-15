import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// 共通のネオモーフィックカードラッパー
Widget neumorphicCard({
  required BuildContext context,
  required Widget child,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? margin,
  double depth = 4.0,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(14)),
}) {
  final theme = Theme.of(context);
  final baseColor = theme.colorScheme.surface;
  return Container(
    margin: margin,
    child: Neumorphic(
      style: NeumorphicStyle(
        color: baseColor,
        depth: depth,
        intensity: 0.8,
        lightSource: LightSource.topLeft,
        boxShape: NeumorphicBoxShape.roundRect(borderRadius),
      ),
      child: Padding(padding: padding ?? const EdgeInsets.all(8), child: child),
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
