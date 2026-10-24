import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';

/// Neo-Brutalist Loading Indicator.
/// Displays an animated high-contrast spinner container with bold status typography.
class LoadingIndicator extends StatefulWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NeoTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: NeoTokens.vividYellow,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
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
                child: const Center(
                  child: Icon(
                    Icons.sync_rounded,
                    color: NeoTokens.black,
                    size: 26,
                  ),
                ),
              ),
            ),
            if (widget.message != null) ...[
              const SizedBox(height: NeoTokens.space20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: NeoTokens.white,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                  border: Border.all(
                    color: NeoTokens.black,
                    width: NeoTokens.borderWidthThin,
                  ),
                ),
                child: Text(
                  widget.message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: NeoTokens.textDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
