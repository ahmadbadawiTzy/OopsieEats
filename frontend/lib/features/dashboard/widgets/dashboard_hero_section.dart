import 'package:flutter/material.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/shared/neo/neo_avatar.dart';

/// Customer-First Neo-Brutalist Hero Header for NutriView.
/// Displays a warm personal greeting, concise motivational guidance,
/// and interactive user avatar with tactile affordance.
class DashboardHeroSection extends StatefulWidget {
  final String userName;
  final String? avatarPreset;
  final String? photoUrl;
  final VoidCallback? onAvatarTap;

  const DashboardHeroSection({
    super.key,
    required this.userName,
    this.avatarPreset,
    this.photoUrl,
    this.onAvatarTap,
  });

  @override
  State<DashboardHeroSection> createState() => _DashboardHeroSectionState();
}

class _DashboardHeroSectionState extends State<DashboardHeroSection> {
  bool _isPressed = false;

  /// Resolves the cleanest personal name or returns a warm fallback.
  String _resolveCleanName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Sobat Sehat';

    // If string is an email, take the handle and capitalize nicely
    if (trimmed.contains('@')) {
      final handle = trimmed
          .split('@')
          .first
          .replaceAll(RegExp(r'[^a-zA-Z]'), '');
      if (handle.isEmpty) return 'Sobat Sehat';
      return handle[0].toUpperCase() + handle.substring(1).toLowerCase();
    }

    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final cleanName = _resolveCleanName(widget.userName);

    return Semantics(
      container: true,
      label: 'Bagian sapaan pengguna, halo $cleanName',
      child: GestureDetector(
        onTapDown: widget.onAvatarTap != null
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: widget.onAvatarTap != null
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: widget.onAvatarTap != null
            ? () => setState(() => _isPressed = false)
            : null,
        onTap: widget.onAvatarTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            _isPressed ? 1.5 : 0.0,
            _isPressed ? 1.5 : 0.0,
            0.0,
          ),
          padding: const EdgeInsets.all(NeoTokens.space16),
          decoration: BoxDecoration(
            color: NeoTokens.paper,
            borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
            border: Border.all(
              color: NeoTokens.ink,
              width: NeoTokens.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: NeoTokens.ink,
                offset: _isPressed
                    ? NeoTokens.shadowOffsetPressed
                    : NeoTokens.shadowOffsetMedium,
                blurRadius: NeoTokens.shadowBlurRadius,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User Avatar with Neo-Brutalism border (size: 44 is on the design system scale)
              NeoAvatar(
                photoUrl: widget.photoUrl,
                avatarPreset: widget.avatarPreset,
                name: widget.userName.isNotEmpty
                    ? widget.userName
                    : 'Sobat Sehat',
                size: 44,
                onTap: widget.onAvatarTap,
              ),
              const SizedBox(width: NeoTokens.space16),

              // Warm Personal Greeting and Context Subtext
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
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
                      child: const Text(
                        'CATATAN GIZI HARIAN',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.paper,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Halo, $cleanName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.ink,
                        letterSpacing: -0.4,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Yuk, pahami asupanmu dan bangun kebiasaan makan yang lebih seimbang.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: NeoTokens.inkSecondary,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Subtle affordance chevron
              if (widget.onAvatarTap != null) ...[
                const SizedBox(width: NeoTokens.space8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: NeoTokens.recess,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                    border: Border.all(
                      color: NeoTokens.ink,
                      width: NeoTokens.borderWidthThin,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      AppIcons.chevronRight,
                      size: AppIcons.sizeLarge,
                      color: NeoTokens.ink,
                    ),
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
