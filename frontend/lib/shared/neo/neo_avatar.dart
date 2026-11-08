import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/shared/neo/avatar_catalog.dart';
import 'package:oopsieeats/shared/neo/user_profile_avatar.dart';

/// Neo-Brutalism Avatar for NutriView.
/// - Prioritizes real user photos via [UserProfileAvatar].
/// - Displays clean uppercase initials when no photo is uploaded.
/// - Preserves backward compatibility for legacy game character presets.
class NeoAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? avatarPreset;
  final String name;
  final double size;
  final double? borderWidth;
  final Offset? shadowOffset;
  final VoidCallback? onTap;

  const NeoAvatar({
    super.key,
    this.photoUrl,
    this.avatarPreset,
    this.name = '',
    this.size = 40.0,
    this.borderWidth,
    this.shadowOffset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // If no character preset is requested, render the modern customer-first UserProfileAvatar
    if (avatarPreset == null || avatarPreset!.trim().isEmpty) {
      return UserProfileAvatar(
        photoUrl: photoUrl,
        name: name,
        size: size,
        borderWidth: borderWidth,
        shadowOffset: shadowOffset,
        onTap: onTap,
      );
    }
    final effectiveBorderWidth =
        borderWidth ?? (size >= 64 ? 2.5 : (size >= 40 ? 2.0 : 1.5));
    final effectiveShadow =
        shadowOffset ?? (size >= 64 ? const Offset(3, 3) : const Offset(2, 2));
    final cornerRadius = BorderRadius.circular(
      size >= 64 ? 14.0 : (size >= 40 ? 10.0 : 6.0),
    );

    final character = AvatarCatalog.getById(avatarPreset);

    Widget content;
    final hasValidPhoto =
        photoUrl != null &&
        photoUrl!.trim().isNotEmpty &&
        (photoUrl!.trim().startsWith('http://') ||
            photoUrl!.trim().startsWith('https://'));

    if (hasValidPhoto) {
      content = Image.network(
        photoUrl!.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: character.backgroundColor,
            alignment: Alignment.center,
            child: SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: NeoTokens.black,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => character.builder(size),
      );
    } else {
      content = character.builder(size);
    }

    Widget avatarBox = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: character.backgroundColor,
        borderRadius: cornerRadius,
        border: Border.all(color: NeoTokens.black, width: effectiveBorderWidth),
        boxShadow: effectiveShadow != Offset.zero
            ? [
                BoxShadow(
                  color: NeoTokens.black,
                  offset: effectiveShadow,
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    if (onTap != null) {
      avatarBox = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatarBox,
      );
    }

    return Semantics(
      button: onTap != null,
      label: 'Avatar ${character.name}',
      child: avatarBox,
    );
  }
}
