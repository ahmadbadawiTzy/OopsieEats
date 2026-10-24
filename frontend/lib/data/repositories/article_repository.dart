import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/article.dart';

class ArticleRepository {
  final FirebaseFirestore? _customFirestore;

  ArticleRepository({ApiClient? client, FirebaseFirestore? firestore})
    : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (Firebase.apps.isNotEmpty) return FirebaseFirestore.instance;
    return null;
  }

  Future<Map<String, dynamic>> getArticles({
    int? categoryId,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final db = _firestore;
    if (db == null) {
      return {
        'items': <ArticleItem>[],
        'total': 0,
        'page': page,
        'limit': limit,
      };
    }

    try {
      final snapshot = await db.collection('cms_articles').get();
      final allArticles = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id')) {
          data['id'] = int.tryParse(doc.id) ?? doc.id.hashCode.abs();
        }
        return data;
      }).toList();

      var filtered = allArticles
          .where((a) => a['status'] == 'published')
          .toList();

      if (categoryId != null) {
        filtered = filtered
            .where((a) => a['category_id'] == categoryId)
            .toList();
      }

      if (search != null && search.trim().isNotEmpty) {
        final cleanSearch = search.trim().toLowerCase();
        filtered = filtered.where((a) {
          final title = (a['title'] as String? ?? '').toLowerCase();
          final excerpt = (a['excerpt'] as String? ?? '').toLowerCase();
          return title.contains(cleanSearch) || excerpt.contains(cleanSearch);
        }).toList();
      }

      filtered.sort((a, b) {
        final da = a['published_at'] ?? a['created_at'] ?? '';
        final dbVal = b['published_at'] ?? b['created_at'] ?? '';
        return dbVal.toString().compareTo(da.toString());
      });

      final total = filtered.length;
      final start = (page - 1) * limit;
      final paginated = start >= total
          ? <Map<String, dynamic>>[]
          : filtered.skip(start).take(limit).toList();

      final items = paginated.map((j) => ArticleItem.fromJson(j)).toList();

      return {'items': items, 'total': total, 'page': page, 'limit': limit};
    } catch (_) {
      return {
        'items': <ArticleItem>[],
        'total': 0,
        'page': page,
        'limit': limit,
      };
    }
  }

  Future<ArticleItem> getArticleDetail(String slug) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 404,
        code: 'ARTICLE_NOT_FOUND',
        message: 'Artikel tidak ditemukan.',
      );
    }

    final query = await db
        .collection('cms_articles')
        .where('slug', isEqualTo: slug)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final data = Map<String, dynamic>.from(query.docs.first.data());
      if (!data.containsKey('id')) {
        data['id'] =
            int.tryParse(query.docs.first.id) ??
            query.docs.first.id.hashCode.abs();
      }
      return ArticleItem.fromJson(data);
    }

    // Try by document ID
    final doc = await db.collection('cms_articles').doc(slug).get();
    if (doc.exists && doc.data() != null) {
      final data = Map<String, dynamic>.from(doc.data()!);
      if (!data.containsKey('id')) {
        data['id'] = int.tryParse(doc.id) ?? doc.id.hashCode.abs();
      }
      return ArticleItem.fromJson(data);
    }

    throw ApiException(
      statusCode: 404,
      code: 'ARTICLE_NOT_FOUND',
      message: 'Artikel tidak ditemukan.',
    );
  }

  Future<List<CategoryItem>> getCategories() async {
    final db = _firestore;
    if (db == null) return [];

    try {
      final snapshot = await db.collection('cms_categories').get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id')) {
          data['id'] = int.tryParse(doc.id) ?? doc.id.hashCode.abs();
        }
        return CategoryItem.fromJson(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<AnnouncementItem>> getActiveAnnouncements() async {
    final db = _firestore;
    if (db == null) return [];

    try {
      final snapshot = await db
          .collection('cms_announcements')
          .where('is_active', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        if (!data.containsKey('id')) {
          data['id'] = int.tryParse(doc.id) ?? doc.id.hashCode.abs();
        }
        return AnnouncementItem.fromJson(data);
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
