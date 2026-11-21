import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/features/onboarding/models/onboarding_tokens.dart';

/// Neo-Brutalist Skip button with warm cream fill, thick black border,
/// primaryGreen chevron accent, and tactile press-down animation.
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
    const double offsetX = 3.5;
    const double offsetY = 3.5;

    return Semantics(
      button: true,
      label: 'Lewati onboarding',
      child: GestureDetector(
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
          duration: NeoMotion.getDuration(context, NeoMotion.durationFast),
          transform: Matrix4.translationValues(
            _isPressed ? offsetX : 0.0,
            _isPressed ? offsetY : 0.0,
            0.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
          decoration: BoxDecoration(
            color: OnboardingTokens.warmBackground,
            borderRadius: BorderRadius.circular(NeoTokens.radiusPill),
            border: Border.all(
              color: OnboardingTokens.black,
              width: OnboardingTokens.borderWidth,
            ),
            boxShadow: _isPressed
                ? []
                : const [
                    BoxShadow(
                      color: OnboardingTokens.black,
                      offset: Offset(offsetX, offsetY),
                      blurRadius: NeoTokens.shadowBlurRadius,
                    ),
                  ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Skip',
                style: TextStyle(
                  color: OnboardingTokens.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  height: 1.0,
                ),
              ),
              SizedBox(width: 4.0),
              Text(
                '»',
                style: TextStyle(
                  color: OnboardingTokens.primaryGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
