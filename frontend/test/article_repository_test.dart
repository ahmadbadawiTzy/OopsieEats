import 'package:flutter_test/flutter_test.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/models/article.dart';
import 'package:nutriview/data/repositories/article_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Article Models & Serialization Tests', () {
    test('ArticleItem.fromJson parses correctly', () {
      final json = {
        'id': 1,
        'title': 'Panduan Gizi Seimbang',
        'slug': 'panduan-gizi-seimbang',
        'excerpt': 'Mengenal piring makanku...',
        'content_markdown': '### Isi Panduan Gizi...',
        'category_id': 2,
        'category_name': 'Edukasi',
        'author_name': 'Dr. Nutrisi',
        'cover_image_url': 'https://images.unsplash.com/photo-1498837167922',
        'status': 'published',
        'published_at': '2026-10-24T00:00:00.000Z',
        'created_at': '2026-10-24T00:00:00.000Z',
      };

      final item = ArticleItem.fromJson(json);
      expect(item.id, 1);
      expect(item.title, 'Panduan Gizi Seimbang');
      expect(item.slug, 'panduan-gizi-seimbang');
      expect(item.excerpt, 'Mengenal piring makanku...');
      expect(
        item.coverImageUrl,
        'https://images.unsplash.com/photo-1498837167922',
      );
      expect(item.contentMarkdown, '### Isi Panduan Gizi...');
      expect(item.categoryId, 2);
      expect(item.categoryName, 'Edukasi');
      expect(item.authorName, 'Dr. Nutrisi');
      expect(item.status, 'published');
      expect(item.publishedAt, '2026-10-24T00:00:00.000Z');
    });

    test('ArticleItem handles null cover_image_url gracefully', () {
      final json = {'id': 2, 'title': 'Tanpa Gambar', 'slug': 'tanpa-gambar'};
      final item = ArticleItem.fromJson(json);
      expect(item.coverImageUrl, isNull);
    });

    test('CategoryItem.fromJson parses correctly', () {
      final json = {
        'id': 10,
        'name': 'Diet Sehat',
        'slug': 'diet-sehat',
        'description': 'Artikel seputar diet sehat',
      };

      final cat = CategoryItem.fromJson(json);
      expect(cat.id, 10);
      expect(cat.name, 'Diet Sehat');
      expect(cat.slug, 'diet-sehat');
      expect(cat.description, 'Artikel seputar diet sehat');
    });

    test('AnnouncementItem.fromJson parses correctly', () {
      final json = {
        'id': 100,
        'title': 'Fitur Baru Tersedia',
        'message': 'Pemindaian makanan kini berjalan langsung di HP Anda.',
        'type': 'info',
        'is_active': true,
      };

      final ann = AnnouncementItem.fromJson(json);
      expect(ann.id, 100);
      expect(ann.title, 'Fitur Baru Tersedia');
      expect(ann.type, 'info');
      expect(ann.isActive, true);
    });
  });

  group('ArticleRepository Uninitialized / Offline Tests', () {
    late ArticleRepository articleRepository;

    setUp(() {
      articleRepository = ArticleRepository();
    });

    test('getArticles returns empty list when uninitialized', () async {
      final res = await articleRepository.getArticles(limit: 5);
      final items = res['items'] as List<ArticleItem>;
      expect(items, isEmpty);
      expect(res['total'], 0);
    });

    test(
      'getArticleDetail throws ApiException on uninitialized Firestore',
      () async {
        expect(
          () => articleRepository.getArticleDetail('panduan-gizi-seimbang'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.code,
              'code',
              'ARTICLE_NOT_FOUND',
            ),
          ),
        );
      },
    );

    test('getCategories returns empty list when uninitialized', () async {
      final list = await articleRepository.getCategories();
      expect(list, isEmpty);
    });

    test(
      'getActiveAnnouncements returns empty list when uninitialized',
      () async {
        final list = await articleRepository.getActiveAnnouncements();
        expect(list, isEmpty);
      },
    );
  });
}
