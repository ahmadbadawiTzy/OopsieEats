import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';

/// Customer-First Neo-Brutalism User Profile Avatar.
///
/// Features:
/// - Renders real user photos loaded securely from network (Supabase Storage signed URL).
/// - Graceful Fallback: Renders bold uppercase user initials (e.g., "AB" for Ahmad Badawi)
///   on a vibrant deterministic Neo-Brutalism background palette.
/// - Strictly ZERO emojis and NO generic/cartoon illustrations.
/// - Tactile Controlled Neo-Brutalism styling: 2px solid ink border and hard offset shadow.
class UserProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;
  final double? borderWidth;
  final Offset? shadowOffset;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const UserProfileAvatar({
    super.key,
    this.photoUrl,
    this.name = '',
    this.size = 44.0,
    this.borderWidth,
    this.shadowOffset,
    this.backgroundColor,
    this.onTap,
  });

  /// Deterministically extracts 1 or 2 uppercase initials from the user's name.
  static String extractInitials(String rawName) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) return 'U';

    // If an email was passed as the fallback name, extract the prefix
    String target = trimmed;
    if (target.contains('@')) {
      target = target.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').trim();
      if (target.isEmpty) return 'U';
    }

    final parts = target.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      final single = parts.first;
      return single.substring(0, 1).toUpperCase();
    }

    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts[1].substring(0, 1).toUpperCase();
    return '$first$second';
  }

  /// Resolves deterministic Neo-Brutalism background color for the initials placeholder.
  Color _resolveBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;

    const palette = [
      NeoTokens.lime,
      NeoTokens.lilac,
      NeoTokens.tangerine,
      NeoTokens.hazard,
      NeoTokens.mintGreen,
      NeoTokens.skyBlue,
    ];

    final index = name.trim().hashCode.abs() % palette.length;
    return palette[index];
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderWidth =
        borderWidth ?? (size >= 64 ? 2.5 : (size >= 40 ? 2.0 : 1.5));
    final effectiveShadow =
        shadowOffset ?? (size >= 64 ? const Offset(3, 3) : const Offset(2, 2));
    final cornerRadius = BorderRadius.circular(
      size >= 64 ? 14.0 : (size >= 40 ? 10.0 : 6.0),
    );

    final bgCol = _resolveBackgroundColor();
    final initials = extractInitials(name);

    Widget initialsWidget() {
      return Container(
        color: bgCol,
        alignment: Alignment.center,
        child: ExcludeSemantics(
          child: Text(
            initials,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              fontSize: size * 0.40,
              color: NeoTokens.black,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );
    }

    Widget content;
    final hasValidPhoto = photoUrl != null &&
        photoUrl!.trim().isNotEmpty &&
        (photoUrl!.trim().startsWith('http://') ||
            photoUrl!.trim().startsWith('https://'));

    if (hasValidPhoto) {
      content = Image.network(
        photoUrl!.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * 2.5).toInt(),
        cacheHeight: (size * 2.5).toInt(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: bgCol,
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
        errorBuilder: (_, __, ___) => initialsWidget(),
      );
    } else {
      content = initialsWidget();
    }

    Widget avatarBox = Semantics(
      container: true,
      label: 'Foto profil ${name.trim().isNotEmpty ? name.trim() : "Pengguna"}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgCol,
          borderRadius: cornerRadius,
          border: Border.all(
            color: NeoTokens.black,
            width: effectiveBorderWidth,
          ),
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
      ),
    );

    if (onTap != null) {
      avatarBox = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatarBox,
      );
    }

    return avatarBox;
  }
}
