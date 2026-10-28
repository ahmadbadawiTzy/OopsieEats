import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/shared/neo/avatar_catalog.dart';
import 'package:nutriview/shared/neo/neo_avatar.dart';
import 'package:nutriview/shared/neo/neo_badge.dart';
import 'package:nutriview/shared/neo/neo_button.dart';
import 'package:nutriview/shared/neo/neo_card.dart';
import 'package:nutriview/core/app_icons.dart';

/// Modal bottom sheet allowing users to choose an authentic Neo-Brutalism
/// game-style avatar character from [AvatarCatalog].
class AvatarSelectionModal extends StatefulWidget {
  final String currentAvatarId;
  final ValueChanged<String> onAvatarSelected;

  const AvatarSelectionModal({
    super.key,
    required this.currentAvatarId,
    required this.onAvatarSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    required String currentAvatarId,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AvatarSelectionModal(
        currentAvatarId: currentAvatarId,
        onAvatarSelected: (newId) => Navigator.of(ctx).pop(newId),
      ),
    );
  }

  @override
  State<AvatarSelectionModal> createState() => _AvatarSelectionModalState();
}

class _AvatarSelectionModalState extends State<AvatarSelectionModal> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.currentAvatarId;
  }

  @override
  Widget build(BuildContext context) {
    final activeCharacter = AvatarCatalog.getById(_selectedId);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: NeoTokens.warmBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: NeoTokens.black, width: 2.5),
          left: BorderSide(color: NeoTokens.black, width: 2.5),
          right: BorderSide(color: NeoTokens.black, width: 2.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: NeoTokens.black,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Header Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Katalog Avatar Game',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: NeoTokens.black,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pilih karakter unik untuk identitas profilmu di NutriView.',
                          style: TextStyle(
                            fontSize: 12,
                            color: NeoTokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close, color: NeoTokens.black),
                    tooltip: 'Tutup katalog avatar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: NeoTokens.black, height: 1.5, thickness: 1.5),

            // Active Preview Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: NeoCard(
                backgroundColor: NeoTokens.white,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    NeoAvatar(
                      avatarPreset: activeCharacter.id,
                      size: 64,
                      borderWidth: 2.5,
                      shadowOffset: const Offset(3, 3),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                activeCharacter.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: NeoTokens.black,
                                ),
                              ),
                              const SizedBox(width: 6),
                              NeoBadge(
                                label: 'TERPILIH',
                                color: NeoBadgeColor.yellow,
                                fontSize: 9,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeCharacter.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: NeoTokens.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeCharacter.traits,
                            style: const TextStyle(
                              fontSize: 11,
                              color: NeoTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Grid of Characters
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: AvatarCatalog.characters.length,
                itemBuilder: (context, index) {
                  final char = AvatarCatalog.characters[index];
                  final isSelected = char.id == _selectedId;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedId = char.id;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? NeoTokens.vividYellow
                            : NeoTokens.white,
                        borderRadius: BorderRadius.circular(
                          NeoTokens.radiusMedium,
                        ),
                        border: Border.all(
                          color: NeoTokens.black,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: NeoTokens.black,
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NeoAvatar(
                            avatarPreset: char.id,
                            size: 44,
                            borderWidth: 1.5,
                            shadowOffset: Offset.zero,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            char.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: NeoTokens.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: NeoTokens.warmBackground,
                border: Border(
                  top: BorderSide(color: NeoTokens.black, width: 2),
                ),
              ),
              child: NeoButton(
                text: 'Gunakan Avatar Ini',
                variant: NeoButtonVariant.primary,
                suffixIcon: AppIcons.checkCircle,
                onPressed: () => widget.onAvatarSelected(_selectedId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
