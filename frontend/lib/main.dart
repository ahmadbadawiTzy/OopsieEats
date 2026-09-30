import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/config.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/api_client.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/data/repositories/dashboard_repository.dart';
import 'package:nutriview/data/repositories/food_repository.dart';
import 'package:nutriview/data/repositories/meal_repository.dart';
import 'package:nutriview/data/repositories/profile_repository.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/auth/screens/login_screen.dart';
import 'package:nutriview/features/auth/screens/register_screen.dart';
import 'package:nutriview/features/dashboard/providers/dashboard_provider.dart';
import 'package:nutriview/features/dashboard/screens/dashboard_screen.dart';
import 'package:nutriview/features/meals/providers/meal_history_provider.dart';
import 'package:nutriview/features/meals/screens/meal_detail_screen.dart';
import 'package:nutriview/features/meals/screens/meal_history_screen.dart';
import 'package:nutriview/features/profile/providers/profile_provider.dart';
import 'package:nutriview/features/profile/screens/profile_screen.dart';
import 'package:nutriview/features/scanner/providers/scan_flow_provider.dart';
import 'package:nutriview/features/scanner/screens/detection_confirmation_screen.dart';
import 'package:nutriview/features/scanner/screens/meal_result_screen.dart';
import 'package:nutriview/features/scanner/screens/portion_input_screen.dart';
import 'package:nutriview/features/scanner/screens/scanner_screen.dart';
import 'package:nutriview/shared/widgets/loading_indicator.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final apiClient = ApiClient();
  final authRepository = AuthRepository(apiClient);
  final profileRepository = ProfileRepository(apiClient);
  final foodRepository = FoodRepository(apiClient);
  final mealRepository = MealRepository(apiClient);
  final dashboardRepository = DashboardRepository(apiClient);

  final authProvider = AuthProvider(authRepository);

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
        Provider<AuthRepository>.value(value: authRepository),
        Provider<ProfileRepository>.value(value: profileRepository),
        Provider<FoodRepository>.value(value: foodRepository),
        Provider<MealRepository>.value(value: mealRepository),
        Provider<DashboardRepository>.value(value: dashboardRepository),
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

class NutriViewApp extends StatefulWidget {
  const NutriViewApp({super.key});

  @override
  State<NutriViewApp> createState() => _NutriViewAppState();
}

class _NutriViewAppState extends State<NutriViewApp> {
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialAuth();
    });
  }

  Future<void> _checkInitialAuth() async {
    await context.read<AuthProvider>().checkAuthStatus();
    if (mounted) {
      setState(() {
        _checkingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: LoadingIndicator(message: 'Mempersiapkan NutriView...'),
        ),
      );
    }

    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return MaterialApp(
      title: AppConfig.appName,
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      initialRoute: isLoggedIn ? AppRoutes.dashboard : AppRoutes.login,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.register:
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case AppRoutes.dashboard:
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case AppRoutes.profile:
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case AppRoutes.scanner:
            return MaterialPageRoute(builder: (_) => const ScannerScreen());
          case AppRoutes.detectionConfirm:
            return MaterialPageRoute(
              builder: (_) => const DetectionConfirmationScreen(),
            );
          case AppRoutes.portionInput:
            return MaterialPageRoute(builder: (_) => const PortionInputScreen());
          case AppRoutes.mealResult:
            return MaterialPageRoute(builder: (_) => const MealResultScreen());
          case AppRoutes.mealHistory:
            return MaterialPageRoute(builder: (_) => const MealHistoryScreen());
          case AppRoutes.mealDetail:
            final mealId = settings.arguments as int? ?? 0;
            return MaterialPageRoute(
              builder: (_) => MealDetailScreen(mealId: mealId),
            );
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
