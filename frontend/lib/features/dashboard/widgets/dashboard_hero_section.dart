import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/shared/neo/neo_avatar.dart';
import 'package:nutriview/core/app_icons.dart';

/// Overkill Neo-Brutalist Editorial Hero Section.
/// Displays user avatar, greeting, dynamic time context, heavy headline, and subheadline.
class DashboardHeroSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final firstName = userName.trim().isNotEmpty
        ? userName.trim().split(' ').first
        : 'Sobat';
    final upperGreeting = 'HALO, ${firstName.toUpperCase()}!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting & Avatar Header Card
        InkWell(
          onTap: onAvatarTap,
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  offset: NeoTokens.shadowOffsetSmall,
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                NeoAvatar(
                  photoUrl: photoUrl,
                  avatarPreset: avatarPreset,
                  name: userName.isNotEmpty ? userName : 'Sobat Sehat',
                  size: 44,
                  onTap: onAvatarTap,
                ),
                const SizedBox(width: NeoTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: NeoTokens.lime,
                              borderRadius: BorderRadius.circular(
                                NeoTokens.radiusSmall,
                              ),
                              border: Border.all(
                                color: NeoTokens.ink,
                                width: NeoTokens.borderWidthThin,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: NeoTokens.ink,
                                  offset: Offset(1, 1),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              upperGreeting,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: NeoTokens.ink,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Halo, ${userName.trim().isNotEmpty ? userName.trim() : 'Sobat Sehat'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: NeoTokens.ink,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (onAvatarTap != null)
                  const Icon(
                    AppIcons.chevronRight,
                    color: NeoTokens.ink,
                    size: AppIcons.sizeToolbar,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: NeoTokens.space12),

        // Headline
        const Text(
          'PANTAU NUTRISI HARI INI',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            fontSize: 22,
            height: 1.15,
            color: NeoTokens.ink,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: NeoTokens.space6),

        // Subheadline
        const Text(
          'Pindai foto makanan atau cari menu untuk mencatat kalori dan makronutrisi harianmu secara akurat.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: NeoTokens.inkSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
