import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/config.dart';
import 'package:oopsieeats/core/config/supabase_config.dart';
import 'package:oopsieeats/core/ml/yolo_detector.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/core/theme.dart';
import 'package:oopsieeats/data/api_client.dart';
import 'package:oopsieeats/data/models/article.dart';
import 'package:oopsieeats/data/repositories/article_repository.dart';
import 'package:oopsieeats/data/repositories/auth_repository.dart';
import 'package:oopsieeats/data/repositories/dashboard_repository.dart';
import 'package:oopsieeats/data/repositories/food_repository.dart';
import 'package:oopsieeats/data/repositories/meal_repository.dart';
import 'package:oopsieeats/data/repositories/profile_repository.dart';
import 'package:oopsieeats/data/services/supabase_storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oopsieeats/features/admin/data/admin_repository.dart';
import 'package:oopsieeats/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:oopsieeats/features/article/screens/article_detail_screen.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/auth/screens/complete_profile_screen.dart';
import 'package:oopsieeats/features/auth/screens/login_screen.dart';
import 'package:oopsieeats/features/auth/screens/register_screen.dart';
import 'package:oopsieeats/features/dashboard/providers/dashboard_provider.dart';
import 'package:oopsieeats/features/dashboard/screens/dashboard_screen.dart';
import 'package:oopsieeats/features/meals/providers/meal_history_provider.dart';
import 'package:oopsieeats/features/meals/screens/meal_detail_screen.dart';
import 'package:oopsieeats/features/profile/providers/profile_provider.dart';
import 'package:oopsieeats/features/profile/screens/about_screen.dart';
import 'package:oopsieeats/features/profile/screens/biodata_screen.dart';
import 'package:oopsieeats/features/scanner/providers/scan_flow_provider.dart';
import 'package:oopsieeats/features/scanner/screens/detection_confirmation_screen.dart';
import 'package:oopsieeats/features/scanner/screens/meal_result_screen.dart';
import 'package:oopsieeats/features/scanner/screens/portion_input_screen.dart';
import 'package:oopsieeats/features/scanner/screens/scanner_screen.dart';
import 'package:oopsieeats/features/onboarding/screens/onboarding_screen.dart';
import 'package:oopsieeats/features/splash/screens/splash_screen.dart';
import 'package:oopsieeats/firebase_options.dart';
import 'package:oopsieeats/shared/neo/neo.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Parallelize initial synchronous and network configurations
  await Future.wait([
    initializeDateFormatting('id_ID', null),
    () async {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        // Non-blocking fire-and-forget Firebase configurations
        fb.FirebaseAuth.instance.setLanguageCode('id').catchError((_) {});
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: 104857600,
        );
      } catch (e) {
        debugPrint('Firebase initialization warning: $e');
      }
    }(),
    () async {
      if (SupabaseConfig.isConfigured) {
        try {
          await Supabase.initialize(
            url: SupabaseConfig.url,
            publishableKey: SupabaseConfig.anonKey,
          );
        } catch (e) {
          debugPrint('Supabase initialization warning: $e');
        }
      }
    }(),
  ]);

  final yoloDetector = YoloDetector();
  // Asynchronously warmup YOLO in background without blocking first frame/startup
  yoloDetector.initialize().catchError((e) {
    debugPrint('Background YOLO detector initialization warning: $e');
  });

  final storageService = SupabaseStorageService();
  final apiClient = ApiClient();
  final authRepository = AuthRepository(
    apiClient,
    null,
    null,
    null,
    null,
    storageService,
  );
  final profileRepository = ProfileRepository(apiClient);
  final foodRepository = FoodRepository(apiClient, null, yoloDetector);
  final mealRepository = MealRepository(
    apiClient,
    null,
    null,
    foodRepository,
    storageService,
  );
  final dashboardRepository = DashboardRepository(apiClient);
  final articleRepository = ArticleRepository(client: apiClient);
  final adminRepository = AdminRepository(client: apiClient);

  final authProvider = AuthProvider(authRepository);
  final profileProvider = ProfileProvider(profileRepository);
  final dashboardProvider = DashboardProvider(dashboardRepository);

  authProvider.onLogout = () {
    dashboardRepository.invalidateUserCache();
    dashboardProvider.clear();
    profileProvider.clear();
    foodRepository.invalidateCache();
    articleRepository.invalidateCache();
    storageService.clearUrlCache();
  };

  profileProvider.onProfileUpdated = () {
    dashboardRepository.invalidateUserCache();
    if (profileProvider.dailyTarget != null) {
      dashboardProvider.updateTargetFromBiodata(profileProvider.dailyTarget!);
    } else if (!profileProvider.hasProfile) {
      dashboardProvider.handleBiodataDeleted();
    }
  };

  apiClient.onUnauthorized = () {
    authProvider.handleSessionExpired();
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  };

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<SupabaseStorageService>.value(value: storageService),
        Provider<YoloDetector>.value(value: yoloDetector),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<ProfileRepository>.value(value: profileRepository),
        Provider<FoodRepository>.value(value: foodRepository),
        Provider<MealRepository>.value(value: mealRepository),
        Provider<DashboardRepository>.value(value: dashboardRepository),
        Provider<ArticleRepository>.value(value: articleRepository),
        Provider<AdminRepository>.value(value: adminRepository),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
        ChangeNotifierProvider<DashboardProvider>.value(
          value: dashboardProvider,
        ),
        ChangeNotifierProvider<ScanFlowProvider>(
          create: (_) => ScanFlowProvider(
            foodRepository: foodRepository,
            mealRepository: mealRepository,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider<MealHistoryProvider>(
          create: (_) => MealHistoryProvider(mealRepository),
        ),
      ],
      child: const OopsieEatsApp(),
    ),
  );
}

/// Backward-compatible alias
typedef NutriViewApp = OopsieEatsApp;

class OopsieEatsApp extends StatelessWidget {
  const OopsieEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      onGenerateRoute: (settings) {
        final auth = context.read<AuthProvider>();

        // Profile completion guard: If user is authenticated, not admin,
        // and has not completed biodata profile, protect core feature routes.
        final isProtectedFeature =
            settings.name == AppRoutes.dashboard ||
            settings.name == AppRoutes.articles ||
            settings.name == AppRoutes.profile ||
            settings.name == AppRoutes.scanner ||
            settings.name == AppRoutes.detectionConfirm ||
            settings.name == AppRoutes.portionInput ||
            settings.name == AppRoutes.mealResult ||
            settings.name == AppRoutes.mealHistory ||
            settings.name == AppRoutes.mealDetail;

        final profileProvider = context.read<ProfileProvider>();
        final isProfileCompleted =
            auth.isProfileComplete || profileProvider.isProfileComplete;

        if (auth.isLoggedIn &&
            !auth.isAdmin &&
            !isProfileCompleted &&
            isProtectedFeature) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: AppRoutes.completeProfile),
            builder: (_) => const CompleteProfileScreen(),
          );
        }

        switch (settings.name) {
          case AppRoutes.initial:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case AppRoutes.onboarding:
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.register:
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case AppRoutes.completeProfile:
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const CompleteProfileScreen(),
            );
          case AppRoutes.dashboard:
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case AppRoutes.articles:
            return MaterialPageRoute(
              builder: (_) =>
                  const DashboardScreen(initialTab: NeoNavTab.article),
            );
          case AppRoutes.profile:
            return MaterialPageRoute(
              builder: (_) =>
                  const DashboardScreen(initialTab: NeoNavTab.profile),
            );
          case AppRoutes.scanner:
            return MaterialPageRoute(builder: (_) => const ScannerScreen());
          case AppRoutes.detectionConfirm:
            return MaterialPageRoute(
              builder: (_) => const DetectionConfirmationScreen(),
            );
          case AppRoutes.portionInput:
            return MaterialPageRoute(
              builder: (_) => const PortionInputScreen(),
            );
          case AppRoutes.mealResult:
            return MaterialPageRoute(builder: (_) => const MealResultScreen());
          case AppRoutes.mealHistory:
            return MaterialPageRoute(
              builder: (_) =>
                  const DashboardScreen(initialTab: NeoNavTab.history),
            );
          case AppRoutes.mealDetail:
            final mealId = settings.arguments as int? ?? 0;
            return MaterialPageRoute(
              builder: (_) => MealDetailScreen(mealId: mealId),
            );
          case AppRoutes.adminLogin:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.adminDashboard:
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final currentAuth = context.read<AuthProvider>();
            return MaterialPageRoute(
              builder: (_) => AdminDashboardScreen(
                adminEmail: args['email'] ?? currentAuth.email,
                adminRole: args['role'] ?? currentAuth.role,
                adminName: args['name'] ?? currentAuth.name,
              ),
            );
          case AppRoutes.articleDetail:
            final article = settings.arguments as ArticleItem;
            return MaterialPageRoute(
              builder: (_) => ArticleDetailScreen(article: article),
            );
          case AppRoutes.biodata:
            return MaterialPageRoute(builder: (_) => const BiodataScreen());
          case AppRoutes.about:
            return MaterialPageRoute(builder: (_) => const AboutScreen());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
