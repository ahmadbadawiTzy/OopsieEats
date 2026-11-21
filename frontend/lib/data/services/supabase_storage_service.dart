import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oopsieeats/core/config/supabase_config.dart';
import 'package:oopsieeats/core/profile_photo_logger.dart';
import 'package:oopsieeats/data/models/meal.dart';

class _CompressedResult {
  final Uint8List bytes;
  final int width;
  final int height;

  const _CompressedResult(this.bytes, this.width, this.height);
}

/// Standalone top-level worker function executed in an isolated background thread.
/// Decodes the source image, bakes EXIF orientation, resizes to max dimension,
/// and compresses to high-efficiency JPEG format.
_CompressedResult _compressImageWorker(Uint8List rawBytes) {
  img.Image? decoded = img.decodeImage(rawBytes);
  if (decoded == null) {
    throw const FormatException(
      'Gambar tidak valid atau format tidak didukung.',
    );
  }

  decoded = img.bakeOrientation(decoded);

  // Resize if image exceeds maximum configured dimension
  int targetW = decoded.width;
  int targetH = decoded.height;
  const maxDim = SupabaseConfig.maxImageDimension;

  if (targetW > maxDim || targetH > maxDim) {
    if (targetW >= targetH) {
      targetH = (targetH * maxDim / targetW).round();
      targetW = maxDim;
    } else {
      targetW = (targetW * maxDim / targetH).round();
      targetH = maxDim;
    }

    decoded = img.copyResize(
      decoded,
      width: targetW,
      height: targetH,
      interpolation: img.Interpolation.linear,
    );
  }

  final jpgBytes = img.encodeJpg(decoded, quality: SupabaseConfig.jpegQuality);
  return _CompressedResult(
    Uint8List.fromList(jpgBytes),
    decoded.width,
    decoded.height,
  );
}

/// Standalone top-level worker function executed in an isolated background thread.
/// Crops center square 1:1, downscales to max 512x512, and encodes to JPEG (quality: 85).
_CompressedResult _compressProfilePhotoWorker(Uint8List rawBytes) {
  img.Image? decoded = img.decodeImage(rawBytes);
  if (decoded == null) {
    throw const FormatException(
      'Gambar tidak valid atau format tidak didukung.',
    );
  }

  decoded = img.bakeOrientation(decoded);

  final w = decoded.width;
  final h = decoded.height;
  if (w != h) {
    final cropSize = w < h ? w : h;
    final x = (w - cropSize) ~/ 2;
    final y = (h - cropSize) ~/ 2;
    decoded = img.copyCrop(
      decoded,
      x: x,
      y: y,
      width: cropSize,
      height: cropSize,
    );
  }

  const maxDim = 512;
  if (decoded.width > maxDim || decoded.height > maxDim) {
    decoded = img.copyResize(
      decoded,
      width: maxDim,
      height: maxDim,
      interpolation: img.Interpolation.linear,
    );
  }

  final jpgBytes = img.encodeJpg(decoded, quality: 85);
  return _CompressedResult(
    Uint8List.fromList(jpgBytes),
    decoded.width,
    decoded.height,
  );
}

/// Service dedicated to food detection and user profile photos in Supabase Storage.
///
/// Implements least-privilege folder isolation (`food-history-images/{userId}/{mealId}/...`),
/// in-memory signed URL caching with TTL, isolate-backed image compression,
/// and resilient lifecycle cleanup.
class SupabaseStorageService {
  final SupabaseClient? _customClient;
  final String _bucket;

  // In-memory cache for generated signed URLs: path -> (url, expiresAt)
  final Map<String, ({String url, DateTime expiresAt})> _signedUrlCache = {};

  SupabaseStorageService({SupabaseClient? client, String? bucket})
    : _customClient = client,
      _bucket = bucket ?? SupabaseConfig.bucket;

  /// Validates that an identifier (such as userId) is safe and contains no directory traversal
  /// sequences, separators, or invalid characters.
  static bool isSafeIdentifier(String id) {
    if (id.isEmpty || id.length > 128) return false;
    return RegExp(r'^[a-zA-Z0-9_\-]+$').hasMatch(id);
  }

  /// Validates that an object path contains no directory traversal sequences ('../'),
  /// leading/trailing slashes, backslashes, null bytes, or percent-encoded attacks.
  static bool isSafePath(String path) {
    if (path.isEmpty || path.length > 1024) return false;
    if (path.startsWith('/') || path.endsWith('/')) return false;
    if (path.contains('\\') || path.contains('\x00')) return false;

    final lower = path.toLowerCase();
    if (lower.contains('%2e') || lower.contains('%2f') || lower.contains('%5c')) {
      return false;
    }

    final segments = path.split('/');
    for (final seg in segments) {
      if (seg.isEmpty || seg == '.' || seg == '..') {
        return false;
      }
      if (seg.contains('..')) return false;
    }
    return true;
  }

  SupabaseClient? get client {
    if (_customClient != null) return _customClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Compress and upload an inspected food photo to Supabase Storage.
  ///
  /// Returns [MealImageMetadata] containing the stored path and file attributes.
  Future<MealImageMetadata> uploadFoodImage({
    required String userId,
    required int mealId,
    required Uint8List imageBytes,
  }) async {
    if (!isSafeIdentifier(userId)) {
      throw ArgumentError(
        'Invalid userId: contains path traversal or illegal characters.',
      );
    }

    if (imageBytes.isEmpty) {
      throw ArgumentError('File gambar kosong.');
    }

    if (imageBytes.length > 20 * 1024 * 1024) {
      throw ArgumentError(
        'Ukuran foto mentah terlalu besar (> 20MB). Silakan pilih foto yang lebih kecil.',
      );
    }

    final sb = client;
    if (sb == null) {
      throw StateError('Supabase client belum diinisialisasi.');
    }

    // 1. Offload heavy image compression and resizing to background isolate
    final compressed = await Isolate.run(
      () => _compressImageWorker(imageBytes),
    );

    if (compressed.bytes.length > SupabaseConfig.maxUploadSizeBytes) {
      throw ArgumentError(
        'Ukuran foto terkompresi melebihi batas maksimal 5MB.',
      );
    }

    // 2. Generate unique, collision-resistant path under user-isolated directory
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final objectPath = '$userId/$mealId/food_$timestamp.jpg';

    // 3. Upload binary to private bucket
    await sb.storage
        .from(_bucket)
        .uploadBinary(
          objectPath,
          compressed.bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    return MealImageMetadata(
      provider: 'supabase',
      bucket: _bucket,
      path: objectPath,
      mimeType: 'image/jpeg',
      sizeBytes: compressed.bytes.length,
      width: compressed.width,
      height: compressed.height,
    );
  }

  /// Retrieves a temporary signed URL to view a private food inspection image.
  ///
  /// Enforces secure TTL (15-60 min), employs an in-memory cache to prevent
  /// rate limits, blocks directory traversal attempts, and guarantees zero fallback
  /// to public/unsigned URLs for private food images.
  Future<String?> getSignedImageUrl(
    String path, {
    Duration expiresIn = SupabaseConfig.signedUrlTtl,
  }) async {
    if (path.isEmpty || !isSafePath(path)) {
      if (path.isNotEmpty) {
        debugPrint(
          '[SupabaseStorageService] Security violation blocked: unsafe path "$path"',
        );
      }
      return null;
    }

    // Enforce secure bounded expiration TTL (15 to 60 minutes)
    final effectiveTtlSeconds = expiresIn.inSeconds.clamp(15 * 60, 60 * 60);
    final effectiveExpiresIn = Duration(seconds: effectiveTtlSeconds);

    final now = DateTime.now();
    final cached = _signedUrlCache[path];
    // Return cached URL if it has more than 5 minutes of valid lifetime remaining
    if (cached != null &&
        cached.expiresAt.difference(now) > const Duration(minutes: 5)) {
      return cached.url;
    }

    final sb = client;
    if (sb == null) return null;

    final stopwatch = Stopwatch()..start();
    try {
      final signedUrl = await sb.storage
          .from(_bucket)
          .createSignedUrl(path, effectiveExpiresIn.inSeconds);

      _signedUrlCache[path] = (url: signedUrl, expiresAt: now.add(effectiveExpiresIn));

      if (path.contains('/profile/')) {
        ProfilePhotoLogger.log(
          stage: 'STAGE_8_SIGNED_URL',
          status: 'SUCCESS',
          bucket: _bucket,
          path: path,
          durationMs: stopwatch.elapsedMilliseconds,
        );
      }

      return signedUrl;
    } catch (e) {
      if (path.contains('/profile/')) {
        ProfilePhotoLogger.log(
          stage: 'STAGE_8_SIGNED_URL',
          status: 'FAILED',
          bucket: _bucket,
          path: path,
          durationMs: stopwatch.elapsedMilliseconds,
          error: e,
        );
      }
      debugPrint(
        '[SupabaseStorageService] Failed to create signed URL for $path: $e',
      );
      // Zero fallback to public or unsigned URLs for private food history images
      return null;
    }
  }

  /// Deletes a specific food detection image from the storage bucket.
  Future<void> deleteFoodImage(String path) async {
    if (path.isEmpty || !isSafePath(path)) return;

    _signedUrlCache.remove(path);
    final sb = client;
    if (sb == null) return;

    try {
      await sb.storage.from(_bucket).remove([path]);
    } catch (e) {
      debugPrint('[SupabaseStorageService] Failed to delete image $path: $e');
    }
  }

  /// Recursively cleans up all stored food images for a given user.
  /// Used during the cascading Account Deletion workflow.
  Future<void> deleteUserFoodImages(String userId) async {
    if (userId.isEmpty || !isSafeIdentifier(userId)) return;

    final sb = client;
    if (sb == null) return;

    try {
      // List all meal directories under user folder
      final mealFolders = await sb.storage.from(_bucket).list(path: userId);
      final List<String> pathsToDelete = [];

      for (final item in mealFolders) {
        if (item.id == null && item.name.isNotEmpty) {
          // Subdirectory: list contents
          final subPath = '$userId/${item.name}';
          final subItems = await sb.storage.from(_bucket).list(path: subPath);
          for (final sub in subItems) {
            pathsToDelete.add('$subPath/${sub.name}');
          }
        } else {
          pathsToDelete.add('$userId/${item.name}');
        }
      }

      if (pathsToDelete.isNotEmpty) {
        await sb.storage.from(_bucket).remove(pathsToDelete);
        for (final p in pathsToDelete) {
          _signedUrlCache.remove(p);
        }
      }
    } catch (e) {
      debugPrint(
        '[SupabaseStorageService] Failed to purge user folder $userId: $e',
      );
    }
  }

  /// Compresses and uploads a user profile photo to Supabase Storage.
  ///
  /// Crops center 1:1, resizes to max 512px, encodes JPEG.
  /// Path pattern: `$userId/profile/profile_$timestamp.jpg`
  /// Returns the relative object path stored in the bucket.
  Future<String> uploadProfilePhoto({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    if (!isSafeIdentifier(userId)) {
      throw ArgumentError(
        'Invalid userId: contains path traversal or illegal characters.',
      );
    }

    final sb = client;
    if (sb == null) {
      ProfilePhotoLogger.log(
        stage: 'STAGE_6_CLIENT_AUTH',
        status: 'FAILED',
        uid: userId,
        bucket: _bucket,
        error: 'Supabase client belum diinisialisasi.',
      );
      throw StateError('Supabase client belum diinisialisasi.');
    }

    ProfilePhotoLogger.log(
      stage: 'STAGE_6_CLIENT_AUTH',
      status: 'SUCCESS',
      uid: userId,
      bucket: _bucket,
    );

    if (imageBytes.length > SupabaseConfig.maxUploadSizeBytes) {
      throw const FormatException('Ukuran foto terlalu besar. Maksimal 5 MB.');
    }

    final compStopwatch = Stopwatch()..start();
    final _CompressedResult compressed;
    try {
      compressed = await Isolate.run(
        () => _compressProfilePhotoWorker(imageBytes),
      );
      ProfilePhotoLogger.log(
        stage: 'STAGE_5_COMPRESSION',
        status: 'SUCCESS',
        uid: userId,
        durationMs: compStopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      ProfilePhotoLogger.log(
        stage: 'STAGE_5_COMPRESSION',
        status: 'FAILED',
        uid: userId,
        durationMs: compStopwatch.elapsedMilliseconds,
        error: e,
      );
      rethrow;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final objectPath = '$userId/profile/profile_$timestamp.jpg';

    final uploadStopwatch = Stopwatch()..start();
    try {
      await sb.storage
          .from(_bucket)
          .uploadBinary(
            objectPath,
            compressed.bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      ProfilePhotoLogger.log(
        stage: 'STAGE_7_STORAGE_UPLOAD',
        status: 'SUCCESS',
        uid: userId,
        bucket: _bucket,
        path: objectPath,
        durationMs: uploadStopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      ProfilePhotoLogger.log(
        stage: 'STAGE_7_STORAGE_UPLOAD',
        status: 'FAILED',
        uid: userId,
        bucket: _bucket,
        path: objectPath,
        durationMs: uploadStopwatch.elapsedMilliseconds,
        error: e,
      );
      rethrow;
    }

    return objectPath;
  }

  /// Deletes a specific profile photo from the storage bucket.
  Future<void> deleteProfilePhoto(String path) async {
    if (path.isEmpty || !isSafePath(path)) return;

    _signedUrlCache.remove(path);
    final sb = client;
    if (sb == null) return;

    final stopwatch = Stopwatch()..start();
    try {
      await sb.storage.from(_bucket).remove([path]);
      ProfilePhotoLogger.log(
        stage: 'STAGE_10_STORAGE_CLEANUP',
        status: 'SUCCESS',
        bucket: _bucket,
        path: path,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      ProfilePhotoLogger.log(
        stage: 'STAGE_10_STORAGE_CLEANUP',
        status: 'FAILED',
        bucket: _bucket,
        path: path,
        durationMs: stopwatch.elapsedMilliseconds,
        error: e,
      );
      debugPrint(
        '[SupabaseStorageService] Failed to delete profile photo $path: $e',
      );
    }
  }

  /// Clears the in-memory signed URL cache.
  void clearUrlCache() {
    _signedUrlCache.clear();
  }

  @visibleForTesting
  Future<({Uint8List bytes, int width, int height})> compressInspectionImage(
    Uint8List imageBytes,
  ) async {
    final result = await Isolate.run(() => _compressImageWorker(imageBytes));
    return (bytes: result.bytes, width: result.width, height: result.height);
  }

  @visibleForTesting
  Future<({Uint8List bytes, int width, int height})> compressProfilePhoto(
    Uint8List imageBytes,
  ) async {
    final result = await Isolate.run(
      () => _compressProfilePhotoWorker(imageBytes),
    );
    return (bytes: result.bytes, width: result.width, height: result.height);
  }

  @visibleForTesting
  void seedSignedUrlCache(String path, String url, DateTime expiresAt) {
    _signedUrlCache[path] = (url: url, expiresAt: expiresAt);
  }
}
