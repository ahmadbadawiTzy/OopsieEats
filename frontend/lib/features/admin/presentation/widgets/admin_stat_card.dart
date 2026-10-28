import 'package:flutter/material.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';

/// Neo-Brutalist Stat Card for Admin Dashboard HUD.
class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color stripeColor;
  final IconData icon;
  final VoidCallback? onTap;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.stripeColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: NeoTokens.paper,
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          border: Border.all(
            color: NeoTokens.ink,
            width: NeoTokens.borderWidth,
          ),
          boxShadow: const [
            BoxShadow(
              color: NeoTokens.ink,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Stripe
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: stripeColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(NeoTokens.radiusMedium - 2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: NeoTokens.inkSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: stripeColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                          border: Border.all(
                            color: NeoTokens.ink,
                            width: NeoTokens.borderWidthThin,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: AppIcons.sizeMedium,
                          color: NeoTokens.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.ink,
                      height: 1.0,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: NeoTokens.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
