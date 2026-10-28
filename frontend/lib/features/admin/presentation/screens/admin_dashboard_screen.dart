import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/features/admin/data/admin_repository.dart';
import 'package:nutriview/features/admin/presentation/widgets/atwater_checker_widget.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/features/admin/presentation/widgets/admin_components.dart';
import 'package:nutriview/features/admin/presentation/widgets/admin_sidebar.dart';
import 'package:nutriview/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:nutriview/features/admin/presentation/widgets/article_preview_modal.dart';
import 'package:nutriview/features/admin/presentation/widgets/category_manager_modal.dart';
import 'package:nutriview/features/admin/presentation/widgets/food_detail_modal.dart';
import 'package:nutriview/features/admin/presentation/widgets/media_manager_modal.dart';
import 'package:nutriview/features/admin/presentation/widgets/user_detail_modal.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String adminEmail;
  final String adminRole;
  final String adminName;

  const AdminDashboardScreen({
    super.key,
    required this.adminEmail,
    required this.adminRole,
    required this.adminName,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _adminRepo = AdminRepository();

  // State: Foods
  List<dynamic> _foods = [];
  bool _isLoadingFoods = false;
  String _foodSearchQuery = '';
  bool? _foodFilterActive;
  final _foodSearchController = TextEditingController();

  // State: Articles
  List<dynamic> _articles = [];
  bool _isLoadingArticles = false;

  // State: Media
  List<dynamic> _mediaList = [];

  // State: Audit Logs
  List<dynamic> _auditLogs = [];
  bool _isLoadingAudit = false;
  String? _auditFilterEntity;

  // State: Users
  List<dynamic> _users = [];
  bool _isLoadingUsers = false;
  String _userSearchQuery = '';
  String? _userRoleFilter;
  final _userSearchController = TextEditingController();

  // State: Simulator Tab
  final _simNameCtrl = TextEditingController(text: 'Simulasi Menu Sehat');
  final _simCalCtrl = TextEditingController(text: '200.0');
  final _simProCtrl = TextEditingController(text: '15.0');
  final _simCarbCtrl = TextEditingController(text: '20.0');
  final _simFatCtrl = TextEditingController(text: '6.7');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _foodSearchController.dispose();
    _userSearchController.dispose();
    _simNameCtrl.dispose();
    _simCalCtrl.dispose();
    _simProCtrl.dispose();
    _simCarbCtrl.dispose();
    _simFatCtrl.dispose();
    super.dispose();
  }

  void _loadAllData() {
    _fetchFoods();
    _fetchArticles();
    _fetchMedia();
    _fetchAuditLogs();
    _fetchUsers();
  }

  Future<void> _fetchFoods() async {
    setState(() => _isLoadingFoods = true);
    try {
      final foodsResponse = await _adminRepo.getFoods(
        search: _foodSearchQuery,
        isActive: _foodFilterActive,
        limit: 50,
      );
      if (mounted) {
        setState(() => _foods = foodsResponse['items'] as List<dynamic>? ?? []);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memuat makanan: $e');
    } finally {
      if (mounted) setState(() => _isLoadingFoods = false);
    }
  }

  Future<void> _fetchArticles() async {
    setState(() => _isLoadingArticles = true);
    try {
      final articlesResponse = await _adminRepo.getArticles(limit: 50);
      if (mounted) {
        setState(
          () => _articles = articlesResponse['items'] as List<dynamic>? ?? [],
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingArticles = false);
    }
  }

  Future<void> _fetchMedia() async {
    try {
      final mediaResponse = await _adminRepo.getMedia(limit: 50);
      if (mounted) {
        setState(
          () => _mediaList = mediaResponse['items'] as List<dynamic>? ?? [],
        );
      }
    } catch (_) {}
  }

  Future<void> _fetchAuditLogs() async {
    setState(() => _isLoadingAudit = true);
    try {
      final auditLogsResponse = await _adminRepo.getAuditLogs(
        entityType: _auditFilterEntity,
        limit: 40,
      );
      if (mounted) {
        setState(
          () => _auditLogs = auditLogsResponse['items'] as List<dynamic>? ?? [],
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingAudit = false);
    }
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final usersResponse = await _adminRepo.getUsers(
        search: _userSearchQuery,
        role: _userRoleFilter,
        limit: 50,
      );
      if (mounted) {
        setState(() => _users = usersResponse['items'] as List<dynamic>? ?? []);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memuat pengguna: $e');
    } finally {
      if (mounted) setState(() => _isLoadingUsers = false);
    }
  }

  Future<void> _confirmToggleUserStatus(
    int userId,
    bool currentStatus,
    String email,
  ) async {
    final effectiveRole = widget.adminRole.toLowerCase() == 'user'
        ? 'user'
        : 'admin';
    if (effectiveRole != 'admin') {
      _showErrorSnackBar(
        'Hanya Administrator yang berhak mengubah status akun pengguna.',
      );
      return;
    }
    final confirmed = await NeoDialog.show(
      context,
      title: currentStatus ? 'Nonaktifkan Akun?' : 'Aktifkan Akun?',
      message: currentStatus
          ? 'Akun $email tidak akan dapat login lagi sampai diaktifkan kembali oleh administrator.'
          : 'Akun $email akan diaktifkan dan dapat login kembali ke aplikasi.',
      confirmText: currentStatus ? 'Nonaktifkan' : 'Aktifkan',
      cancelText: 'Batal',
      confirmColor: currentStatus ? NeoTokens.coralRed : NeoTokens.primaryGreen,
      icon: currentStatus ? AppIcons.block : AppIcons.checkCircleOutline,
    );

    if (confirmed == true && mounted) {
      try {
        await _adminRepo.setUserStatus(
          userId,
          !currentStatus,
          reason: 'Diubah dari dashboard manajemen pengguna',
        );
        _showSuccessSnackBar('Status akun $email berhasil diubah.');
        _fetchUsers();
        _fetchAuditLogs();
      } on ApiException catch (e) {
        _showErrorSnackBar(e.message);
      } catch (e) {
        _showErrorSnackBar('Gagal mengubah status akun: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    NeoSnackBars.error(context, message);
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    NeoSnackBars.success(context, message);
  }

  Future<void> _confirmDeleteFood(int foodId, String foodName) async {
    final confirmed = await NeoDialog.show(
      context,
      title: 'Hapus Makanan?',
      message:
          'Apakah Anda yakin ingin menghapus "$foodName" dari katalog pangan secara permanen? Data yang telah dihapus tidak dapat dipulihkan.',
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
      confirmColor: NeoTokens.alert,
      icon: AppIcons.deleteForever,
    );

    if (confirmed == true && mounted) {
      try {
        await _adminRepo.deleteFood(foodId);
        _showSuccessSnackBar('Makanan "$foodName" berhasil dihapus.');
        _fetchFoods();
        _fetchAuditLogs();
      } on ApiException catch (e) {
        _showErrorSnackBar(e.message);
      } catch (e) {
        _showErrorSnackBar('Gagal menghapus makanan: $e');
      }
    }
  }

  Future<void> _confirmDeleteArticle(int articleId, String title) async {
    final confirmed = await NeoDialog.show(
      context,
      title: 'Hapus Artikel?',
      message:
          'Apakah Anda yakin ingin menghapus artikel "$title"? Artikel ini akan dihapus secara permanen dari basis data CMS.',
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
      confirmColor: NeoTokens.alert,
      icon: AppIcons.deleteForever,
    );

    if (confirmed == true && mounted) {
      try {
        await _adminRepo.deleteArticle(articleId);
        _showSuccessSnackBar('Artikel "$title" berhasil dihapus.');
        _fetchArticles();
        _fetchAuditLogs();
      } on ApiException catch (e) {
        _showErrorSnackBar(e.message);
      } catch (e) {
        _showErrorSnackBar('Gagal menghapus artikel: $e');
      }
    }
  }

  void _openCategoriesManager() {
    CategoryManagerModal.show(
      context,
      adminRepo: _adminRepo,
      onDataChanged: () {
        _fetchArticles();
        _fetchAuditLogs();
      },
    );
  }

  void _openMediaManager() {
    MediaManagerModal.show(
      context,
      adminRepo: _adminRepo,
      onDataChanged: () {
        _fetchMedia();
        _fetchAuditLogs();
      },
    );
  }

  void _openFoodDetail(Map<String, dynamic> food) {
    final bool isActive = food['is_active'] == true;
    FoodDetailModal.show(
      context,
      food: food,
      onEdit: () => _showFoodFormSheet(initialFood: food),
      onToggleStatus: () async {
        try {
          await _adminRepo.setFoodStatus(
            food['id'],
            !isActive,
            reason: 'Diubah via detail modal pangan',
          );
          _showSuccessSnackBar('Status makanan berhasil diperbarui.');
          _fetchFoods();
          _fetchAuditLogs();
        } catch (e) {
          _showErrorSnackBar('Gagal mengubah status makanan: $e');
        }
      },
      onDelete: () => _confirmDeleteFood(food['id'], food['name'] ?? ''),
    );
  }

  void _openArticlePreview(Map<String, dynamic> article) {
    final bool isPublished = article['status'] == 'published';
    ArticlePreviewModal.show(
      context,
      article: article,
      onEdit: () => _showArticleFormSheet(initialArticle: article),
      onToggleStatus: () async {
        try {
          final nextStatus = isPublished ? 'draft' : 'published';
          await _adminRepo.updateArticle(article['id'], {'status': nextStatus});
          _showSuccessSnackBar(
            isPublished
                ? 'Artikel dipindahkan ke draft.'
                : 'Artikel telah dipublikasikan.',
          );
          _fetchArticles();
          _fetchAuditLogs();
        } catch (e) {
          _showErrorSnackBar('Gagal mengubah status artikel: $e');
        }
      },
      onDelete: () =>
          _confirmDeleteArticle(article['id'], article['title'] ?? ''),
    );
  }

  void _openUserDetail(Map<String, dynamic> user) {
    final int userId = (user['id'] as num?)?.toInt() ?? 0;
    final bool isActive = user['is_active'] != false;
    final String email = user['email'] as String? ?? '';
    UserDetailModal.show(
      context,
      user: user,
      onToggleStatus: () => _confirmToggleUserStatus(userId, isActive, email),
    );
  }

  // ========================================================================
  // REUSABLE NEO-BRUTALIST UI HELPERS (FULL UI/UX PARITY)
  // ========================================================================
  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = NeoTokens.lime,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : NeoTokens.paper,
            borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
            border: Border.all(
              color: NeoTokens.ink,
              width: isSelected
                  ? NeoTokens.borderWidth
                  : NeoTokens.borderWidthThin,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: NeoTokens.ink,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: NeoTokens.ink,
                      offset: Offset(1, 1),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: NeoTokens.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
    required VoidCallback onClear,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: NeoTokens.paper,
        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
        border: Border.all(
          color: NeoTokens.ink,
          width: NeoTokens.borderWidthThin,
        ),
        boxShadow: NeoTokens.neoBoxShadowSmall(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              AppIcons.search,
              size: AppIcons.sizeToolbar,
              color: NeoTokens.ink,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: NeoTokens.ink,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: NeoTokens.inkMuted,
                  fontWeight: FontWeight.w500,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: IconButton(
                icon: const Icon(
                  AppIcons.close,
                  size: AppIcons.sizeControl,
                  color: NeoTokens.ink,
                ),
                onPressed: onClear,
                tooltip: 'Hapus pencarian',
                splashRadius: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(NeoTokens.space24),
        child: NeoCard(
          backgroundColor: NeoTokens.paper,
          padding: const EdgeInsets.all(NeoTokens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: NeoTokens.hazard,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  border: Border.all(
                    color: NeoTokens.ink,
                    width: NeoTokens.borderWidth,
                  ),
                  boxShadow: NeoTokens.neoBoxShadowSmall(),
                ),
                child: Icon(
                  icon,
                  size: AppIcons.sizeState,
                  color: NeoTokens.ink,
                ),
              ),
              const SizedBox(height: NeoTokens.space16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: NeoTokens.ink,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: NeoTokens.space8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: NeoTokens.inkSecondary,
                  height: 1.4,
                ),
              ),
              if (buttonText != null && onAction != null) ...[
                const SizedBox(height: NeoTokens.space16),
                NeoButton(
                  text: buttonText,
                  variant: NeoButtonVariant.primary,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState({String message = 'Memuat data...'}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NeoTokens.paper,
              borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
              border: Border.all(
                color: NeoTokens.ink,
                width: NeoTokens.borderWidth,
              ),
              boxShadow: NeoTokens.neoBoxShadowSmall(),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(NeoTokens.ink),
            ),
          ),
          const SizedBox(height: NeoTokens.space12),
          Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: NeoTokens.ink,
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGOUT HANDLER (WITH CONFIRMATION & NAVIGATION RESET) ---
  Future<void> _handleLogout() async {
    final confirmed = await NeoDialog.show(
      context,
      title: 'Keluar dari Portal Admin?',
      message:
          'Apakah Anda yakin ingin mengakhiri sesi admin "${widget.adminName}"?',
      confirmText: 'Ya, Keluar',
      cancelText: 'Batal',
      confirmColor: NeoTokens.coralRed,
      icon: AppIcons.logout,
    );

    if (confirmed == true && mounted) {
      final auth = context.read<AuthProvider>();
      final nav = Navigator.of(context);
      await auth.logout();
      if (!mounted) return;
      nav.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  // --- FOOD BOTTOM SHEET FORM (NO OVERFLOW) ---
  void _showFoodFormSheet({Map<String, dynamic>? initialFood}) {
    final isEdit = initialFood != null;
    final nameCtrl = TextEditingController(text: initialFood?['name'] ?? '');
    final yoloCtrl = TextEditingController(
      text: initialFood?['yolo_class'] ?? '',
    );
    final calCtrl = TextEditingController(
      text: initialFood?['nutrition']?['calories_kcal']?.toString() ?? '150.0',
    );
    final proCtrl = TextEditingController(
      text: initialFood?['nutrition']?['protein_g']?.toString() ?? '10.0',
    );
    final carbCtrl = TextEditingController(
      text: initialFood?['nutrition']?['carbs_g']?.toString() ?? '15.0',
    );
    final fatCtrl = TextEditingController(
      text: initialFood?['nutrition']?['fat_g']?.toString() ?? '5.0',
    );
    final srcCtrl = TextEditingController(
      text: initialFood?['nutrition']?['source'] ?? 'Kemenkes TKPI',
    );
    final reasonCtrl = TextEditingController(
      text: isEdit
          ? 'Pembaruan data nutrisi'
          : 'Pendaftaran makanan baru ke katalog',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final double calVal = double.tryParse(calCtrl.text) ?? 0.0;
            final double proVal = double.tryParse(proCtrl.text) ?? 0.0;
            final double carbVal = double.tryParse(carbCtrl.text) ?? 0.0;
            final double fatVal = double.tryParse(fatCtrl.text) ?? 0.0;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                color: NeoTokens.warmBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  top: BorderSide(color: NeoTokens.ink, width: 3),
                  left: BorderSide(color: NeoTokens.ink, width: 3),
                  right: BorderSide(color: NeoTokens.ink, width: 3),
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle Bar
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: NeoTokens.ink,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'EDIT NUTRISI PANGAN' : 'TAMBAH PANGAN BARU',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(AppIcons.close, color: NeoTokens.ink),
                        tooltip: 'Tutup',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: NeoTokens.ink, thickness: 2),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          NeoInput(
                            controller: nameCtrl,
                            label: 'NAMA MAKANAN',
                            hintText: 'misal: Soto Ayam Lamongan',
                          ),
                          const SizedBox(height: 12),
                          NeoInput(
                            controller: yoloCtrl,
                            label: 'LABEL KELAS YOLO (OPSIONAL)',
                            hintText: 'misal: soto_ayam',
                          ),
                          const SizedBox(height: 12),
                          NeoInput(
                            controller: srcCtrl,
                            label: 'SUMBER DATA GIZI',
                            hintText: 'misal: Kemenkes TKPI 2024 / Uji Lab IPB',
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'NILAI GIZI (PER 100 GRAM)',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: NeoTokens.inkSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: NeoInput(
                                  controller: calCtrl,
                                  label: 'KALORI (KKAL)',
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setSheetState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: NeoInput(
                                  controller: proCtrl,
                                  label: 'PROTEIN (G)',
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setSheetState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: NeoInput(
                                  controller: carbCtrl,
                                  label: 'KARBO (G)',
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setSheetState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: NeoInput(
                                  controller: fatCtrl,
                                  label: 'LEMAK (G)',
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setSheetState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          AtwaterCheckerWidget(
                            calories: calVal,
                            protein: proVal,
                            carbs: carbVal,
                            fat: fatVal,
                          ),
                          const SizedBox(height: 12),
                          NeoInput(
                            controller: reasonCtrl,
                            label: 'ALASAN PERUBAHAN (LOG AUDIT)',
                            hintText: 'Wajib diisi untuk audit trail',
                          ),
                          const SizedBox(height: 20),
                          NeoButton(
                            text: isEdit
                                ? 'SIMPAN PERUBAHAN'
                                : 'TAMBAHKAN KE KATALOG',
                            variant: NeoButtonVariant.primary,
                            onPressed: () async {
                              if (nameCtrl.text.trim().isEmpty) {
                                _showErrorSnackBar('Nama makanan wajib diisi.');
                                return;
                              }
                              final cal = double.tryParse(calCtrl.text) ?? 0.0;
                              final pro = double.tryParse(proCtrl.text) ?? 0.0;
                              final carb =
                                  double.tryParse(carbCtrl.text) ?? 0.0;
                              final fat = double.tryParse(fatCtrl.text) ?? 0.0;

                              final payload = {
                                'name': nameCtrl.text.trim(),
                                if (yoloCtrl.text.trim().isNotEmpty)
                                  'yolo_class': yoloCtrl.text.trim(),
                                'calories_kcal': cal,
                                'protein_g': pro,
                                'carbs_g': carb,
                                'fat_g': fat,
                                'source': srcCtrl.text.trim(),
                                'edit_reason': reasonCtrl.text.trim(),
                              };

                              try {
                                if (isEdit) {
                                  await _adminRepo.updateFood(
                                    initialFood['id'],
                                    payload,
                                  );
                                  _showSuccessSnackBar(
                                    'Makanan berhasil diperbarui.',
                                  );
                                } else {
                                  await _adminRepo.createFood(payload);
                                  _showSuccessSnackBar(
                                    'Makanan baru berhasil ditambahkan.',
                                  );
                                }
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                                _fetchFoods();
                                _fetchAuditLogs();
                              } catch (e) {
                                _showErrorSnackBar(
                                  e is ApiException
                                      ? e.message
                                      : 'Gagal menyimpan: $e',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- ARTICLE BOTTOM SHEET FORM ---
  void _showArticleFormSheet({Map<String, dynamic>? initialArticle}) {
    final isEdit = initialArticle != null;
    final titleCtrl = TextEditingController(
      text: initialArticle?['title'] ?? '',
    );
    final excerptCtrl = TextEditingController(
      text: initialArticle?['excerpt'] ?? '',
    );
    final coverImageUrlCtrl = TextEditingController(
      text: initialArticle?['cover_image_url'] ?? '',
    );
    final contentCtrl = TextEditingController(
      text: initialArticle?['content_markdown'] ?? '',
    );
    String statusVal = initialArticle?['status'] ?? 'draft';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                color: NeoTokens.warmBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  top: BorderSide(color: NeoTokens.ink, width: 3),
                  left: BorderSide(color: NeoTokens.ink, width: 3),
                  right: BorderSide(color: NeoTokens.ink, width: 3),
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: NeoTokens.ink,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'EDIT ARTIKEL GIZI' : 'TULIS ARTIKEL BARU',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(AppIcons.close, color: NeoTokens.ink),
                        tooltip: 'Tutup',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: NeoTokens.ink, thickness: 2),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          NeoInput(
                            controller: titleCtrl,
                            label: 'JUDUL ARTIKEL',
                            hintText: 'misal: Panduan Menu Sehat Harian',
                          ),
                          const SizedBox(height: 12),
                          NeoInput(
                            controller: excerptCtrl,
                            label: 'RINGKASAN SINGKAT',
                            hintText: 'Ringkasan artikel dalam 1-2 kalimat...',
                          ),
                          const SizedBox(height: 12),
                          NeoInput(
                            controller: coverImageUrlCtrl,
                            label: 'URL GAMBAR SAMPUL (OPSIONAL)',
                            hintText: 'https://images.unsplash.com/...',
                            onChanged: (_) => setSheetState(() {}),
                          ),
                          if (coverImageUrlCtrl.text.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                NeoTokens.radiusSmall,
                              ),
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: NeoTokens.recess,
                                  border: Border.all(
                                    color: NeoTokens.ink,
                                    width: NeoTokens.borderWidthThin,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    NeoTokens.radiusSmall,
                                  ),
                                ),
                                child: Image.network(
                                  coverImageUrlCtrl.text.trim(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          AppIcons.brokenImage,
                                          size: AppIcons.sizeControl,
                                          color: NeoTokens.coralRed,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'URL gambar tidak dapat dimuat',
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: NeoTokens.coralRed,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  loadingBuilder: (_, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          NeoInput(
                            controller: contentCtrl,
                            label: 'ISI ARTIKEL (MARKDOWN)',
                            hintText: 'Tuliskan isi artikel edukasi di sini...',
                            maxLines: 6,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Text(
                                'STATUS: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterPill(
                                label: 'Draf',
                                isSelected: statusVal == 'draft',
                                activeColor: NeoTokens.hazard,
                                onTap: () =>
                                    setSheetState(() => statusVal = 'draft'),
                              ),
                              _buildFilterPill(
                                label: 'Publik',
                                isSelected: statusVal == 'published',
                                activeColor: NeoTokens.lime,
                                onTap: () => setSheetState(
                                  () => statusVal = 'published',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          NeoButton(
                            text: isEdit
                                ? 'SIMPAN ARTIKEL'
                                : 'PUBLIKASIKAN ARTIKEL',
                            variant: NeoButtonVariant.primary,
                            onPressed: () async {
                              if (titleCtrl.text.trim().isEmpty ||
                                  contentCtrl.text.trim().isEmpty) {
                                _showErrorSnackBar(
                                  'Judul dan isi artikel tidak boleh kosong.',
                                );
                                return;
                              }
                              final coverUrl = coverImageUrlCtrl.text.trim();
                              if (coverUrl.isNotEmpty &&
                                  !coverUrl.startsWith('http://') &&
                                  !coverUrl.startsWith('https://')) {
                                _showErrorSnackBar(
                                  'URL gambar harus diawali dengan http:// atau https://',
                                );
                                return;
                              }
                              final payload = {
                                'title': titleCtrl.text.trim(),
                                'excerpt': excerptCtrl.text.trim(),
                                'content_markdown': contentCtrl.text.trim(),
                                'status': statusVal,
                                if (coverUrl.isNotEmpty)
                                  'cover_image_url': coverUrl,
                              };
                              try {
                                if (isEdit) {
                                  await _adminRepo.updateArticle(
                                    initialArticle['id'],
                                    payload,
                                  );
                                  _showSuccessSnackBar(
                                    'Artikel berhasil diperbarui.',
                                  );
                                } else {
                                  await _adminRepo.createArticle(payload);
                                  _showSuccessSnackBar(
                                    'Artikel baru berhasil dibuat.',
                                  );
                                }
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                                _fetchArticles();
                              } catch (e) {
                                _showErrorSnackBar(
                                  e is ApiException
                                      ? e.message
                                      : 'Gagal menyimpan: $e',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'RINGKASAN HUD';
      case 1:
        return 'KATALOG PANGAN';
      case 2:
        return 'SIMULATOR ATWATER';
      case 3:
        return 'ARTIKEL EDUKASI GIZI';
      case 4:
        return 'MANAJEMEN PENGGUNA';
      case 5:
        return 'LOG AUDIT TRAIL';
      default:
        return 'DASHBOARD';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 900;

        if (isWideScreen) {
          return Scaffold(
            backgroundColor: NeoTokens.warmBackground,
            body: Row(
              children: [
                AdminSidebar(
                  selectedIndex: _tabController.index,
                  onItemSelected: (index) {
                    setState(() {
                      _tabController.animateTo(index);
                    });
                  },
                  adminName: widget.adminName,
                  adminEmail: widget.adminEmail,
                  adminRole: widget.adminRole,
                  onOpenUserMode: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.dashboard,
                    );
                  },
                  onLogout: _handleLogout,
                  onOpenCategories: _openCategoriesManager,
                  onOpenMedia: _openMediaManager,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          color: NeoTokens.paper,
                          border: Border(
                            bottom: BorderSide(
                              color: NeoTokens.ink,
                              width: NeoTokens.borderWidth,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'PORTAL ADMIN',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: NeoTokens.inkSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '/',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: NeoTokens.inkSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getTabTitle(_tabController.index),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: NeoTokens.ink,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                NeoButton(
                                  text: 'Segarkan',
                                  prefixIcon: AppIcons.refresh,
                                  height: 38,
                                  isFullWidth: false,
                                  variant: NeoButtonVariant.secondary,
                                  onPressed: _loadAllData,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSummaryTab(),
                            _buildFoodsTab(),
                            _buildAtwaterTab(),
                            _buildArticlesTab(),
                            _buildUsersTab(),
                            _buildAuditTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: NeoTokens.warmBackground,
          drawer: Drawer(
            width: NeoTokens.sidebarWidth,
            backgroundColor: NeoTokens.canvas,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: AdminSidebar(
              selectedIndex: _tabController.index,
              onItemSelected: (index) {
                setState(() {
                  _tabController.animateTo(index);
                });
              },
              adminName: widget.adminName,
              adminEmail: widget.adminEmail,
              adminRole: widget.adminRole,
              onOpenUserMode: () {
                Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              },
              onLogout: _handleLogout,
              onOpenCategories: _openCategoriesManager,
              onOpenMedia: _openMediaManager,
            ),
          ),
          appBar: AppBar(
            toolbarHeight: 56,
            leading: Builder(
              builder: (drawerCtx) => IconButton(
                icon: const Icon(
                  AppIcons.menu,
                  size: AppIcons.sizeToolbar,
                  color: NeoTokens.ink,
                ),
                tooltip: 'Buka Menu Admin',
                onPressed: () => Scaffold.of(drawerCtx).openDrawer(),
              ),
            ),
            backgroundColor: NeoTokens.paper,
            elevation: 0,
            titleSpacing: 0,
            title: const Text(
              'NutriView',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: NeoTokens.ink,
                letterSpacing: -0.5,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(NeoTokens.borderWidthThin),
              child: Container(
                color: NeoTokens.ink,
                height: NeoTokens.borderWidthThin,
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSummaryTab(),
              _buildFoodsTab(),
              _buildAtwaterTab(),
              _buildArticlesTab(),
              _buildUsersTab(),
              _buildAuditTab(),
            ],
          ),
        );
      },
    );
  }

  // ========================================================================
  // TAB 1: RINGKASAN HUD (RESPONSIVE GRID WITHOUT OVERFLOW)
  // ========================================================================
  Widget _buildSummaryTab() {
    final activeCount = _foods.where((f) => f['is_active'] == true).length;
    final publishedCount = _articles
        .where((a) => a['status'] == 'published')
        .length;

    return RefreshIndicator(
      onRefresh: () async => _loadAllData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stat Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'TOTAL PANGAN',
                  value: '$activeCount',
                  subtitle: '${_foods.length} terdaftar',
                  stripeColor: NeoTokens.lime,
                  icon: AppIcons.fastfood,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'ARTIKEL TERBIT',
                  value: '$publishedCount',
                  subtitle: '${_articles.length} total draft/live',
                  stripeColor: NeoTokens.cobalt,
                  icon: AppIcons.menuBook,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'ASET MEDIA',
                  value: '${_mediaList.length}',
                  subtitle: 'Kompresi WebP',
                  stripeColor: NeoTokens.hazard,
                  icon: AppIcons.photoLibrary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'AKTIVITAS AUDIT',
                  value: '${_auditLogs.length}',
                  subtitle: 'Log tercatat',
                  stripeColor: NeoTokens.coralRed,
                  icon: AppIcons.shield,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Action Panel
          NeoCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AKSI CEPAT MANAJEMEN GIZI',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: NeoTokens.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NeoButton(
                        text: '+ Pangan Baru',
                        variant: NeoButtonVariant.primary,
                        onPressed: () => _showFoodFormSheet(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NeoButton(
                        text: '+ Tulis Artikel',
                        variant: NeoButtonVariant.secondary,
                        onPressed: () => _showArticleFormSheet(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: NeoButton(
                        text: 'Kelola Kategori',
                        prefixIcon: AppIcons.category,
                        variant: NeoButtonVariant.secondary,
                        onPressed: _openCategoriesManager,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NeoButton(
                        text: 'Galeri Media',
                        prefixIcon: AppIcons.photoLibrary,
                        variant: NeoButtonVariant.secondary,
                        onPressed: _openMediaManager,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Latest Audit Logs preview
          NeoCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LOG AUDIT TERAKHIR',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.ink,
                        letterSpacing: -0.2,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _tabController.animateTo(5),
                      child: const Text(
                        'Lihat Semua →',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const Divider(color: NeoTokens.ink, thickness: 1.5),
                if (_auditLogs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Belum ada catatan aktivitas audit.',
                        style: TextStyle(
                          color: NeoTokens.inkSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  ..._auditLogs.take(5).map((l) {
                    final action = l['action'] ?? 'LOG';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: action == 'CREATE'
                                  ? NeoTokens.lime
                                  : action == 'UPDATE'
                                  ? NeoTokens.hazard
                                  : NeoTokens.lilac,
                              border: Border.all(
                                color: NeoTokens.ink,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              action,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l['entity_type']} #${l['entity_id']}: ${l['reason'] ?? '-'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Oleh ${l['performer_name']} • ${l['created_at']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: NeoTokens.inkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color stripeColor,
    required IconData icon,
  }) {
    return AdminStatCard(
      title: title,
      value: value,
      subtitle: subtitle,
      stripeColor: stripeColor,
      icon: icon,
    );
  }

  // ========================================================================
  // TAB 2: KATALOG PANGAN
  // ========================================================================
  Widget _buildFoodsTab() {
    return Column(
      children: [
        // Search & Action Header
        Container(
          color: NeoTokens.paper,
          padding: const EdgeInsets.all(NeoTokens.space12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSearchBar(
                      controller: _foodSearchController,
                      hintText: 'Cari makanan atau YOLO class...',
                      onChanged: (v) {
                        _foodSearchQuery = v;
                        _fetchFoods();
                      },
                      onClear: () {
                        _foodSearchController.clear();
                        setState(() => _foodSearchQuery = '');
                        _fetchFoods();
                      },
                    ),
                  ),
                  const SizedBox(width: NeoTokens.space8),
                  NeoButton(
                    text: '+ Tambah',
                    isFullWidth: false,
                    height: 52,
                    variant: NeoButtonVariant.primary,
                    onPressed: () => _showFoodFormSheet(),
                  ),
                ],
              ),
              const SizedBox(height: NeoTokens.space10),
              // Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill(
                      label: 'Semua',
                      isSelected: _foodFilterActive == null,
                      onTap: () {
                        setState(() => _foodFilterActive = null);
                        _fetchFoods();
                      },
                    ),
                    _buildFilterPill(
                      label: 'Aktif',
                      isSelected: _foodFilterActive == true,
                      activeColor: NeoTokens.lime,
                      onTap: () {
                        setState(() => _foodFilterActive = true);
                        _fetchFoods();
                      },
                    ),
                    _buildFilterPill(
                      label: 'Nonaktif',
                      isSelected: _foodFilterActive == false,
                      activeColor: NeoTokens.coralRed.withValues(alpha: 0.35),
                      onTap: () {
                        setState(() => _foodFilterActive = false);
                        _fetchFoods();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(color: NeoTokens.ink, thickness: 2, height: 2),

        // Food List
        Expanded(
          child: _isLoadingFoods
              ? _buildLoadingState(message: 'Memuat katalog pangan...')
              : _foods.isEmpty
              ? _buildEmptyState(
                  icon: AppIcons.restaurantMenu,
                  title: _foodSearchQuery.isNotEmpty
                      ? 'Makanan Tidak Ditemukan'
                      : 'Katalog Pangan Kosong',
                  message: _foodSearchQuery.isNotEmpty
                      ? 'Tidak ada data pangan yang cocok dengan kata kunci "$_foodSearchQuery".'
                      : 'Belum ada item makanan yang terdaftar dalam katalog nutrisi.',
                  buttonText: _foodSearchQuery.isNotEmpty
                      ? 'Tampilkan Semua Pangan'
                      : '+ Daftarkan Pangan Baru',
                  onAction: _foodSearchQuery.isNotEmpty
                      ? () {
                          _foodSearchController.clear();
                          setState(() => _foodSearchQuery = '');
                          _fetchFoods();
                        }
                      : () => _showFoodFormSheet(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: _foods.length,
                  itemBuilder: (ctx, i) {
                    final foodItem = _foods[i];
                    final nutritionData = foodItem['nutrition'] ?? {};
                    final isActive = foodItem['is_active'] == true;

                    return NeoCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      onTap: () => _openFoodDetail(foodItem),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  foodItem['name'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: NeoTokens.ink,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              NeoBadge(
                                label: isActive ? 'AKTIF' : 'NONAKTIF',
                                color: isActive
                                    ? NeoBadgeColor.mint
                                    : NeoBadgeColor.coral,
                              ),
                            ],
                          ),
                          if (foodItem['yolo_class'] != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  AppIcons.smartToy,
                                  size: AppIcons.sizeSmall,
                                  color: NeoTokens.inkSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'YOLO: ${foodItem['yolo_class']}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: NeoTokens.inkSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          // Macro Pills
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildNutrientPill(
                                '${nutritionData['calories_kcal'] ?? 0} kkal',
                                NeoTokens.warmBackground,
                              ),
                              _buildNutrientPill(
                                'P: ${nutritionData['protein_g'] ?? 0}g',
                                NeoTokens.lime.withValues(alpha: 0.4),
                              ),
                              _buildNutrientPill(
                                'C: ${nutritionData['carbs_g'] ?? 0}g',
                                NeoTokens.hazard.withValues(alpha: 0.4),
                              ),
                              _buildNutrientPill(
                                'F: ${nutritionData['fat_g'] ?? 0}g',
                                NeoTokens.lilac.withValues(alpha: 0.4),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Sumber: ${nutritionData['source'] ?? '-'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: NeoTokens.inkSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AdminActionButton.more(
                                tooltip: 'Opsi & Detail Pangan',
                                onPressed: () => _openFoodDetail(foodItem),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNutrientPill(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: NeoTokens.ink, width: 1.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  // ========================================================================
  // TAB 3: ATWATER SIMULATOR (INTERACTIVE TESTING)
  // ========================================================================
  Widget _buildAtwaterTab() {
    final double cal = double.tryParse(_simCalCtrl.text) ?? 0.0;
    final double pro = double.tryParse(_simProCtrl.text) ?? 0.0;
    final double carb = double.tryParse(_simCarbCtrl.text) ?? 0.0;
    final double fat = double.tryParse(_simFatCtrl.text) ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeoCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(AppIcons.balance, color: NeoTokens.cobalt),
                    SizedBox(width: 8),
                    Text(
                      'SIMULATOR FISIKA GIZI ATWATER',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Uji kelayakan nilai kalori berdasarkan formula standar 4-4-9: '
                  '(4 kkal/g Protein) + (4 kkal/g Karbohidrat) + (9 kkal/g Lemak). '
                  'Sistem menolak penyimpanan pangan jika deviasi melebihi 30%.',
                  style: TextStyle(fontSize: 12, color: NeoTokens.inkSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          NeoCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeoInput(
                  controller: _simNameCtrl,
                  label: 'NAMA MAKANAN SIMULASI',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NeoInput(
                        controller: _simCalCtrl,
                        label: 'KALORI (KKAL)',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NeoInput(
                        controller: _simProCtrl,
                        label: 'PROTEIN (G)',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: NeoInput(
                        controller: _simCarbCtrl,
                        label: 'KARBOHIDRAT (G)',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NeoInput(
                        controller: _simFatCtrl,
                        label: 'LEMAK (G)',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AtwaterCheckerWidget(
                  calories: cal,
                  protein: pro,
                  carbs: carb,
                  fat: fat,
                ),
                const SizedBox(height: 16),
                NeoButton(
                  text: 'Daftarkan Nilai Ini ke Katalog',
                  variant: NeoButtonVariant.primary,
                  onPressed: () {
                    _showFoodFormSheet(
                      initialFood: {
                        'name': _simNameCtrl.text,
                        'nutrition': {
                          'calories_kcal': cal,
                          'protein_g': pro,
                          'carbs_g': carb,
                          'fat_g': fat,
                          'source': 'Simulator Atwater NutriView',
                        },
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // TAB 4: ARTIKEL EDUKASI GIZI
  // ========================================================================
  Widget _buildArticlesTab() {
    return Column(
      children: [
        Container(
          color: NeoTokens.paper,
          padding: const EdgeInsets.all(NeoTokens.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'KONTEN EDUKASI GIZI',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  NeoButton(
                    text: '+ Tulis Artikel',
                    isFullWidth: false,
                    height: 42,
                    variant: NeoButtonVariant.primary,
                    onPressed: () => _showArticleFormSheet(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      text: 'Kelola Kategori',
                      prefixIcon: AppIcons.category,
                      height: 38,
                      variant: NeoButtonVariant.secondary,
                      onPressed: _openCategoriesManager,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeoButton(
                      text: 'Galeri Media',
                      prefixIcon: AppIcons.photoLibrary,
                      height: 38,
                      variant: NeoButtonVariant.secondary,
                      onPressed: _openMediaManager,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(color: NeoTokens.ink, thickness: 2, height: 2),
        Expanded(
          child: _isLoadingArticles
              ? _buildLoadingState(message: 'Memuat artikel...')
              : _articles.isEmpty
              ? _buildEmptyState(
                  icon: AppIcons.article,
                  title: 'Belum Ada Artikel',
                  message: 'Daftar artikel edukasi gizi masih kosong. Mulai buat dan publikasikan artikel nutrisi untuk pengguna aplikasi.',
                  buttonText: '+ Tulis Artikel Baru',
                  onAction: () => _showArticleFormSheet(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _articles.length,
                  itemBuilder: (ctx, i) {
                    final articleItem = _articles[i];
                    final isPublished = articleItem['status'] == 'published';

                    return NeoCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      onTap: () => _openArticlePreview(articleItem),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  articleItem['title'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: NeoTokens.ink,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              NeoBadge(
                                label: isPublished ? 'PUBLIK' : 'DRAF',
                                color: isPublished
                                    ? NeoBadgeColor.mint
                                    : NeoBadgeColor.yellow,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            articleItem['excerpt'] ??
                                articleItem['content_markdown'] ??
                                '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: NeoTokens.inkSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Penulis: ${articleItem['author_name'] ?? 'Admin'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AdminActionButton.more(
                                tooltip: 'Opsi & Pratinjau Artikel',
                                onPressed: () =>
                                    _openArticlePreview(articleItem),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ========================================================================
  // TAB 5: LOG AUDIT LENGKAP
  // ========================================================================
  Widget _buildAuditTab() {
    return Column(
      children: [
        Container(
          color: NeoTokens.paper,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Text(
                'Entitas: ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              _buildFilterPill(
                label: 'Semua',
                isSelected: _auditFilterEntity == null,
                onTap: () {
                  setState(() => _auditFilterEntity = null);
                  _fetchAuditLogs();
                },
              ),
              _buildFilterPill(
                label: 'Pangan',
                isSelected: _auditFilterEntity == 'food',
                activeColor: NeoTokens.lime,
                onTap: () {
                  setState(() => _auditFilterEntity = 'food');
                  _fetchAuditLogs();
                },
              ),
              _buildFilterPill(
                label: 'Artikel',
                isSelected: _auditFilterEntity == 'article',
                activeColor: NeoTokens.hazard,
                onTap: () {
                  setState(() => _auditFilterEntity = 'article');
                  _fetchAuditLogs();
                },
              ),
            ],
          ),
        ),
        const Divider(color: NeoTokens.ink, thickness: 2, height: 2),
        Expanded(
          child: _isLoadingAudit
              ? _buildLoadingState(message: 'Memuat log audit...')
              : _auditLogs.isEmpty
              ? _buildEmptyState(
                  icon: AppIcons.history,
                  title: 'Tidak Ada Log Audit',
                  message: 'Belum ada catatan aktivitas administratif yang tercatat pada sistem.',
                  buttonText: 'Segarkan Log',
                  onAction: _fetchAuditLogs,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _auditLogs.length,
                  itemBuilder: (ctx, i) {
                    final log = _auditLogs[i];
                    final action = log['action'] ?? 'LOG';

                    return NeoCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              NeoBadge(
                                label: action,
                                color: action == 'CREATE'
                                    ? NeoBadgeColor.mint
                                    : action == 'UPDATE'
                                    ? NeoBadgeColor.yellow
                                    : NeoBadgeColor.coral,
                              ),
                              Text(
                                log['created_at'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: NeoTokens.inkSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${log['entity_type']?.toString().toUpperCase()} #${log['entity_id']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: NeoTokens.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Alasan: ${log['reason'] ?? '-'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dieksekusi oleh: ${log['performer_name'] ?? log['user_email'] ?? 'System'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: NeoTokens.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ========================================================================
  // TAB 6: MANAJEMEN PENGGUNA
  // ========================================================================
  Widget _buildUsersTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(NeoTokens.space12),
          color: NeoTokens.paper,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSearchBar(
                      controller: _userSearchController,
                      hintText: 'Cari nama atau email pengguna...',
                      onChanged: (val) {
                        _userSearchQuery = val;
                        _fetchUsers();
                      },
                      onClear: () {
                        _userSearchController.clear();
                        setState(() => _userSearchQuery = '');
                        _fetchUsers();
                      },
                    ),
                  ),
                  const SizedBox(width: NeoTokens.space8),
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: NeoTokens.paper,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusMedium,
                      ),
                      border: Border.all(
                        color: NeoTokens.ink,
                        width: NeoTokens.borderWidthThin,
                      ),
                      boxShadow: NeoTokens.neoBoxShadowSmall(),
                    ),
                    child: IconButton(
                      icon: const Icon(AppIcons.refresh, color: NeoTokens.ink),
                      tooltip: 'Segarkan data pengguna',
                      onPressed: _fetchUsers,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NeoTokens.space10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill(
                      label: 'Semua Role',
                      isSelected: _userRoleFilter == null,
                      onTap: () {
                        setState(() => _userRoleFilter = null);
                        _fetchUsers();
                      },
                    ),
                    _buildFilterPill(
                      label: 'User',
                      isSelected: _userRoleFilter == 'user',
                      activeColor: NeoTokens.lime,
                      onTap: () {
                        setState(() => _userRoleFilter = 'user');
                        _fetchUsers();
                      },
                    ),
                    _buildFilterPill(
                      label: 'Admin',
                      isSelected: _userRoleFilter == 'admin',
                      activeColor: NeoTokens.hazard,
                      onTap: () {
                        setState(() => _userRoleFilter = 'admin');
                        _fetchUsers();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(color: NeoTokens.ink, thickness: 2, height: 2),
        Expanded(
          child: _isLoadingUsers
              ? _buildLoadingState(message: 'Memuat data pengguna...')
              : _users.isEmpty
              ? _buildEmptyState(
                  icon: AppIcons.peopleAlt,
                  title: _userSearchQuery.isNotEmpty || _userRoleFilter != null
                      ? 'Pengguna Tidak Ditemukan'
                      : 'Belum Ada Pengguna',
                  message:
                      _userSearchQuery.isNotEmpty || _userRoleFilter != null
                      ? 'Tidak ada akun pengguna yang sesuai dengan filter atau pencarian saat ini.'
                      : 'Daftar pengguna aplikasi masih kosong.',
                  buttonText:
                      _userSearchQuery.isNotEmpty || _userRoleFilter != null
                      ? 'Reset Filter & Pencarian'
                      : 'Segarkan Data',
                  onAction: () {
                    _userSearchController.clear();
                    setState(() {
                      _userSearchQuery = '';
                      _userRoleFilter = null;
                    });
                    _fetchUsers();
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _users.length,
                  itemBuilder: (ctx, i) {
                    final u = _users[i];
                    final int userId = u['id'] as int? ?? 0;
                    final String email = u['email'] as String? ?? '';
                    final String name = u['full_name'] as String? ?? '';
                    final String role = u['role'] as String? ?? 'user';
                    final bool isActive = u['is_active'] as bool? ?? true;

                    final profile = u['profile'] as Map<String, dynamic>?;
                    final profession =
                        profile?['profession'] as String? ?? 'Umum';

                    return NeoCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      onTap: () => _openUserDetail(u),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? NeoTokens.mintGreen
                                  : NeoTokens.recess,
                              borderRadius: BorderRadius.circular(
                                NeoTokens.radiusSmall,
                              ),
                              border: Border.all(
                                color: NeoTokens.ink,
                                width: NeoTokens.borderWidthThin,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: NeoTokens.ink,
                                  offset: Offset(1.5, 1.5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              role == 'admin'
                                  ? AppIcons.adminPanelSettings
                                  : AppIcons.person,
                              color: NeoTokens.ink,
                              size: AppIcons.sizeToolbar,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: NeoTokens.ink,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    NeoBadge(
                                      label: role == 'admin' ? 'ADMIN' : 'USER',
                                      color: role == 'admin'
                                          ? NeoBadgeColor.yellow
                                          : NeoBadgeColor.white,
                                      fontSize: 10,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: NeoTokens.inkSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    NeoBadge(
                                      label: isActive ? 'AKTIF' : 'NONAKTIF',
                                      color: isActive
                                          ? NeoBadgeColor.mint
                                          : NeoBadgeColor.coral,
                                      fontSize: 10,
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: NeoTokens.recess,
                                        borderRadius: BorderRadius.circular(
                                          NeoTokens.radiusSmall,
                                        ),
                                        border: Border.all(
                                          color: NeoTokens.ink,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        profession,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: NeoTokens.inkSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'ID #$userId',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          color: NeoTokens.inkSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AdminActionButton.more(
                            tooltip: 'Menu Aksi & Detail Pengguna',
                            onPressed: () => _openUserDetail(u),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
