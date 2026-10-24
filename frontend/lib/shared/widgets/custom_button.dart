import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/shared/neo/neo_button.dart';

/// Legacy-compatible CustomButton upgraded with tactile Neo-Brutalist interaction.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return NeoButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      customBackgroundColor: backgroundColor ?? NeoTokens.vividYellow,
      customTextColor: textColor ?? NeoTokens.black,
      prefixIcon: icon,
      isFullWidth: true,
      height: 52,
    );
  }
}
