import 'package:flutter/material.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/neo_tokens.dart';

/// Semantic tone of a [NeoSnackBars] message.
enum NeoSnackKind { success, error, info }

/// Single Neo-Brutalist SnackBar treatment shared by the user and admin areas.
///
/// One shape, one border, one icon language and one typography for every
/// transient message in the app:
/// - floating surface, `radiusSmall` corners, crisp 2.0px ink border
/// - leading [AppIcons] glyph (outline status style) at [AppIcons.sizeControl]
/// - 13px / w700 copy
class NeoSnackBars {
  NeoSnackBars._();

  static void success(BuildContext context, String message) =>
      show(context, message, kind: NeoSnackKind.success);

  static void error(BuildContext context, String message) =>
      show(context, message, kind: NeoSnackKind.error);

  static void info(BuildContext context, String message) =>
      show(context, message, kind: NeoSnackKind.info);

  static void show(
    BuildContext context,
    String message, {
    NeoSnackKind kind = NeoSnackKind.info,
  }) {
    final Color background;
    final IconData icon;
    switch (kind) {
      case NeoSnackKind.success:
        background = NeoTokens.primaryGreen;
        icon = AppIcons.checkCircleOutline;
      case NeoSnackKind.error:
        background = NeoTokens.coralRed;
        icon = AppIcons.error;
      case NeoSnackKind.info:
        background = NeoTokens.ink;
        icon = AppIcons.info;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
          side: const BorderSide(color: NeoTokens.ink, width: 2),
        ),
        content: Row(
          children: [
            Icon(icon, color: NeoTokens.paper, size: AppIcons.sizeControl),
            const SizedBox(width: NeoTokens.space10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: NeoTokens.paper,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
