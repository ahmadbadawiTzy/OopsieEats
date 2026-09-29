import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/config.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/dashboard/providers/dashboard_provider.dart';
import 'package:nutriview/shared/widgets/custom_button.dart';
import 'package:nutriview/shared/widgets/error_view.dart';
import 'package:nutriview/shared/widgets/loading_indicator.dart';
import 'package:nutriview/shared/widgets/progress_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  void _previousDay() {
    final prov = context.read<DashboardProvider>();
    final prev = prov.selectedDate.subtract(const Duration(days: 1));
    prov.changeDate(prev);
  }

  void _nextDay() {
    final prov = context.read<DashboardProvider>();
    final next = prov.selectedDate.add(const Duration(days: 1));
    prov.changeDate(next);
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final isToday = dash.selectedDate.year == DateTime.now().year &&
        dash.selectedDate.month == DateTime.now().month &&
        dash.selectedDate.day == DateTime.now().day;
    final dateDisplay = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dash.selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreenLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'NutriView',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Riwayat Makan',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.mealHistory);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final nav = Navigator.of(context);
              await auth.logout();
              if (!mounted) return;
              nav.pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () => dash.loadDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 24),
                      visualDensity: VisualDensity.compact,
                      onPressed: _previousDay,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateDisplay,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreenLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Hari Ini',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreenDark,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 24),
                      visualDensity: VisualDensity.compact,
                      onPressed: _nextDay,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Profile incomplete warning
              if (dash.isProfileIncomplete) ...[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrangeLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFE0B2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppTheme.accentOrange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Profil Gizi Belum Lengkap',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sistem membutuhkan data profil Anda untuk menghitung target gizi harian yang tepat.',
                        style: TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Lengkapi Profil Sekarang',
                        icon: Icons.person_add_alt_1_outlined,
                        backgroundColor: AppTheme.accentOrange,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.profile);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // State handling: loading / error / content
              if (dash.isLoading && dash.dashboard == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.0),
                  child: LoadingIndicator(message: 'Memuat progres harian...'),
                )
              else if (dash.errorMessage != null && !dash.isProfileIncomplete)
                ErrorView(
                  message: dash.errorMessage!,
                  onRetry: () => dash.loadDashboard(),
                )
              else if (dash.dashboard != null) ...[
                // Meal count banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            size: 18,
                            color: AppTheme.primaryGreen,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Total Catatan Makan',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreenLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${dash.dashboard!.mealCount} kali',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryGreenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section Title
                const Padding(
                  padding: EdgeInsets.only(left: 2.0, bottom: 8.0),
                  child: Text(
                    'Asupan Gizi Hari Ini',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                // Progress cards
                ProgressCard(
                  title: 'Energi / Kalori',
                  progress: dash.dashboard!.progress.calories,
                  unit: 'kkal',
                  barColor: AppTheme.primaryGreen,
                ),
                ProgressCard(
                  title: 'Protein',
                  progress: dash.dashboard!.progress.protein,
                  unit: 'g',
                  barColor: AppTheme.accentBlue,
                ),
                ProgressCard(
                  title: 'Karbohidrat',
                  progress: dash.dashboard!.progress.carbs,
                  unit: 'g',
                  barColor: AppTheme.accentOrange,
                ),
                ProgressCard(
                  title: 'Lemak',
                  progress: dash.dashboard!.progress.fat,
                  unit: 'g',
                  barColor: AppTheme.accentPurple,
                ),
                const SizedBox(height: 16),
              ],

              // Disclaimer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppConfig.disclaimerText,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 84),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.camera_alt_rounded, size: 20),
        label: const Text(
          'Scan Makanan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: -0.1,
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.scanner);
        },
      ),
    );
  }
}
