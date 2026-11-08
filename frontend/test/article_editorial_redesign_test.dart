import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/core/theme.dart';
import 'package:oopsieeats/data/models/article.dart';
import 'package:oopsieeats/data/repositories/article_repository.dart';
import 'package:oopsieeats/features/article/screens/article_detail_screen.dart';
import 'package:oopsieeats/features/article/screens/article_list_screen.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  late MockArticleRepository mockArticleRepo;

  final sampleArticles = [
    ArticleItem(
      id: 1,
      title: 'Kunci Piring Sehat: Membagi Makronutrien Secara Seimbang',
      slug: 'kunci-piring-sehat',
      excerpt: 'Panduan visual mengatur porsi karbohidrat, protein, dan serat.',
      coverImageUrl: 'https://images.unsplash.com/photo-healthy-meal',
      categoryId: 1,
      categoryName: 'Panduan Gizi',
      authorName: 'Ahmad Badawi',
      status: 'published',
      contentMarkdown: '## Cara Praktis Mengatur Piring Sehat\n\nMakanan sehat tidak harus rumit.',
      publishedAt: '2026-10-28T08:00:00Z',
    ),
    ArticleItem(
      id: 2,
      title: 'Pentingnya Hidrasi Seluler untuk Metabolisme',
      slug: 'pentingnya-hidrasi',
      excerpt: 'Mengapa air putih adalah pondasi utama metabolisme tubuh kita.',
      coverImageUrl: null,
      categoryId: 2,
      categoryName: 'Gaya Hidup',
      authorName: 'Dr. Nutrisi',
      status: 'published',
      contentMarkdown: 'Konsumsi air yang cukup mencegah dehidrasi ringan.',
      publishedAt: '2026-10-27T10:00:00Z',
    ),
    ArticleItem(
      id: 3,
      title: 'Memilih Sumber Protein Berkualitas Tinggi',
      slug: 'sumber-protein',
      excerpt: 'Perbandingan asam amino dari telur, tempe, dan daging.',
      coverImageUrl: 'https://images.unsplash.com/photo-protein-sources',
      categoryId: 1,
      categoryName: 'Panduan Gizi',
      authorName: 'Tim NutriView',
      status: 'published',
      contentMarkdown: 'Protein penting untuk regenerasi jaringan tubuh.',
      publishedAt: '2026-10-26T12:00:00Z',
    ),
  ];

  final sampleCategories = [
    CategoryItem(id: 1, name: 'Panduan Gizi', slug: 'panduan-gizi'),
    CategoryItem(id: 2, name: 'Gaya Hidup', slug: 'gaya-hidup'),
  ];

  setUp(() {
    mockArticleRepo = MockArticleRepository();
    when(() => mockArticleRepo.invalidateCache()).thenReturn(null);
    when(() => mockArticleRepo.getCategories()).thenAnswer((_) async => sampleCategories);
    when(
      () => mockArticleRepo.getArticles(
        categoryId: any(named: 'categoryId'),
        search: any(named: 'search'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => {
        'items': sampleArticles,
        'total': sampleArticles.length,
        'page': 1,
        'limit': 50,
      },
    );
  });

  Widget buildTestApp({Widget? home}) {
    return Provider<ArticleRepository>.value(
      value: mockArticleRepo,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        routes: {
          AppRoutes.articleDetail: (ctx) {
            final art = ModalRoute.of(ctx)!.settings.arguments as ArticleItem;
            return ArticleDetailScreen(article: art);
          },
        },
        home: home ?? const ArticleListScreen(isTab: false),
      ),
    );
  }

  group('Editorial Neo-Brutalism Article Page Tests (Section 15)', () {
    testWidgets('renders editorial header, featured hero article, and magazine list items', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // 1. Header & Customer Subtitle
      expect(find.text('Artikel Nutrisi'), findsOneWidget);
      expect(
        find.text('Panduan makan sehat & gizi seimbang untuk keseharianmu.'),
        findsOneWidget,
      );

      // 2. Featured Hero Article (Article 1)
      expect(
        find.text('Kunci Piring Sehat: Membagi Makronutrien Secara Seimbang'),
        findsOneWidget,
      );
      expect(
        find.text('Panduan visual mengatur porsi karbohidrat, protein, dan serat.'),
        findsOneWidget,
      );
      expect(find.text('Panduan Gizi'), findsWidgets);

      // 3. Section Divider for secondary articles
      expect(find.text('BACAAN LAINNYA'), findsOneWidget);

      // 4. Secondary Articles (Article 2 & 3 in magazine layout)
      expect(find.text('Pentingnya Hidrasi Seluler untuk Metabolisme'), findsOneWidget);
      expect(find.text('Memilih Sumber Protein Berkualitas Tinggi'), findsOneWidget);

      // 5. Read button affordance
      expect(find.text('Baca Artikel'), findsWidgets);
    });

    testWidgets('tapping featured article navigates to ArticleDetailScreen with editorial standfirst', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Tap on the featured article
      await tester.tap(find.text('Kunci Piring Sehat: Membagi Makronutrien Secara Seimbang'));
      await tester.pumpAndSettle();

      // Verify ArticleDetailScreen
      expect(find.text('Artikel Nutrisi'), findsWidgets);
      expect(find.text('Ditulis oleh Ahmad Badawi'), findsOneWidget);
      expect(
        find.text('Panduan visual mengatur porsi karbohidrat, protein, dan serat.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Cara Praktis Mengatur Piring Sehat'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Informasi edukasi ini disajikan untuk panduan nutrisi harian'),
        findsOneWidget,
      );
    });

    testWidgets('responsive layout on small screen (320x568) and tablet (800x1280) with zero overflow', (tester) async {
      // 1. Small screen
      tester.view.physicalSize = const Size(320 * 2, 568 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Artikel Nutrisi'), findsOneWidget);

      // 2. Tablet view
      tester.view.physicalSize = const Size(800 * 2, 1280 * 2);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Artikel Nutrisi'), findsOneWidget);
    });

    testWidgets('renders cleanly with 1.4x system font scaling without overflow', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
          child: buildTestApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Artikel Nutrisi'), findsOneWidget);
      expect(find.text('BACAAN LAINNYA'), findsOneWidget);
    });
  });
}
