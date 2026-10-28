import 'package:flutter/material.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';

/// Standard NutriView back control for every `AppBar`.
///
/// Material's built-in `BackButton` always draws the default sharp-styled
/// back arrow, which breaks the app-wide Rounded-family rule kept in
/// [AppIcons]. This widget gives every pushed
/// screen the same rounded glyph, the same ink colour and a proper tooltip
/// while keeping the default 48px touch target.
class NeoBackButton extends StatelessWidget {
  const NeoBackButton({super.key, this.tooltip = 'Kembali'});

  final String tooltip;

  /// Ready-made `AppBar.leading` value.
  ///
  /// Returns `null` when the current route cannot be popped, mirroring
  /// Material's own rule so a root screen never shows a dead back button.
  static Widget? leading(BuildContext context) =>
      ModalRoute.of(context)?.canPop == true ? const NeoBackButton() : null;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(AppIcons.arrowBack, color: NeoTokens.ink),
      tooltip: tooltip,
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}
