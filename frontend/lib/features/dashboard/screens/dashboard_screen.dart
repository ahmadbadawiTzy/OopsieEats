import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/data/models/article.dart';
import 'package:oopsieeats/data/models/meal.dart';
import 'package:oopsieeats/data/repositories/article_repository.dart';
import 'package:oopsieeats/data/repositories/meal_repository.dart';
import 'package:oopsieeats/features/article/screens/article_list_screen.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/dashboard/providers/dashboard_provider.dart';
import 'package:oopsieeats/features/dashboard/widgets/daily_calorie_hero_card.dart';
import 'package:oopsieeats/features/dashboard/widgets/dashboard_hero_section.dart';
import 'package:oopsieeats/features/dashboard/widgets/latest_articles_section.dart';
import 'package:oopsieeats/features/dashboard/widgets/macro_bento_grid.dart';
import 'package:oopsieeats/features/dashboard/widgets/scan_cta_card.dart';
import 'package:oopsieeats/features/dashboard/widgets/todays_intake_section.dart';
import 'package:oopsieeats/features/meals/screens/meal_history_screen.dart';
import 'package:oopsieeats/features/profile/providers/profile_provider.dart';
import 'package:oopsieeats/features/profile/screens/profile_screen.dart';
import 'package:oopsieeats/shared/neo/neo.dart';
import 'package:oopsieeats/shared/widgets/error_view.dart';
import 'package:oopsieeats/shared/widgets/loading_indicator.dart';

/// Main User Shell for NutriView.
/// Hosts an [IndexedStack] with all 4 user tabs (Beranda, Artikel, Riwayat, Profil),
/// a persistent tactile [NeoBottomNav], and back-button safety ensuring the user
/// never accidentally logs out or exits unexpectedly.
class DashboardScreen extends StatefulWidget {
  final NeoNavTab initialTab;

  const DashboardScreen({super.key, this.initialTab = NeoNavTab.home});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late NeoNavTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  void _onTabSelected(NeoNavTab tab) {
    if (_currentTab != tab) {
      setState(() {
        _currentTab = tab;
      });
      if (tab == NeoNavTab.home) {
        context.read<DashboardProvider>().loadDashboard(forceRefresh: true);
      }
    }
  }

  void _onScanPressed() {
    Navigator.pushNamed(context, AppRoutes.scanner);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentTab == NeoNavTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentTab != NeoNavTab.home) {
          setState(() {
            _currentTab = NeoNavTab.home;
          });
          context.read<DashboardProvider>().loadDashboard(forceRefresh: true);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentTab.index,
          children: [
            DashboardHomeView(onNavigateToTab: _onTabSelected),
            const ArticleListScreen(isTab: true),
            const MealHistoryScreen(isTab: true),
            const ProfileScreen(isTab: true),
          ],
        ),
        bottomNavigationBar: NeoBottomNav(
          activeTab: _currentTab,
          onTabSelected: _onTabSelected,
          onScanPressed: _onScanPressed,
        ),
      ),
    );
  }
}

/// The Beranda / Dashboard content view redesigned with Customer-First Neo-Brutalism.
class DashboardHomeView extends StatefulWidget {
  final ValueChanged<NeoNavTab> onNavigateToTab;

  const DashboardHomeView({super.key, required this.onNavigateToTab});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView>
    with SingleTickerProviderStateMixin {
  List<AnnouncementItem> _announcements = [];
  bool _dismissedAnnouncement = false;
  List<ArticleItem> _articles = [];
  List<MealRecord> _todayMeals = [];
  bool _isLoadingMeals = false;
  String? _mealsError;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final disableAnimations = MediaQuery.of(context).disableAnimations;
        if (disableAnimations) {
          _animController.value = 1.0;
        } else {
          _animController.forward();
        }
      }

      final dash = context.read<DashboardProvider>();
      dash.loadDashboard();
      context.read<ProfileProvider>().loadProfile();
      _loadAnnouncementsAndArticles();
      _loadTodayMeals(dash.selectedDate);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadAnnouncementsAndArticles() async {
    try {
      final articleRepo = context.read<ArticleRepository>();
      final announcementsFuture = articleRepo.getActiveAnnouncements();
      final articlesFuture = articleRepo.getArticles(limit: 5);

      final results = await Future.wait([announcementsFuture, articlesFuture]);
      if (mounted) {
        setState(() {
          _announcements = results[0] as List<AnnouncementItem>;
          final articleData = results[1] as Map<String, dynamic>;
          _articles = articleData['items'] as List<ArticleItem>;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadTodayMeals(DateTime date) async {
    setState(() {
      _isLoadingMeals = true;
      _mealsError = null;
    });

    try {
      final mealRepo = context.read<MealRepository>();
      final meals = await mealRepo.getMeals(dateFrom: date, dateTo: date);
      if (mounted) {
        setState(() {
          _todayMeals = meals;
          _isLoadingMeals = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _mealsError = 'Gagal memuat catatan makanan hari ini.';
          _isLoadingMeals = false;
        });
      }
    }
  }

  void _previousDay() {
    final prov = context.read<DashboardProvider>();
    final prev = prov.selectedDate.subtract(const Duration(days: 1));
    prov.changeDate(prev);
    _loadTodayMeals(prev);
  }

  void _nextDay() {
    final prov = context.read<DashboardProvider>();
    final next = prov.selectedDate.add(const Duration(days: 1));
    prov.changeDate(next);
    _loadTodayMeals(next);
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final isToday =
        dash.selectedDate.year == DateTime.now().year &&
        dash.selectedDate.month == DateTime.now().month &&
        dash.selectedDate.day == DateTime.now().day;
    final dateDisplay = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(dash.selectedDate);

    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: NeoTokens.warmBackground,
        centerTitle: true,
        title: const Text(
          'OopsieEats',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.6,
            color: NeoTokens.ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: NeoTokens.ink, height: 1.5),
        ),
        actions: [
          // Admin shortcut badge (if user has admin role)
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (!auth.isAdmin) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: NeoTokens.space16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.adminDashboard,
                      arguments: {
                        'email': auth.email,
                        'role': auth.role,
                        'name': auth.name,
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: NeoTokens.lime,
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
                          offset: Offset(2, 2),
                          blurRadius: NeoTokens.shadowBlurRadius,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppIcons.adminPanelSettings,
                          size: AppIcons.sizeMedium,
                          color: NeoTokens.ink,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'ADMIN',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: NeoTokens.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: NeoTokens.ink,
        backgroundColor: NeoTokens.lime,
        onRefresh: () async {
          await dash.loadDashboard(forceRefresh: true);
          await _loadAnnouncementsAndArticles();
          await _loadTodayMeals(dash.selectedDate);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: NeoTokens.space16,
            vertical: NeoTokens.space12,
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // A. Personal Greeting Hero Section
                  Consumer2<AuthProvider, ProfileProvider>(
                    builder: (context, auth, profileProv, _) {
                      final user = profileProv.user;
                      final displayName = auth.name.isNotEmpty
                          ? auth.name
                          : (auth.email.isNotEmpty
                                ? auth.email.split('@').first
                                : 'Sobat Sehat');
                      return DashboardHeroSection(
                        userName: displayName,
                        photoUrl: user?.photoUrl ?? auth.currentUser?.photoUrl,
                        onAvatarTap: () =>
                            widget.onNavigateToTab(NeoNavTab.profile),
                      );
                    },
                  ),
                  const SizedBox(height: NeoTokens.space12),

                  // Active Announcement Banner (if any)
                  if (_announcements.isNotEmpty && !_dismissedAnnouncement) ...[
                    _buildAnnouncementBanner(),
                    const SizedBox(height: NeoTokens.space12),
                  ],

                  // Date Navigation NeoCard
                  NeoCard(
                    backgroundColor: NeoTokens.paper,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    shadowOffset: NeoTokens.shadowOffsetSmall,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NeoIconButton(
                          icon: AppIcons.chevronLeft,
                          tooltip: 'Hari sebelumnya',
                          size: 36,
                          iconSize: AppIcons.sizeToolbar,
                          shadowOffset: Offset.zero,
                          onPressed: _previousDay,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: dash.selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                dash.changeDate(picked);
                                _loadTodayMeals(picked);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    AppIcons.calendarMonth,
                                    size: AppIcons.sizeMedium,
                                    color: NeoTokens.ink,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      dateDisplay.toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: NeoTokens.ink,
                                      ),
                                    ),
                                  ),
                                  if (isToday) ...[
                                    const SizedBox(width: 6),
                                    const NeoBadge(
                                      label: 'HARI INI',
                                      color: NeoBadgeColor.yellow,
                                      fontSize: 10,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        NeoIconButton(
                          icon: AppIcons.chevronRight,
                          tooltip: 'Hari berikutnya',
                          size: 36,
                          iconSize: AppIcons.sizeToolbar,
                          shadowOffset: Offset.zero,
                          onPressed: _nextDay,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space16),

                  // State Handling: loading / error / content
                  if (dash.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: LoadingIndicator(message: 'Memuat data harian...'),
                    )
                  else if (dash.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: ErrorView(
                        message: dash.errorMessage!,
                        onRetry: () {
                          dash.loadDashboard();
                          _loadTodayMeals(dash.selectedDate);
                        },
                      ),
                    )
                  else if (dash.dashboard != null) ...[
                    // B. Primary Action: High-Voltage Scan CTA
                    ScanCtaCard(
                      onScanPressed: () {
                        Navigator.pushNamed(context, AppRoutes.scanner);
                      },
                    ),
                    const SizedBox(height: NeoTokens.space16),

                    // C. Ringkasan Nutrisi: Daily Calorie Centerpiece
                    DailyCalorieHeroCard(
                      progress: dash.dashboard!.progress.calories,
                      isProfileIncomplete: dash.isProfileIncomplete,
                      onCompleteProfile: () =>
                          widget.onNavigateToTab(NeoNavTab.profile),
                    ),
                    const SizedBox(height: NeoTokens.space16),

                    // C.2 Makronutrien & Activity Bento Grid
                    MacroBentoGrid(
                      progress: dash.dashboard!.progress,
                      mealCount: dash.dashboard!.mealCount,
                      onViewHistory: () =>
                          widget.onNavigateToTab(NeoNavTab.history),
                    ),
                    const SizedBox(height: NeoTokens.space16),

                    // D. Makanan Terakhir: Today's Intake Section
                    TodaysIntakeSection(
                      meals: _todayMeals,
                      isLoading: _isLoadingMeals,
                      errorMessage: _mealsError,
                      onRetry: () => _loadTodayMeals(dash.selectedDate),
                      onScanPressed: () {
                        Navigator.pushNamed(context, AppRoutes.scanner);
                      },
                      onMealTapped: (mealId) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.mealDetail,
                          arguments: mealId,
                        );
                      },
                      onViewAllHistory: () =>
                          widget.onNavigateToTab(NeoNavTab.history),
                    ),
                    const SizedBox(height: NeoTokens.space16),

                    // E. Edukasi Nutrisi: Latest Articles Section
                    LatestArticlesSection(
                      articles: _articles,
                      onArticleTapped: (art) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.articleDetail,
                          arguments: art,
                        );
                      },
                      onViewAllArticles: () =>
                          widget.onNavigateToTab(NeoNavTab.article),
                    ),
                    const SizedBox(height: NeoTokens.space16),
                  ],

                  // Medical & Calculation Methodology Disclaimer
                  NeoCard(
                    backgroundColor: NeoTokens.recess,
                    padding: const EdgeInsets.all(NeoTokens.space12),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          AppIcons.info,
                          size: AppIcons.sizeMedium,
                          color: NeoTokens.inkSecondary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Target kalori dihitung menggunakan rumus Mifflin-St Jeor. Estimasi gizi didasarkan pada Tabel Komposisi Pangan Indonesia (TKPI). Konsultasikan dengan dokter atau ahli gizi untuk kebutuhan medis khusus.',
                            style: TextStyle(
                              fontSize: 11,
                              color: NeoTokens.inkSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom padding ensuring bottom navigation bar never obscures content
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementBanner() {
    final ann = _announcements.first;
    return NeoCard(
      backgroundColor: ann.type == 'warning'
          ? NeoTokens.hazard
          : NeoTokens.lime,
      padding: const EdgeInsets.all(NeoTokens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ann.type == 'warning' ? AppIcons.warning : AppIcons.campaign,
            color: NeoTokens.ink,
            size: AppIcons.sizeHeader,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const NeoBadge(
                      label: 'PENGUMUMAN',
                      color: NeoBadgeColor.dark,
                      fontSize: 10,
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ann.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  ann.message,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: NeoTokens.ink,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              AppIcons.close,
              size: AppIcons.sizeLarge,
              color: NeoTokens.ink,
            ),
            tooltip: 'Tutup Pengumuman',
            onPressed: () {
              setState(() => _dismissedAnnouncement = true);
            },
          ),
        ],
      ),
    );
  }
}
