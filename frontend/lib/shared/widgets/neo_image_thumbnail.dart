import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/data/models/meal.dart';
import 'package:oopsieeats/data/services/supabase_storage_service.dart';

/// Neo-Brutalist Image Thumbnail for food inspection photos stored in Supabase Storage.
///
/// Features:
/// - Asynchronous signed URL fetching with in-memory caching via [SupabaseStorageService]
/// - Resilient fallback icon when image is absent, offline, or failed to load
/// - Signature Neo-Brutalist 2px black border, hard offset shadow, and flat background
class NeoImageThumbnail extends StatelessWidget {
  final MealImageMetadata? imageMetadata;
  final double size;
  final double borderWidth;
  final double borderRadius;
  final Offset shadowOffset;
  final VoidCallback? onTap;
  final Color backgroundColor;

  const NeoImageThumbnail({
    super.key,
    required this.imageMetadata,
    this.size = 64.0,
    this.borderWidth = NeoTokens.borderWidth,
    this.borderRadius = NeoTokens.radiusSmall,
    this.shadowOffset = const Offset(2, 2),
    this.onTap,
    this.backgroundColor = NeoTokens.recess,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    final metadata = imageMetadata;

    if (metadata == null || metadata.path.isEmpty) {
      content = _buildPlaceholder(
        icon: AppIcons.restaurant,
        iconSize: size * 0.45,
      );
    } else {
      content = _SignedImageLoader(
        metadata: metadata,
        size: size,
        borderRadius: borderRadius,
        onTap: onTap,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: NeoTokens.black, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: NeoTokens.black,
              offset: shadowOffset,
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - 1),
          child: content,
        ),
      ),
    );
  }

  Widget _buildPlaceholder({required IconData icon, required double iconSize}) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: NeoTokens.inkSecondary),
    );
  }
}

class _SignedImageLoader extends StatefulWidget {
  final MealImageMetadata metadata;
  final double size;
  final double borderRadius;
  final VoidCallback? onTap;

  const _SignedImageLoader({
    required this.metadata,
    required this.size,
    required this.borderRadius,
    this.onTap,
  });

  @override
  State<_SignedImageLoader> createState() => _SignedImageLoaderState();
}

class _SignedImageLoaderState extends State<_SignedImageLoader> {
  Future<String?>? _signedUrlFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchSignedUrl();
  }

  @override
  void didUpdateWidget(covariant _SignedImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.metadata.path != widget.metadata.path) {
      setState(() {
        _fetchSignedUrl();
      });
    }
  }

  void _fetchSignedUrl() {
    try {
      final service = context.read<SupabaseStorageService>();
      _signedUrlFuture = service.getSignedImageUrl(widget.metadata.path);
    } catch (_) {
      _signedUrlFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _signedUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: NeoTokens.warmBackground,
            alignment: Alignment.center,
            child: SizedBox(
              width: widget.size * 0.35,
              height: widget.size * 0.35,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: NeoTokens.black,
              ),
            ),
          );
        }

        final signedUrl = snapshot.data;
        if (signedUrl == null || signedUrl.isEmpty) {
          return Container(
            color: NeoTokens.recess,
            alignment: Alignment.center,
            child: Icon(
              AppIcons.restaurant,
              size: widget.size * 0.45,
              color: NeoTokens.inkSecondary,
            ),
          );
        }

        final pixelRatio = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
        final targetDim = (widget.size * pixelRatio).round().clamp(100, 300);

        return Image.network(
          signedUrl,
          width: widget.size,
          height: widget.size,
          cacheWidth: targetDim,
          cacheHeight: targetDim,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: NeoTokens.warmBackground,
              alignment: Alignment.center,
              child: SizedBox(
                width: widget.size * 0.35,
                height: widget.size * 0.35,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: NeoTokens.black,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: NeoTokens.recess,
              alignment: Alignment.center,
              child: Icon(
                AppIcons.brokenImage,
                size: widget.size * 0.45,
                color: NeoTokens.inkSecondary,
              ),
            );
          },
        );
      },
    );
  }
}

/// Full-width Neo-Brutalist Hero Card for displaying meal detection photo on the details screen.
class NeoImageHeroCard extends StatelessWidget {
  final MealImageMetadata imageMetadata;
  final double aspectRatio;
  final VoidCallback? onEnlarge;

  const NeoImageHeroCard({
    super.key,
    required this.imageMetadata,
    this.aspectRatio = 4 / 3,
    this.onEnlarge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NeoTokens.white,
        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
        border: Border.all(
          color: NeoTokens.black,
          width: NeoTokens.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: NeoTokens.black,
            offset: NeoTokens.shadowOffset,
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium - 2),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _HeroImageLoader(
                metadata: imageMetadata,
                onTap: () => _showEnlargedDialog(context),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: NeoTokens.hazard,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                    border: Border.all(
                      color: NeoTokens.black,
                      width: NeoTokens.borderWidth,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.cameraAlt,
                        size: AppIcons.sizeSmall,
                        color: NeoTokens.black,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Foto Pemeriksaan',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => _showEnlargedDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: NeoTokens.white,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusSmall,
                      ),
                      border: Border.all(
                        color: NeoTokens.black,
                        width: NeoTokens.borderWidth,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: NeoTokens.black,
                          offset: Offset(1.5, 1.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      AppIcons.fullscreen,
                      size: AppIcons.sizeSmall,
                      color: NeoTokens.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnlargedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(NeoTokens.space16),
          child: Container(
            decoration: BoxDecoration(
              color: NeoTokens.white,
              borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
              border: Border.all(
                color: NeoTokens.black,
                width: NeoTokens.borderWidth,
              ),
              boxShadow: const [
                BoxShadow(
                  color: NeoTokens.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(NeoTokens.radiusMedium - 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: NeoTokens.lime,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'FOTO MAKANAN',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: NeoTokens.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(dialogCtx),
                          child: const Icon(
                            AppIcons.close,
                            size: AppIcons.sizeControl,
                            color: NeoTokens.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(color: NeoTokens.black, height: 2),
                  InteractiveViewer(
                    maxScale: 4.0,
                    child: _HeroImageLoader(
                      metadata: imageMetadata,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroImageLoader extends StatefulWidget {
  final MealImageMetadata metadata;
  final VoidCallback? onTap;
  final BoxFit fit;

  const _HeroImageLoader({
    required this.metadata,
    this.onTap,
    this.fit = BoxFit.cover,
  });

  @override
  State<_HeroImageLoader> createState() => _HeroImageLoaderState();
}

class _HeroImageLoaderState extends State<_HeroImageLoader> {
  Future<String?>? _signedUrlFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchSignedUrl();
  }

  @override
  void didUpdateWidget(covariant _HeroImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.metadata.path != widget.metadata.path) {
      setState(() {
        _fetchSignedUrl();
      });
    }
  }

  void _fetchSignedUrl() {
    try {
      final service = context.read<SupabaseStorageService>();
      _signedUrlFuture = service.getSignedImageUrl(widget.metadata.path);
    } catch (_) {
      _signedUrlFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _signedUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: NeoTokens.warmBackground,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: NeoTokens.black,
            ),
          );
        }

        final signedUrl = snapshot.data;
        if (signedUrl == null || signedUrl.isEmpty) {
          return Container(
            color: NeoTokens.recess,
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.brokenImage,
                  size: AppIcons.sizeEmpty,
                  color: NeoTokens.inkSecondary,
                ),
                SizedBox(height: 8),
                Text(
                  'Gambar tidak dapat dimuat',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: NeoTokens.inkSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return GestureDetector(
          onTap: widget.onTap,
          child: Image.network(
            signedUrl,
            fit: widget.fit,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: NeoTokens.warmBackground,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: NeoTokens.black,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: NeoTokens.recess,
                alignment: Alignment.center,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.brokenImage,
                      size: AppIcons.sizeEmpty,
                      color: NeoTokens.inkSecondary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gagal memuat gambar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: NeoTokens.inkSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
