import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/shared/neo/neo_button.dart';
import 'package:nutriview/shared/neo/neo_card.dart';

/// Neo-Brutalist Error View.
/// Displays an emphatic alert card with retry capability.
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NeoTokens.space24,
          vertical: NeoTokens.space32,
        ),
        child: NeoCard(
          backgroundColor: NeoTokens.white,
          padding: const EdgeInsets.all(NeoTokens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: NeoTokens.coralRed,
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
                child: const Icon(
                  Icons.priority_high_rounded,
                  size: 34,
                  color: NeoTokens.white,
                ),
              ),
              const SizedBox(height: NeoTokens.space16),
              const Text(
                'Terjadi Kendala',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: NeoTokens.textDark,
                  letterSpacing: -0.3,
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
              if (onRetry != null) ...[
                const SizedBox(height: NeoTokens.space20),
                SizedBox(
                  width: 170,
                  child: NeoButton(
                    text: 'Coba Lagi',
                    prefixIcon: Icons.refresh_rounded,
                    customBackgroundColor: NeoTokens.vividYellow,
                    height: 46,
                    onPressed: onRetry!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
