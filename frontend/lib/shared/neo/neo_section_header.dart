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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isBounded = constraints.maxWidth.isFinite;

        final textColumn = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: isBounded ? 2 : null,
              overflow: isBounded ? TextOverflow.ellipsis : null,
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
        );

        final indicatorRow = Row(
          mainAxisSize: isBounded ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            if (isBounded) Expanded(child: textColumn) else textColumn,
          ],
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: NeoTokens.space8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isBounded) Expanded(child: indicatorRow) else indicatorRow,
              if (trailing != null) ...[
                const SizedBox(width: NeoTokens.space8),
                trailing!,
              ],
            ],
          ),
        );
      },
    );
  }
}
