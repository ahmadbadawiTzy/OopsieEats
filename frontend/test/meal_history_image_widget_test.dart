import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/data/models/meal.dart';
import 'package:nutriview/data/services/supabase_storage_service.dart';
import 'package:nutriview/shared/widgets/neo_image_thumbnail.dart';

void main() {
  Widget buildTestableWidget(Widget child, {SupabaseStorageService? storageService}) {
    return MultiProvider(
      providers: [
        Provider<SupabaseStorageService>.value(
          value: storageService ?? SupabaseStorageService(),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(child: child),
        ),
      ),
    );
  }

  group('NeoImageThumbnail Widget Tests', () {
    testWidgets('renders fallback restaurant icon when imageMetadata is null', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const NeoImageThumbnail(
            imageMetadata: null,
            size: 64,
          ),
        ),
      );

      // Verify fallback icon appears
      expect(find.byIcon(AppIcons.restaurant), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders fallback restaurant icon when path is empty', (tester) async {
      final emptyPathMetadata = MealImageMetadata(
        provider: 'supabase',
        bucket: 'food-history-images',
        path: '',
      );

      await tester.pumpWidget(
        buildTestableWidget(
          NeoImageThumbnail(
            imageMetadata: emptyPathMetadata,
            size: 64,
          ),
        ),
      );

      expect(find.byIcon(AppIcons.restaurant), findsOneWidget);
    });

    testWidgets('NeoImageHeroCard renders badge, fullscreen icon and title', (tester) async {
      final sampleMetadata = MealImageMetadata(
        provider: 'supabase',
        bucket: 'food-history-images',
        path: 'user_123/meal_456/food.jpg',
        width: 800,
        height: 600,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          SingleChildScrollView(
            child: SizedBox(
              width: 360,
              child: NeoImageHeroCard(
                imageMetadata: sampleMetadata,
              ),
            ),
          ),
        ),
      );

      // Check text label
      expect(find.text('Foto Pemeriksaan'), findsOneWidget);
      // Check icons
      expect(find.byIcon(AppIcons.cameraAlt), findsOneWidget);
      expect(find.byIcon(AppIcons.fullscreen), findsOneWidget);
    });
  });
}
