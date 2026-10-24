import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/shared/neo/neo_card.dart';

/// Overkill Neo-Brutalist Primary Call-To-Action Card for On-Device Food Scanning.
/// High voltage Acid Lime background with bold typography, camera badge, and hard shadows.
class ScanCtaCard extends StatelessWidget {
  final VoidCallback onScanPressed;

  const ScanCtaCard({super.key, required this.onScanPressed});

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: NeoTokens.lime,
      borderWidth: 3.0,
      shadowOffset: NeoTokens.shadowOffsetMedium,
      padding: const EdgeInsets.all(NeoTokens.space16),
      onTap: onScanPressed,
      child: Stack(
        children: [
          // Background decorative geometric corner pattern
          Positioned(
            right: -10,
            bottom: -15,
            child: Opacity(
              opacity: 0.12,
              child: const Icon(
                Icons.center_focus_strong_rounded,
                size: 110,
                color: NeoTokens.ink,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: NeoTokens.hud,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusSmall,
                      ),
                      border: Border.all(
                        color: NeoTokens.ink,
                        width: NeoTokens.borderWidthThin,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          size: 13,
                          color: NeoTokens.lime,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'PINDAI MAKANAN',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: NeoTokens.paper,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: NeoTokens.paper,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusSmall,
                      ),
                      border: Border.all(
                        color: NeoTokens.ink,
                        width: NeoTokens.borderWidthThin,
                      ),
                    ),
                    child: const Text(
                      'FOTO',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.ink,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NeoTokens.space12),

              // Title and Action Button Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PINDAI MAKANAN',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            color: NeoTokens.ink,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kenali makanan dari foto dan catat nutrisinya.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: NeoTokens.ink,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: NeoTokens.space12),

                  // Camera button badge
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: NeoTokens.paper,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusSmall,
                      ),
                      border: Border.all(color: NeoTokens.ink, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: NeoTokens.ink,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: NeoTokens.ink,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
