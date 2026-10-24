import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/features/admin/data/admin_repository.dart';
import 'package:nutriview/features/admin/presentation/widgets/atwater_checker_widget.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';

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
    final confirmed = await NeoDialog.show(
      context,
      title: currentStatus ? 'Nonaktifkan Akun?' : 'Aktifkan Akun?',
      message: currentStatus
          ? 'Akun $email tidak akan dapat login lagi sampai diaktifkan kembali oleh administrator.'
          : 'Akun $email akan diaktifkan dan dapat login kembali ke aplikasi.',
      confirmText: currentStatus ? 'Nonaktifkan' : 'Aktifkan',
      cancelText: 'Batal',
      confirmColor: currentStatus ? NeoTokens.coralRed : NeoTokens.primaryGreen,
      icon: currentStatus ? Icons.block_rounded : Icons.check_circle_outline_rounded,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: NeoTokens.paper,
              size: 20,
            ),
            const SizedBox(width: NeoTokens.space10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: NeoTokens.paper,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: NeoTokens.coralRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
          side: const BorderSide(color: NeoTokens.ink, width: 2),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: NeoTokens.paper,
              size: 20,
            ),
            const SizedBox(width: NeoTokens.space10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: NeoTokens.paper,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: NeoTokens.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
          side: const BorderSide(color: NeoTokens.ink, width: 2),
        ),
      ),
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
            child: Icon(Icons.search_rounded, size: 22, color: NeoTokens.ink),
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
                  fontSize: 13.5,
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
                  Icons.close_rounded,
                  size: 20,
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
                child: Icon(icon, size: 28, color: NeoTokens.ink),
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
                  fontSize: 12.5,
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
      icon: Icons.logout_rounded,
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
                        icon: const Icon(
                          Icons.close_rounded,
                          color: NeoTokens.ink,
                        ),
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
                        icon: const Icon(
                          Icons.close_rounded,
                          color: NeoTokens.ink,
                        ),
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
                                          Icons.broken_image_outlined,
                                          size: 20,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        backgroundColor: NeoTokens.paper,
        elevation: 0,
        titleSpacing: NeoTokens.space16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'NutriView',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: NeoTokens.ink,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: NeoTokens.space8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: NeoTokens.lime,
                borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
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
              child: const Text(
                'PORTAL ADMIN',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: NeoTokens.ink,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: NeoBadge(
              label: widget.adminRole.toUpperCase().replaceAll('_', ' '),
              color: NeoBadgeColor.white,
              fontSize: 9.5,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.dashboard_outlined,
              color: NeoTokens.ink,
            ),
            tooltip: 'Buka Mode Pengguna',
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: NeoTokens.coralRed),
            tooltip: 'Keluar dari Portal Admin',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              Container(color: NeoTokens.ink, height: NeoTokens.borderWidthThin),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: NeoTokens.ink,
                indicatorWeight: 3.5,
                labelColor: NeoTokens.ink,
                unselectedLabelColor: NeoTokens.inkSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.grid_view_rounded, size: 18),
                    text: 'RINGKASAN',
                  ),
                  Tab(
                    icon: Icon(Icons.restaurant_menu_rounded, size: 18),
                    text: 'PANGAN',
                  ),
                  Tab(
                    icon: Icon(Icons.balance_rounded, size: 18),
                    text: 'ATWATER',
                  ),
                  Tab(
                    icon: Icon(Icons.article_rounded, size: 18),
                    text: 'ARTIKEL',
                  ),
                  Tab(
                    icon: Icon(Icons.people_alt_rounded, size: 18),
                    text: 'PENGGUNA',
                  ),
                  Tab(
                    icon: Icon(Icons.history_rounded, size: 18),
                    text: 'LOG AUDIT',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
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
                  icon: Icons.fastfood_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'ARTIKEL TERBIT',
                  value: '$publishedCount',
                  subtitle: '${_articles.length} total draft/live',
                  stripeColor: NeoTokens.cobalt,
                  icon: Icons.menu_book_rounded,
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
                  icon: Icons.photo_library_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'AKTIVITAS AUDIT',
                  value: '${_auditLogs.length}',
                  subtitle: 'Log tercatat',
                  stripeColor: NeoTokens.coralRed,
                  icon: Icons.shield_outlined,
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
                          fontSize: 12.5,
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
                                fontSize: 9.5,
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
                                    fontSize: 12.5,
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
    return NeoCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 6, width: double.infinity, color: stripeColor),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.inkSecondary,
                      ),
                    ),
                    Icon(icon, size: 16, color: NeoTokens.inkSecondary),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: NeoTokens.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: NeoTokens.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  icon: Icons.restaurant_menu_rounded,
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
                                  Icons.smart_toy_outlined,
                                  size: 14,
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
                              Text(
                                'Sumber: ${nutritionData['source'] ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: NeoTokens.inkSecondary,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: NeoTokens.paper,
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
                                    child: IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      icon: Icon(
                                        isActive
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 18,
                                        color: isActive
                                            ? NeoTokens.primaryGreen
                                            : NeoTokens.coralRed,
                                      ),
                                      tooltip: isActive
                                          ? 'Nonaktifkan'
                                          : 'Aktifkan',
                                      onPressed: () async {
                                        await _adminRepo.setFoodStatus(
                                          foodItem['id'],
                                          !isActive,
                                          reason: 'Toggle status via Mobile CMS',
                                        );
                                        _showSuccessSnackBar(
                                          'Status makanan berhasil diubah.',
                                        );
                                        _fetchFoods();
                                        _fetchAuditLogs();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: NeoTokens.paper,
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
                                    child: IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 36,
                                        minHeight: 36,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: NeoTokens.cobalt,
                                      ),
                                      tooltip: 'Edit Nutrisi',
                                      onPressed: () => _showFoodFormSheet(
                                        initialFood: foodItem,
                                      ),
                                    ),
                                  ),
                                ],
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
          fontSize: 10.5,
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
                    Icon(Icons.balance_rounded, color: NeoTokens.cobalt),
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
          child: Row(
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
        ),
        const Divider(color: NeoTokens.ink, thickness: 2, height: 2),
        Expanded(
          child: _isLoadingArticles
              ? _buildLoadingState(message: 'Memuat artikel...')
              : _articles.isEmpty
              ? _buildEmptyState(
                  icon: Icons.article_rounded,
                  title: 'Belum Ada Artikel',
                  message:
                      'Daftar artikel edukasi gizi masih kosong. Mulai buat dan publikasikan artikel nutrisi untuk pengguna aplikasi.',
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
                              Text(
                                'Penulis: ${articleItem['author_name'] ?? 'Admin'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final nextStatus = isPublished
                                          ? 'draft'
                                          : 'published';
                                      await _adminRepo.updateArticle(
                                        articleItem['id'],
                                        {'status': nextStatus},
                                      );
                                      _showSuccessSnackBar(
                                        isPublished
                                            ? 'Artikel dipindahkan ke draft.'
                                            : 'Artikel telah dipublikasikan ke publik.',
                                      );
                                      _fetchArticles();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPublished
                                            ? NeoTokens.recess
                                            : NeoTokens.lime,
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
                                      child: Text(
                                        isPublished ? 'Tarik Draf' : 'Terbitkan',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: NeoTokens.ink,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: NeoTokens.paper,
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
                                    child: IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 34,
                                        minHeight: 34,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: NeoTokens.cobalt,
                                      ),
                                      tooltip: 'Edit Artikel',
                                      onPressed: () => _showArticleFormSheet(
                                        initialArticle: articleItem,
                                      ),
                                    ),
                                  ),
                                ],
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
                  icon: Icons.history_rounded,
                  title: 'Tidak Ada Log Audit',
                  message:
                      'Belum ada catatan aktivitas administratif yang tercatat pada sistem.',
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
                                  fontSize: 10.5,
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
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: NeoTokens.ink,
                      ),
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
                      label: 'Dietitian',
                      isSelected: _userRoleFilter == 'dietitian',
                      activeColor: NeoTokens.hazard,
                      onTap: () {
                        setState(() => _userRoleFilter = 'dietitian');
                        _fetchUsers();
                      },
                    ),
                    _buildFilterPill(
                      label: 'Super Admin',
                      isSelected: _userRoleFilter == 'super_admin',
                      activeColor: NeoTokens.coralRed.withValues(alpha: 0.35),
                      onTap: () {
                        setState(() => _userRoleFilter = 'super_admin');
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
                  icon: Icons.people_alt_rounded,
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

                    return NeoCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
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
                              role == 'super_admin'
                                  ? Icons.security_rounded
                                  : role == 'dietitian'
                                  ? Icons.medical_services_rounded
                                  : Icons.person_rounded,
                              color: NeoTokens.ink,
                              size: 22,
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
                                      label: role.toUpperCase(),
                                      color: role == 'super_admin'
                                          ? NeoBadgeColor.coral
                                          : role == 'dietitian'
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
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    NeoBadge(
                                      label: isActive ? 'AKTIF' : 'NONAKTIF',
                                      color: isActive
                                          ? NeoBadgeColor.mint
                                          : NeoBadgeColor.coral,
                                      fontSize: 9.5,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ID #$userId',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                        color: NeoTokens.inkSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: NeoTokens.paper,
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
                            child: IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              padding: const EdgeInsets.all(6),
                              icon: Icon(
                                isActive
                                    ? Icons.block_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 20,
                                color: isActive
                                    ? NeoTokens.coralRed
                                    : NeoTokens.primaryGreen,
                              ),
                              tooltip: isActive
                                  ? 'Nonaktifkan Akun'
                                  : 'Aktifkan Akun',
                              onPressed: () => _confirmToggleUserStatus(
                                userId,
                                isActive,
                                email,
                              ),
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
}
