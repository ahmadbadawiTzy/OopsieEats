import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/config.dart';
import 'package:nutriview/core/ml/yolo_detector.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/models/article.dart';
import 'package:nutriview/data/repositories/article_repository.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/data/repositories/dashboard_repository.dart';
import 'package:nutriview/data/repositories/food_repository.dart';
import 'package:nutriview/data/repositories/meal_repository.dart';
import 'package:nutriview/data/repositories/profile_repository.dart';
import 'package:nutriview/features/admin/data/admin_repository.dart';
import 'package:nutriview/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:nutriview/features/article/screens/article_detail_screen.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/auth/screens/login_screen.dart';
import 'package:nutriview/features/auth/screens/register_screen.dart';
import 'package:nutriview/features/dashboard/providers/dashboard_provider.dart';
import 'package:nutriview/features/dashboard/screens/dashboard_screen.dart';
import 'package:nutriview/features/meals/providers/meal_history_provider.dart';
import 'package:nutriview/features/meals/screens/meal_detail_screen.dart';
import 'package:nutriview/features/profile/providers/profile_provider.dart';
import 'package:nutriview/features/profile/screens/about_screen.dart';
import 'package:nutriview/features/profile/screens/biodata_screen.dart';
import 'package:nutriview/features/scanner/providers/scan_flow_provider.dart';
import 'package:nutriview/features/scanner/screens/detection_confirmation_screen.dart';
import 'package:nutriview/features/scanner/screens/meal_result_screen.dart';
import 'package:nutriview/features/scanner/screens/portion_input_screen.dart';
import 'package:nutriview/features/scanner/screens/scanner_screen.dart';
import 'package:nutriview/features/splash/screens/splash_screen.dart';
import 'package:nutriview/firebase_options.dart';
import 'package:nutriview/shared/neo/neo.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Send official auth emails (password reset, verification) in Indonesian
    try {
      await fb.FirebaseAuth.instance.setLanguageCode('id');
    } catch (_) {}
    // Production bounded cache: 100MB prevents unbounded memory and disk footprint
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 104857600,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  final yoloDetector = YoloDetector();
  // Asynchronously warmup YOLO in background without blocking first frame/startup
  yoloDetector.initialize().catchError((e) {
    debugPrint('Background YOLO detector initialization warning: $e');
  });

  final apiClient = ApiClient();
  final authRepository = AuthRepository(apiClient);
  final profileRepository = ProfileRepository(apiClient);
  final foodRepository = FoodRepository(apiClient, null, yoloDetector);
  final mealRepository = MealRepository(apiClient, null, null, foodRepository);
  final dashboardRepository = DashboardRepository(apiClient);
  final articleRepository = ArticleRepository(client: apiClient);
  final adminRepository = AdminRepository(client: apiClient);

  final authProvider = AuthProvider(authRepository);
  authProvider.onLogout = () {
    dashboardRepository.invalidateUserCache();
    foodRepository.invalidateCache();
    articleRepository.invalidateCache();
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
        Provider<YoloDetector>.value(value: yoloDetector),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<ProfileRepository>.value(value: profileRepository),
        Provider<FoodRepository>.value(value: foodRepository),
        Provider<MealRepository>.value(value: mealRepository),
        Provider<DashboardRepository>.value(value: dashboardRepository),
        Provider<ArticleRepository>.value(value: articleRepository),
        Provider<AdminRepository>.value(value: adminRepository),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(profileRepository),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(dashboardRepository),
        ),
        ChangeNotifierProvider<ScanFlowProvider>(
          create: (_) => ScanFlowProvider(
            foodRepository: foodRepository,
            mealRepository: mealRepository,
          ),
        ),
        ChangeNotifierProvider<MealHistoryProvider>(
          create: (_) => MealHistoryProvider(mealRepository),
        ),
      ],
      child: const NutriViewApp(),
    ),
  );
}

class NutriViewApp extends StatelessWidget {
  const NutriViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.initial,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.initial:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.register:
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
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
