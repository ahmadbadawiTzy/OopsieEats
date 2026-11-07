import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';

enum NeoBadgeColor { mint, yellow, coral, sky, lavender, white, dark }

/// Neo-Brutalist Badge & Chip component.
/// Provides high-contrast, bold tags with crisp black borders and optional mini hard shadows.
class NeoBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final NeoBadgeColor color;
  final Color? customBackgroundColor;
  final Color? customTextColor;
  final bool hasShadow;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const NeoBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = NeoBadgeColor.mint,
    this.customBackgroundColor,
    this.customTextColor,
    this.hasShadow = false,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.fontSize = 12,
  });

  Color get _bg {
    if (customBackgroundColor != null) return customBackgroundColor!;
    switch (color) {
      case NeoBadgeColor.mint:
        return NeoTokens.mintGreen;
      case NeoBadgeColor.yellow:
        return NeoTokens.vividYellow;
      case NeoBadgeColor.coral:
        return NeoTokens.coralRed;
      case NeoBadgeColor.sky:
        return NeoTokens.skyBlue;
      case NeoBadgeColor.lavender:
        return NeoTokens.lavender;
      case NeoBadgeColor.white:
        return NeoTokens.white;
      case NeoBadgeColor.dark:
        return NeoTokens.black;
    }
  }

  Color get _fg {
    if (customTextColor != null) return customTextColor!;
    switch (color) {
      case NeoBadgeColor.coral:
      case NeoBadgeColor.dark:
        return NeoTokens.white;
      default:
        return NeoTokens.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        border: Border.all(
          color: NeoTokens.black,
          width: NeoTokens.borderWidthThin,
        ),
        boxShadow: hasShadow
            ? [
                const BoxShadow(
                  color: NeoTokens.black,
                  offset: NeoTokens.shadowOffsetSmall,
                  blurRadius: NeoTokens.shadowBlurRadius,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: _fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: _fg,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      badge = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        child: badge,
      );
    }

    return badge;
  }
}
