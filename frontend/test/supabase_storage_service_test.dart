import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nutriview/core/config/supabase_config.dart';
import 'package:nutriview/data/services/supabase_storage_service.dart';

void main() {
  group('SupabaseConfig & Constants Tests', () {
    test('SupabaseConfig has correct constants and boundaries', () {
      expect(SupabaseConfig.bucket, 'food-history-images');
      expect(SupabaseConfig.maxUploadSizeBytes, 5 * 1024 * 1024);
      expect(SupabaseConfig.signedUrlTtl, const Duration(hours: 1));
      expect(SupabaseConfig.maxImageDimension, 1024);
      expect(SupabaseConfig.jpegQuality, 80);
    });
  });

  group('SupabaseStorageService Unit Tests', () {
    test('Image compression downscales large images to <= 1024px', () async {
      // Create a test 2000x1500 bitmap image
      final testImage = img.Image(width: 2000, height: 1500);
      img.fill(testImage, color: img.ColorRgb8(255, 0, 0));
      final pngBytes = Uint8List.fromList(img.encodePng(testImage));

      expect(pngBytes.lengthInBytes, greaterThan(0));

      final service = SupabaseStorageService();
      // In isolate / worker compression
      final metadata = await service.compressInspectionImage(pngBytes);

      expect(metadata.width, lessThanOrEqualTo(1024));
      expect(metadata.height, lessThanOrEqualTo(1024));
      expect(metadata.bytes.lengthInBytes, lessThan(SupabaseConfig.maxUploadSizeBytes));

      // Check aspect ratio preserved roughly 4:3
      final ratio = metadata.width / metadata.height;
      expect(ratio, closeTo(2000 / 1500, 0.05));
    });

    test('getSignedImageUrl returns cached URL without re-fetching', () async {
      final service = SupabaseStorageService();

      // Seed cache directly
      service.seedSignedUrlCache(
        'user1/123/food.jpg',
        'https://cached.supabase.co/storage/v1/object/sign/food-history-images/user1/123/food.jpg?token=abc',
        DateTime.now().add(const Duration(minutes: 45)),
      );

      final url = await service.getSignedImageUrl('user1/123/food.jpg');
      expect(url, contains('token=abc'));
    });
  });
}
