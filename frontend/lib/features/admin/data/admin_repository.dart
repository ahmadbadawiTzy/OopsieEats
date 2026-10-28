import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/nutrition_calculator.dart';
import 'package:nutriview/data/api_client.dart';

class AdminRepository {
  final ApiClient _client;
  final fb.FirebaseAuth? _customAuth;
  final FirebaseFirestore? _customFirestore;

  AdminRepository({
    ApiClient? client,
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    dynamic storage,
  }) : _client = client ?? ApiClient(),
       _customAuth = auth,
       _customFirestore = firestore;

  fb.FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    if (Firebase.apps.isNotEmpty) return fb.FirebaseAuth.instance;
    return null;
  }

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (Firebase.apps.isNotEmpty) return FirebaseFirestore.instance;
    return null;
  }

  Future<void> _recordAuditLog({
    required String action,
    required String entityType,
    String? entityId,
    String? details,
  }) async {
    final db = _firestore;
    if (db == null) return;

    try {
      final user = _auth?.currentUser;
      final logId = DateTime.now().millisecondsSinceEpoch;
      await db.collection('cms_audit_logs').doc(logId.toString()).set({
        'id': logId,
        'user_id': user?.uid.hashCode.abs() ?? 0,
        'user_email': user?.email ?? 'admin@nutriview.id',
        'performed_by': user?.uid ?? '',
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId ?? '',
        'details': details ?? '',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  // --- Auth ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final auth = _auth;
    final db = _firestore;
    if (auth == null || db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user?.uid ?? '';
      final userDoc = await db.collection('users').doc(uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        throw ApiException(
          statusCode: 403,
          code: 'FORBIDDEN',
          message: 'Data administrator tidak ditemukan.',
        );
      }

      final data = userDoc.data()!;
      final role = data['role'] as String? ?? 'user';
      final isActive = data['is_active'] as bool? ?? true;

      if (!isActive) {
        await auth.signOut();
        throw ApiException(
          statusCode: 403,
          code: 'ACCOUNT_INACTIVE',
          message: 'Akun Anda telah dinonaktifkan.',
        );
      }

      if (role != 'admin') {
        await auth.signOut();
        throw ApiException(
          statusCode: 403,
          code: 'FORBIDDEN',
          message:
              'Akses ditolak. Akun ini tidak memiliki hak akses administrator.',
        );
      }

      final fullName = data['full_name'] as String? ?? 'Admin';
      await _client.saveToken(uid);
      await _client.saveUserSession(
        role: role,
        name: fullName,
        email: email.trim(),
      );

      await _recordAuditLog(
        action: 'login',
        entityType: 'auth',
        entityId: uid,
        details: 'Admin login: $email ($role)',
      );

      return {
        'access_token': uid,
        'token_type': 'bearer',
        'user': {
          'id': (data['id'] as num?)?.toInt() ?? uid.hashCode.abs(),
          'email': email.trim(),
          'full_name': fullName,
          'role': role,
          'is_active': true,
        },
      };
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw ApiException(
          statusCode: 401,
          code: 'INVALID_CREDENTIALS',
          message: 'Email atau kata sandi tidak valid.',
        );
      } else {
        throw ApiException(
          statusCode: 400,
          code: e.code,
          message: e.message ?? 'Gagal masuk sistem.',
        );
      }
    }
  }

  Future<void> logout() async {
    await _recordAuditLog(
      action: 'logout',
      entityType: 'auth',
      details: 'Admin logged out',
    );
    await _auth?.signOut();
    await _client.clearToken();
  }

  // --- Foods ---
  Future<Map<String, dynamic>> getFoods({
    String? search,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    final db = _firestore;
    if (db == null) {
      return {'items': [], 'total': 0, 'page': page, 'limit': limit};
    }

    final snapshot = await db.collection('foods').get();

    final allFoods = snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      final id =
          (data['id'] as num?)?.toInt() ??
          int.tryParse(doc.id) ??
          doc.id.hashCode.abs();
      data['id'] = id;

      // Ensure nutrition object is present for frontend compatibility
      if (!data.containsKey('nutrition')) {
        data['nutrition'] = {
          'calories_kcal':
              (data['calories_kcal_per_100g'] as num?)?.toDouble() ?? 0.0,
          'protein_g': (data['protein_g_per_100g'] as num?)?.toDouble() ?? 0.0,
          'carbs_g': (data['carbs_g_per_100g'] as num?)?.toDouble() ?? 0.0,
          'fat_g': (data['fat_g_per_100g'] as num?)?.toDouble() ?? 0.0,
          'source': data['source'] as String? ?? 'TKPI',
        };
      }
      return data;
    }).toList();

    var filtered = allFoods;
    if (isActive != null) {
      filtered = filtered.where((f) => f['is_active'] == isActive).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((f) {
        final name = (f['name'] as String? ?? '').toLowerCase();
        final yoloClass = (f['yolo_class'] as String? ?? '').toLowerCase();
        return name.contains(q) || yoloClass.contains(q);
      }).toList();
    }

    filtered.sort(
      (a, b) => ((a['id'] as num?)?.toInt() ?? 0).compareTo(
        (b['id'] as num?)?.toInt() ?? 0,
      ),
    );

    final total = filtered.length;
    final start = (page - 1) * limit;
    final items = start >= total
        ? []
        : filtered.skip(start).take(limit).toList();

    return {'items': items, 'total': total, 'page': page, 'limit': limit};
  }

  Future<Map<String, dynamic>> createFood(Map<String, dynamic> body) async {
    final cal =
        (body['calories_kcal_per_100g'] as num?)?.toDouble() ??
        (body['calories_kcal'] as num?)?.toDouble() ??
        0.0;
    final pro =
        (body['protein_g_per_100g'] as num?)?.toDouble() ??
        (body['protein_g'] as num?)?.toDouble() ??
        0.0;
    final carb =
        (body['carbs_g_per_100g'] as num?)?.toDouble() ??
        (body['carbs_g'] as num?)?.toDouble() ??
        0.0;
    final fat =
        (body['fat_g_per_100g'] as num?)?.toDouble() ??
        (body['fat_g'] as num?)?.toDouble() ??
        0.0;

    NutritionCalculator.validateAtwater(
      calories: cal,
      protein: pro,
      carbs: carb,
      fat: fat,
    );

    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    final id = DateTime.now().millisecondsSinceEpoch % 10000000;
    final foodData = {
      'id': id,
      'name': body['name'],
      'yolo_class': body['yolo_class'],
      'is_active': body['is_active'] ?? true,
      'calories_kcal_per_100g': cal,
      'protein_g_per_100g': pro,
      'carbs_g_per_100g': carb,
      'fat_g_per_100g': fat,
      'source': body['source'] ?? 'Kemenkes / TKPI',
      'has_nutrition_data': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    await db.collection('foods').doc(id.toString()).set(foodData);
    await _recordAuditLog(
      action: 'create',
      entityType: 'food',
      entityId: id.toString(),
      details: 'Created food: ${body['name']}',
    );

    foodData['nutrition'] = {
      'calories_kcal': cal,
      'protein_g': pro,
      'carbs_g': carb,
      'fat_g': fat,
      'source': foodData['source'],
    };
    return foodData;
  }

  Future<Map<String, dynamic>> updateFood(
    int id,
    Map<String, dynamic> body,
  ) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    final updates = Map<String, dynamic>.from(body);
    updates['updated_at'] = DateTime.now().toIso8601String();

    await db.collection('foods').doc(id.toString()).update(updates);
    await _recordAuditLog(
      action: 'update',
      entityType: 'food',
      entityId: id.toString(),
      details: 'Updated food ID: $id',
    );

    final updatedDoc = await db.collection('foods').doc(id.toString()).get();
    return Map<String, dynamic>.from(updatedDoc.data() ?? updates);
  }

  Future<Map<String, dynamic>> setFoodStatus(
    int id,
    bool isActive, {
    String? reason,
  }) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    await db.collection('foods').doc(id.toString()).update({
      'is_active': isActive,
      'deactivation_reason': reason,
      'updated_at': DateTime.now().toIso8601String(),
    });

    await _recordAuditLog(
      action: isActive ? 'activate' : 'deactivate',
      entityType: 'food',
      entityId: id.toString(),
      details: 'Status changed to $isActive, reason: $reason',
    );

    return {'id': id, 'is_active': isActive, 'reason': reason};
  }

  Future<void> deleteFood(int id) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    await db.collection('foods').doc(id.toString()).delete();
    await _recordAuditLog(
      action: 'delete',
      entityType: 'food',
      entityId: id.toString(),
      details: 'Deleted food ID: $id',
    );
  }

  // --- Articles ---
  Future<Map<String, dynamic>> getArticles({
    String? status,
    int? categoryId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final db = _firestore;
    if (db == null) {
      return {'items': [], 'total': 0, 'page': page, 'limit': limit};
    }

    final snapshot = await db.collection('cms_articles').get();
    final all = snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] =
          (data['id'] as num?)?.toInt() ??
          int.tryParse(doc.id) ??
          doc.id.hashCode.abs();
      return data;
    }).toList();

    var filtered = all;
    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((a) => a['status'] == status).toList();
    }
    if (categoryId != null) {
      filtered = filtered.where((a) => a['category_id'] == categoryId).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((a) {
        final title = (a['title'] as String? ?? '').toLowerCase();
        return title.contains(q);
      }).toList();
    }

    filtered.sort(
      (a, b) => (b['created_at'] ?? '').toString().compareTo(
        (a['created_at'] ?? '').toString(),
      ),
    );

    final total = filtered.length;
    final start = (page - 1) * limit;
    final items = start >= total
        ? []
        : filtered.skip(start).take(limit).toList();

    return {'items': items, 'total': total, 'page': page, 'limit': limit};
  }

  Future<Map<String, dynamic>> createArticle(Map<String, dynamic> body) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    final id = DateTime.now().millisecondsSinceEpoch % 10000000;
    final articleData = Map<String, dynamic>.from(body);
    articleData['id'] = id;
    articleData['created_at'] = DateTime.now().toIso8601String();
    if (articleData['status'] == 'published') {
      articleData['published_at'] = DateTime.now().toIso8601String();
    }

    await db.collection('cms_articles').doc(id.toString()).set(articleData);
    await _recordAuditLog(
      action: 'create',
      entityType: 'article',
      entityId: id.toString(),
      details: 'Created article: ${body['title']}',
    );

    return articleData;
  }

  Future<Map<String, dynamic>> updateArticle(
    int id,
    Map<String, dynamic> body,
  ) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    final updates = Map<String, dynamic>.from(body);
    updates['updated_at'] = DateTime.now().toIso8601String();

    await db.collection('cms_articles').doc(id.toString()).update(updates);
    await _recordAuditLog(
      action: 'update',
      entityType: 'article',
      entityId: id.toString(),
      details: 'Updated article ID: $id',
    );

    final doc = await db.collection('cms_articles').doc(id.toString()).get();
    return Map<String, dynamic>.from(doc.data() ?? updates);
  }

  Future<void> deleteArticle(int id) async {
    final db = _firestore;
    if (db == null) return;

    await db.collection('cms_articles').doc(id.toString()).delete();
    await _recordAuditLog(
      action: 'delete',
      entityType: 'article',
      entityId: id.toString(),
      details: 'Deleted article ID: $id',
    );
  }

  // --- Categories ---
  Future<List<dynamic>> getCategories() async {
    final db = _firestore;
    if (db == null) return [];

    final snapshot = await db.collection('cms_categories').get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] =
          (data['id'] as num?)?.toInt() ??
          int.tryParse(doc.id) ??
          doc.id.hashCode.abs();
      return data;
    }).toList();
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> body) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    final catData = Map<String, dynamic>.from(body);
    catData['id'] = id;
    catData['created_at'] = DateTime.now().toIso8601String();

    await db.collection('cms_categories').doc(id.toString()).set(catData);
    await _recordAuditLog(
      action: 'create',
      entityType: 'category',
      entityId: id.toString(),
      details: 'Created category: ${body['name']}',
    );

    return catData;
  }

  Future<Map<String, dynamic>> updateCategory(
    int id,
    Map<String, dynamic> body,
  ) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    final updates = Map<String, dynamic>.from(body);
    updates['updated_at'] = DateTime.now().toIso8601String();

    await db.collection('cms_categories').doc(id.toString()).update(updates);
    await _recordAuditLog(
      action: 'update',
      entityType: 'category',
      entityId: id.toString(),
      details: 'Updated category ID: $id',
    );

    final doc = await db.collection('cms_categories').doc(id.toString()).get();
    return Map<String, dynamic>.from(doc.data() ?? updates);
  }

  Future<void> deleteCategory(int id) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    await db.collection('cms_categories').doc(id.toString()).delete();
    await _recordAuditLog(
      action: 'delete',
      entityType: 'category',
      entityId: id.toString(),
      details: 'Deleted category ID: $id',
    );
  }

  // --- Announcements ---
  Future<Map<String, dynamic>> createAnnouncement(
    Map<String, dynamic> body,
  ) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    final annData = Map<String, dynamic>.from(body);
    annData['id'] = id;
    annData['created_at'] = DateTime.now().toIso8601String();

    await db.collection('cms_announcements').doc(id.toString()).set(annData);
    await _recordAuditLog(
      action: 'create',
      entityType: 'announcement',
      entityId: id.toString(),
      details: 'Created announcement: ${body['title']}',
    );

    return annData;
  }

  // --- Media ---
  Future<Map<String, dynamic>> getMedia({int page = 1, int limit = 20}) async {
    final db = _firestore;
    if (db == null) {
      return {'items': [], 'total': 0, 'page': page, 'limit': limit};
    }

    final snapshot = await db.collection('cms_media').get();
    final items = snapshot.docs.map((doc) => doc.data()).toList();
    return {
      'items': items,
      'total': items.length,
      'page': page,
      'limit': limit,
    };
  }

  Future<Map<String, dynamic>> uploadMedia(
    List<int> bytes,
    String filename, {
    String? mediaUrl,
  }) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    final id = DateTime.now().millisecondsSinceEpoch;
    final finalUrl =
        mediaUrl ??
        'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=800';
    final mediaData = {
      'id': id,
      'filename': filename,
      'url': finalUrl,
      'file_size': bytes.length,
      'created_at': DateTime.now().toIso8601String(),
    };
    await db.collection('cms_media').doc(id.toString()).set(mediaData);

    await _recordAuditLog(
      action: 'upload',
      entityType: 'media',
      entityId: id.toString(),
      details: 'Uploaded media: $filename ($finalUrl)',
    );

    return mediaData;
  }

  Future<void> deleteMedia(int id) async {
    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    await db.collection('cms_media').doc(id.toString()).delete();
    await _recordAuditLog(
      action: 'delete',
      entityType: 'media',
      entityId: id.toString(),
      details: 'Deleted media ID: $id',
    );
  }

  // --- Audit Logs ---
  Future<Map<String, dynamic>> getAuditLogs({
    String? entityType,
    String? entityId,
    int page = 1,
    int limit = 20,
  }) async {
    final db = _firestore;
    if (db == null) {
      return {'items': [], 'total': 0, 'page': page, 'limit': limit};
    }

    final snapshot = await db.collection('cms_audit_logs').get();
    var all = snapshot.docs.map((d) => d.data()).toList();

    if (entityType != null && entityType.isNotEmpty) {
      all = all.where((l) => l['entity_type'] == entityType).toList();
    }
    if (entityId != null && entityId.isNotEmpty) {
      all = all.where((l) => l['entity_id'] == entityId).toList();
    }

    all.sort(
      (a, b) => (b['created_at'] ?? '').toString().compareTo(
        (a['created_at'] ?? '').toString(),
      ),
    );

    final total = all.length;
    final start = (page - 1) * limit;
    final items = start >= total ? [] : all.skip(start).take(limit).toList();

    return {'items': items, 'total': total, 'page': page, 'limit': limit};
  }

  // --- User Management ---
  Future<Map<String, dynamic>> getUsers({
    String? search,
    String? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    final db = _firestore;
    if (db == null) {
      return {'items': [], 'total': 0, 'page': page, 'limit': limit};
    }

    final snapshot = await db.collection('users').get();
    final allUsers = snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] =
          (data['id'] as num?)?.toInt() ??
          int.tryParse(doc.id) ??
          doc.id.hashCode.abs();
      return data;
    }).toList();

    var filtered = allUsers;
    if (role != null && role.isNotEmpty) {
      filtered = filtered.where((u) => u['role'] == role).toList();
    }
    if (isActive != null) {
      filtered = filtered.where((u) => u['is_active'] == isActive).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      filtered = filtered.where((u) {
        final email = (u['email'] as String? ?? '').toLowerCase();
        final name = (u['full_name'] as String? ?? '').toLowerCase();
        return email.contains(q) || name.contains(q);
      }).toList();
    }

    filtered.sort(
      (a, b) => (b['created_at'] ?? '').toString().compareTo(
        (a['created_at'] ?? '').toString(),
      ),
    );

    final total = filtered.length;
    final start = (page - 1) * limit;
    final items = start >= total
        ? []
        : filtered.skip(start).take(limit).toList();

    return {'items': items, 'total': total, 'page': page, 'limit': limit};
  }

  Future<Map<String, dynamic>> setUserStatus(
    int userId,
    bool isActive, {
    String? reason,
  }) async {
    final callerRole = await _client.getRole() ?? '';

    // Enforce role authorization: Only admin can activate or deactivate accounts
    if (callerRole != 'admin') {
      throw ApiException(
        statusCode: 403,
        code: 'FORBIDDEN',
        message:
            'Hanya Administrator yang berhak mengubah status akun pengguna.',
      );
    }

    final db = _firestore;
    if (db == null) {
      throw ApiException(
        statusCode: 500,
        code: 'FIREBASE_NOT_INITIALIZED',
        message: 'Firebase belum terinisialisasi.',
      );
    }

    final currentUid = _auth?.currentUser?.uid ?? '';
    final currentEmail =
        _auth?.currentUser?.email ?? await _client.getUserEmail();

    // 1. Self-lockout protection
    final targetDocQuery = await db
        .collection('users')
        .where('id', isEqualTo: userId)
        .get();
    DocumentSnapshot<Map<String, dynamic>>? targetDoc;
    if (targetDocQuery.docs.isNotEmpty) {
      targetDoc = targetDocQuery.docs.first;
    } else {
      final byId = await db.collection('users').doc(userId.toString()).get();
      if (byId.exists) targetDoc = byId;
    }

    if (targetDoc != null && targetDoc.exists) {
      final targetData = targetDoc.data()!;
      final targetUid = targetData['uid'] as String? ?? targetDoc.id;
      final targetEmail = targetData['email'] as String? ?? '';

      if (targetUid == currentUid ||
          (currentEmail != null &&
              targetEmail.toLowerCase() == currentEmail.toLowerCase())) {
        throw ApiException(
          statusCode: 400,
          code: 'SELF_LOCKOUT_FORBIDDEN',
          message: 'Anda tidak dapat menonaktifkan akun Anda sendiri.',
        );
      }

      // 2. Last admin protection
      final targetRole = targetData['role'] as String? ?? 'user';
      if (targetRole == 'admin' && !isActive) {
        final adminsSnapshot = await db
            .collection('users')
            .where('role', isEqualTo: 'admin')
            .where('is_active', isEqualTo: true)
            .get();

        if (adminsSnapshot.docs.length <= 1) {
          throw ApiException(
            statusCode: 400,
            code: 'LAST_ADMIN_PROTECTION',
            message: 'Tidak dapat menonaktifkan admin terakhir.',
          );
        }
      }

      await targetDoc.reference.update({
        'is_active': isActive,
        'deactivation_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    await _recordAuditLog(
      action: isActive ? 'activate' : 'deactivate',
      entityType: 'user',
      entityId: userId.toString(),
      details: 'User status set to $isActive (reason: $reason)',
    );

    return {'id': userId, 'is_active': isActive, 'reason': reason};
  }
}
