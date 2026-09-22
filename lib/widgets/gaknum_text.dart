import 'package:flutter/material.dart';

/// Renders a number using GakNumBold with baseline adjusted so its bottom edge
/// (下端) aligns with surrounding Japanese fonts.
InlineSpan gakNumSpan(
  String text, {
  TextStyle? style,
  double? fontSize,
  Color? color,
  FontWeight? fontWeight,
  double yShiftFactor = 0.0,
}) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: Builder(
      builder: (context) {
        final parentStyle = style ?? DefaultTextStyle.of(context).style;
        final resolvedSize = fontSize ?? parentStyle.fontSize ?? 14.0;
        final yOffset = resolvedSize * yShiftFactor;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Text(
            text,
            style: parentStyle.copyWith(
              fontFamily: 'GakNumBold',
              fontSize: resolvedSize,
              color: color,
              fontWeight: fontWeight,
            ),
          ),
        );
      },
    ),
  );
}
