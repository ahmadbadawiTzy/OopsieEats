import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/shared/neo/neo_button.dart';

/// Neo-Brutalist Confirmation Dialog.
/// Features a heavy black border, deep hard shadow, and high-impact action buttons.
class NeoDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color confirmColor;
  final IconData? icon;

  const NeoDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Konfirmasi',
    this.cancelText = 'Batal',
    required this.onConfirm,
    this.onCancel,
    this.confirmColor = NeoTokens.vividYellow,
    this.icon,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Konfirmasi',
    String? cancelText = 'Batal',
    Color confirmColor = NeoTokens.vividYellow,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => NeoDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: NeoTokens.space24,
        vertical: NeoTokens.space24,
      ),
      child: Container(
        padding: const EdgeInsets.all(NeoTokens.space24),
        decoration: BoxDecoration(
          color: NeoTokens.warmBackground,
          borderRadius: BorderRadius.circular(NeoTokens.radiusLarge),
          border: Border.all(
            color: NeoTokens.black,
            width: NeoTokens.borderWidthThick,
          ),
          boxShadow: const [
            BoxShadow(
              color: NeoTokens.black,
              offset: NeoTokens.shadowOffsetLarge,
              blurRadius: NeoTokens.shadowBlurRadius,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: confirmColor,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                    border: Border.all(
                      color: NeoTokens.black,
                      width: NeoTokens.borderWidth,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: NeoTokens.black,
                        offset: NeoTokens.shadowOffsetSmall,
                        blurRadius: NeoTokens.shadowBlurRadius,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 28, color: NeoTokens.black),
                ),
              ),
              const SizedBox(height: NeoTokens.space16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: NeoTokens.textDark,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: NeoTokens.space8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: NeoTokens.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: NeoTokens.space24),
            Row(
              children: [
                if (cancelText != null) ...[
                  Expanded(
                    child: NeoButton(
                      text: cancelText!,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      variant: NeoButtonVariant.secondary,
                      onPressed:
                          onCancel ?? () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: NeoTokens.space12),
                ],
                Expanded(
                  child: NeoButton(
                    text: confirmText,
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    customBackgroundColor: confirmColor,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
