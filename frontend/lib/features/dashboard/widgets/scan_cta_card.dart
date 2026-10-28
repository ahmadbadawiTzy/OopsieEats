import 'package:flutter/material.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';

/// Primary Call-To-Action Card for On-Device Food Scanning.
/// High-voltage Acid Lime Neo-Brutalist card with tactile affordance,
/// customer-centric copywriting, and instant camera trigger.
class ScanCtaCard extends StatefulWidget {
  final VoidCallback onScanPressed;

  const ScanCtaCard({super.key, required this.onScanPressed});

  @override
  State<ScanCtaCard> createState() => _ScanCtaCardState();
}

class _ScanCtaCardState extends State<ScanCtaCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Scan Makanan, pindai makananmu untuk mencatat kalori dan nutrisi otomatis',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onScanPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            _isPressed ? 2.0 : 0.0,
            _isPressed ? 2.0 : 0.0,
            0.0,
          ),
          decoration: BoxDecoration(
            color: NeoTokens.lime,
            borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
            border: Border.all(
              color: NeoTokens.ink,
              width: NeoTokens.borderWidthThick,
            ),
            boxShadow: [
              BoxShadow(
                color: NeoTokens.ink,
                offset: _isPressed ? NeoTokens.shadowOffsetPressed : NeoTokens.shadowOffsetMedium,
                blurRadius: NeoTokens.shadowBlurRadius,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: NeoTokens.space16,
            vertical: NeoTokens.space16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Main Copy: Title and Subtitle
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Makanan',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        color: NeoTokens.ink,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pindai makananmu untuk mencatat kalori dan nutrisi otomatis.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: NeoTokens.ink,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: NeoTokens.space16),

              // Camera Action Button Badge
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: NeoTokens.paper,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                  border: Border.all(
                    color: NeoTokens.ink,
                    width: NeoTokens.borderWidth,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: NeoTokens.ink,
                      offset: NeoTokens.shadowOffsetSmall,
                      blurRadius: NeoTokens.shadowBlurRadius,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    AppIcons.cameraAlt,
                    color: NeoTokens.ink,
                    size: AppIcons.sizeState,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
