import 'package:flutter/material.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';

/// Tactile Neo-Brutalist Skip button with physical press feedback.
class SkipButton extends StatefulWidget {
  final VoidCallback onPressed;

  const SkipButton({super.key, required this.onPressed});

  @override
  State<SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends State<SkipButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double offsetX = 3.0;
    const double offsetY = 3.0;

    return GestureDetector(
      onTapDown: (_) {
        if (mounted) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (mounted) setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () {
        if (mounted) setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(
          _isPressed ? offsetX : 0.0,
          _isPressed ? offsetY : 0.0,
          0.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: OnboardingTokens.white,
          borderRadius: BorderRadius.circular(999.0),
          border: Border.all(
            color: OnboardingTokens.black,
            width: OnboardingTokens.borderWidthThin,
          ),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    color: OnboardingTokens.black,
                    offset: Offset(offsetX, offsetY),
                    blurRadius: 0.0,
                  ),
                ],
        ),
        child: const Text(
          'Skip',
          style: TextStyle(
            color: OnboardingTokens.black,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
