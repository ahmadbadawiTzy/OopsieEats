import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';

/// Neo-Brutalist Progress Bar.
/// Features a crisp black border, flat fill color, and animated value progression.
class NeoProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0 (or greater, clamped visually)
  final Color fillColor;
  final Color backgroundColor;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final int segments; // If > 0, renders industrial segmented blocks

  const NeoProgressBar({
    super.key,
    required this.value,
    this.fillColor = NeoTokens.lime,
    this.backgroundColor = NeoTokens.surfaceMuted,
    this.height = 14.0,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(NeoTokens.radiusSmall),
    ),
    this.segments = 0,
  });

  @override
  Widget build(BuildContext context) {
    final clampedFraction = min(1.0, max(0.0, value));

    if (segments > 0) {
      final activeSegments = (clampedFraction * segments).round();
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: Border.all(
            color: NeoTokens.ink,
            width: NeoTokens.borderWidthThin,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: List.generate(segments, (index) {
            final isActive = index < activeSegments;
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? fillColor : Colors.transparent,
                  border: index < segments - 1
                      ? const Border(
                          right: BorderSide(color: NeoTokens.ink, width: 1.5),
                        )
                      : null,
                ),
              ),
            );
          }),
        ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: NeoTokens.ink,
          width: NeoTokens.borderWidthThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth * clampedFraction;
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: barWidth,
                height: height,
                decoration: BoxDecoration(color: fillColor),
              ),
            ],
          );
        },
      ),
    );
  }
}
