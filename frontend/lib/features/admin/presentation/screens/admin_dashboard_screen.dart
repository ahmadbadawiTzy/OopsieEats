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

  void _confirmToggleUserStatus(int userId, bool currentStatus, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          side: const BorderSide(color: NeoTokens.ink, width: 2),
        ),
        title: Text(currentStatus ? 'Nonaktifkan Akun?' : 'Aktifkan Akun?'),
        content: Text(
          currentStatus
              ? 'Akun $email tidak akan dapat login lagi sampai diaktifkan kembali.'
              : 'Akun $email akan diaktifkan dan dapat login kembali ke aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: currentStatus
                  ? NeoTokens.alert
                  : NeoTokens.primaryGreen,
              foregroundColor: NeoTokens.paper,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
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
            },
            child: Text(currentStatus ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: NeoTokens.alert,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: NeoTokens.primaryGreen,
        behavior: SnackBarBehavior.floating,
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
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.ink,
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
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.ink,
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
                              ChoiceChip(
                                label: const Text('Draft'),
                                selected: statusVal == 'draft',
                                selectedColor: NeoTokens.hazard,
                                onSelected: (_) =>
                                    setSheetState(() => statusVal = 'draft'),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Published'),
                                selected: statusVal == 'published',
                                selectedColor: NeoTokens.lime,
                                onSelected: (_) => setSheetState(
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
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: NeoTokens.cobalt,
                borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                border: Border.all(
                  color: NeoTokens.ink,
                  width: NeoTokens.borderWidthThin,
                ),
                boxShadow: NeoTokens.neoBoxShadowSmall(),
              ),
              child: const Text(
                'NV.ADMIN // CMS',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: NeoTokens.paper,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: NeoTokens.space10),
            const Text(
              'NutriView',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: NeoTokens.ink,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: NeoBadge(
              label: widget.adminRole.toUpperCase().replaceAll('_', ' '),
              color: NeoBadgeColor.yellow,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.person_outline_rounded,
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
              Container(color: NeoTokens.ink, height: 2),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: NeoTokens.cobalt,
                indicatorWeight: 3.5,
                labelColor: NeoTokens.cobalt,
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
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.ink,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _tabController.animateTo(4),
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
                    child: Center(child: Text('Belum ada catatan aktivitas.')),
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
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari makanan / yolo class...',
                        hintStyle: const TextStyle(fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        filled: true,
                        fillColor: NeoTokens.warmBackground,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: NeoTokens.ink,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: NeoTokens.ink,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                        ),
                      ),
                      onChanged: (v) {
                        _foodSearchQuery = v;
                        _fetchFoods();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 110,
                    child: NeoButton(
                      text: '+ Tambah',
                      variant: NeoButtonVariant.primary,
                      onPressed: () => _showFoodFormSheet(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Filter Chips
              Row(
                children: [
                  const Text(
                    'Filter: ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('Semua', style: TextStyle(fontSize: 11)),
                    selected: _foodFilterActive == null,
                    selectedColor: NeoTokens.cobalt.withValues(alpha: 0.2),
                    onSelected: (_) {
                      setState(() => _foodFilterActive = null);
                      _fetchFoods();
                    },
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('Aktif', style: TextStyle(fontSize: 11)),
                    selected: _foodFilterActive == true,
                    selectedColor: NeoTokens.lime.withValues(alpha: 0.5),
                    onSelected: (_) {
                      setState(() => _foodFilterActive = true);
                      _fetchFoods();
                    },
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text(
                      'Nonaktif',
                      style: TextStyle(fontSize: 11),
                    ),
                    selected: _foodFilterActive == false,
                    selectedColor: NeoTokens.coralRed.withValues(alpha: 0.3),
                    onSelected: (_) {
                      setState(() => _foodFilterActive = false);
                      _fetchFoods();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(color: NeoTokens.ink, thickness: 2, height: 2),

        // Food List
        Expanded(
          child: _isLoadingFoods
              ? const Center(child: CircularProgressIndicator())
              : _foods.isEmpty
              ? const Center(child: Text('Tidak ada makanan ditemukan.'))
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
                                  IconButton(
                                    icon: Icon(
                                      isActive
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
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
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: NeoTokens.cobalt,
                                    ),
                                    tooltip: 'Edit Nutrisi',
                                    onPressed: () => _showFoodFormSheet(
                                      initialFood: foodItem,
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
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'KONTEN EDUKASI GIZI',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              NeoButton(
                text: '+ Tulis Artikel',
                variant: NeoButtonVariant.primary,
                onPressed: () => _showArticleFormSheet(),
              ),
            ],
          ),
        ),
        const Divider(color: NeoTokens.ink, thickness: 2, height: 2),
        Expanded(
          child: _isLoadingArticles
              ? const Center(child: CircularProgressIndicator())
              : _articles.isEmpty
              ? const Center(child: Text('Belum ada artikel.'))
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
                                label: isPublished ? 'PUBLISHED' : 'DRAFT',
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
                                  TextButton(
                                    onPressed: () async {
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
                                    child: Text(
                                      isPublished ? 'Tarik Draf' : 'Terbitkan',
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: NeoTokens.cobalt,
                                    ),
                                    onPressed: () => _showArticleFormSheet(
                                      initialArticle: articleItem,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Filter Entitas: ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Semua', style: TextStyle(fontSize: 11)),
                selected: _auditFilterEntity == null,
                selectedColor: NeoTokens.cobalt.withValues(alpha: 0.2),
                onSelected: (_) {
                  setState(() => _auditFilterEntity = null);
                  _fetchAuditLogs();
                },
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text('Pangan', style: TextStyle(fontSize: 11)),
                selected: _auditFilterEntity == 'food',
                selectedColor: NeoTokens.lime.withValues(alpha: 0.5),
                onSelected: (_) {
                  setState(() => _auditFilterEntity = 'food');
                  _fetchAuditLogs();
                },
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text('Artikel', style: TextStyle(fontSize: 11)),
                selected: _auditFilterEntity == 'article',
                selectedColor: NeoTokens.hazard.withValues(alpha: 0.4),
                onSelected: (_) {
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
              ? const Center(child: CircularProgressIndicator())
              : _auditLogs.isEmpty
              ? const Center(child: Text('Tidak ada log audit tercatat.'))
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

  Widget _buildUsersTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: NeoTokens.canvas,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau email pengguna...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                          borderSide: const BorderSide(
                            color: NeoTokens.ink,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                          borderSide: const BorderSide(
                            color: NeoTokens.ink,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                          borderSide: const BorderSide(
                            color: NeoTokens.cobalt,
                            width: 2.5,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        _userSearchQuery = val;
                        _fetchUsers();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: NeoTokens.ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          NeoTokens.radiusSmall,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: NeoTokens.paper,
                    ),
                    onPressed: _fetchUsers,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text(
                        'Semua Role',
                        style: TextStyle(fontSize: 11),
                      ),
                      selected: _userRoleFilter == null,
                      selectedColor: NeoTokens.cobalt.withValues(alpha: 0.3),
                      onSelected: (_) {
                        setState(() => _userRoleFilter = null);
                        _fetchUsers();
                      },
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('User', style: TextStyle(fontSize: 11)),
                      selected: _userRoleFilter == 'user',
                      selectedColor: NeoTokens.cobalt.withValues(alpha: 0.3),
                      onSelected: (_) {
                        setState(() => _userRoleFilter = 'user');
                        _fetchUsers();
                      },
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text(
                        'Dietitian',
                        style: TextStyle(fontSize: 11),
                      ),
                      selected: _userRoleFilter == 'dietitian',
                      selectedColor: NeoTokens.cobalt.withValues(alpha: 0.3),
                      onSelected: (_) {
                        setState(() => _userRoleFilter = 'dietitian');
                        _fetchUsers();
                      },
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text(
                        'Super Admin',
                        style: TextStyle(fontSize: 11),
                      ),
                      selected: _userRoleFilter == 'super_admin',
                      selectedColor: NeoTokens.cobalt.withValues(alpha: 0.3),
                      onSelected: (_) {
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
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
              ? const Center(child: Text('Tidak ada pengguna ditemukan.'))
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
                                width: 2,
                              ),
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
                          IconButton(
                            icon: Icon(
                              isActive
                                  ? Icons.block_rounded
                                  : Icons.check_circle_outline_rounded,
                              color: isActive
                                  ? NeoTokens.alert
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
