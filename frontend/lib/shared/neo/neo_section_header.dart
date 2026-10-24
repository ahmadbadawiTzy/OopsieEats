import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';

/// Neo-Brutalist Section Header.
/// Features a bold title with high-contrast accent indicator and optional action widget.
class NeoSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accentColor;
  final Widget? trailing;

  const NeoSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.accentColor = NeoTokens.vividYellow,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NeoTokens.space8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  border: Border.all(color: NeoTokens.black, width: 1.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: NeoTokens.space8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: NeoTokens.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: NeoTokens.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
