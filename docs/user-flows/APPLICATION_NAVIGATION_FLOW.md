# Application Navigation Flow

## 1. Declarative Navigation Architecture

NutriView uses Flutter's native declarative routing map coupled with an assertive runtime Route Guard evaluated at application launch, state mutations, and route transitions.

```mermaid
stateDiagram-v2
    [*] --> SplashScreen: Launch App

    state "Authentication Stack" as AuthStack {
        LoginScreen --> RegisterScreen: Navigate to Register
        RegisterScreen --> LoginScreen: Back to Login
        LoginScreen --> ForgotPasswordModal: BottomSheet
        LoginScreen --> BiometricEnrollmentModal: BottomSheet
    }

    state "Onboarding Gate" as OnboardingGate {
        CompleteProfileScreen: /complete-profile\n(UnifiedBiodataForm Onboarding)
    }

    state "Core Consumer Tabs & Screens" as ConsumerStack {
        DashboardScreen: /dashboard\n(Home Tab)
        MealHistoryScreen: /history\n(History Tab)
        ArticleListScreen: /articles\n(Articles Tab)
        ProfileScreen: /profile\n(Profile Tab)
    }

    state "Scanner & Analysis Pipeline" as ScannerStack {
        ScannerScreen: /scanner
        DetectionConfirmationScreen: /detection-confirmation
        PortionInputScreen: /portion-input
        MealResultScreen: /meal-result
        FoodSearchModal: Modal BottomSheet
    }

    state "Profile & Settings" as ProfileStack {
        BiodataScreen: /biodata\n(UnifiedBiodataForm Edit)
        AboutScreen: /about\n(Developer & App Info)
    }

    state "Administrative Portal" as AdminStack {
        AdminDashboardScreen: /admin/dashboard
        AdminFoodCatalog: Tab / Section
        AdminArticles: Tab / Section
        AdminUserManagement: Tab / Section
        AdminAuditLogs: Tab / Section
    }

    SplashScreen --> LoginScreen: Unauthenticated
    SplashScreen --> CompleteProfileScreen: Authenticated & Incomplete Profile
    SplashScreen --> DashboardScreen: Authenticated & Complete Profile
    SplashScreen --> AdminDashboardScreen: Authenticated Admin Direct Link

    LoginScreen --> CompleteProfileScreen: First-time Sign In / Register
    LoginScreen --> DashboardScreen: Returning User (Profile Complete)

    CompleteProfileScreen --> DashboardScreen: Biodata Saved Successfully
    CompleteProfileScreen --> LoginScreen: Logout / Change Account

    DashboardScreen --> ScannerScreen: Tap Floating / Center Scan CTA
    DashboardScreen --> MealHistoryScreen: Tap 'Lihat Semua' or Nav Item
    DashboardScreen --> ArticleListScreen: Tap Article Card or Nav Item
    DashboardScreen --> ProfileScreen: Tap Avatar or Nav Item
    DashboardScreen --> AdminDashboardScreen: Admin Switcher (If Role == Admin)

    ScannerScreen --> DetectionConfirmationScreen: Photo Captured / Picked
    DetectionConfirmationScreen --> PortionInputScreen: Detections Confirmed
    DetectionConfirmationScreen --> FoodSearchModal: Add / Replace Food Item
    FoodSearchModal --> DetectionConfirmationScreen: Food Item Selected
    PortionInputScreen --> MealResultScreen: Calculate & Submit
    MealResultScreen --> DashboardScreen: Finish & View Today's Progress
    MealResultScreen --> MealHistoryScreen: Finish & View Log

    MealHistoryScreen --> MealDetailScreen: Tap Meal Card
    MealDetailScreen --> MealHistoryScreen: Delete Meal / Back

    ArticleListScreen --> ArticleDetailScreen: Tap Article Card
    ArticleDetailScreen --> ArticleListScreen: Back

    ProfileScreen --> BiodataScreen: Tap 'Kelola Biodata'
    ProfileScreen --> AboutScreen: Tap 'Tentang Aplikasi'
    ProfileScreen --> LoginScreen: Sign Out Confirmed
    BiodataScreen --> ProfileScreen: Save Changes / Cancel

    AdminDashboardScreen --> DashboardScreen: Exit to Consumer View
```

---

## 2. Route Guarding & Navigation Security

### 2.1 Route Guard Evaluation Rules
The route guard in `lib/main.dart` evaluates every route transition against three strict conditions:

```dart
// Route Guard Evaluation Logic
final isAuthenticated = authProvider.isAuthenticated;
final isProfileComplete = authProvider.isProfileComplete || profileProvider.isProfileComplete;
final isAdmin = authProvider.isAdmin;

if (!isAuthenticated) {
  // Allow only public auth routes
  if (route != Routes.login && route != Routes.register && route != Routes.splash) {
    return Routes.login;
  }
} else if (!isProfileComplete) {
  // Prevent skipping onboarding
  if (route != Routes.completeProfile) {
    return Routes.completeProfile;
  }
} else {
  // Profile is complete; protect admin routes
  if (route.startsWith('/admin') && !isAdmin) {
    return Routes.dashboard;
  }
}
```

### 2.2 Route Table Reference

| Route Name | Target Widget | Guard Requirements | Primary Parameters |
| :--- | :--- | :--- | :--- |
| `Routes.splash` (`/`) | `SplashScreen` | None (Initial) | None |
| `Routes.login` (`/login`) | `LoginScreen` | Guest Only | None |
| `Routes.register` (`/register`) | `RegisterScreen` | Guest Only | None |
| `Routes.completeProfile` (`/complete-profile`) | `CompleteProfileScreen` | Authenticated & Profile Incomplete | None |
| `Routes.dashboard` (`/dashboard`) | `DashboardScreen` | Authenticated & Profile Complete | None |
| `Routes.scanner` (`/scanner`) | `ScannerScreen` | Authenticated & Profile Complete | None |
| `Routes.detectionConfirmation` (`/detection-confirmation`) | `DetectionConfirmationScreen` | Authenticated & Profile Complete | `imageFile`, `detections` |
| `Routes.portionInput` (`/portion-input`) | `PortionInputScreen` | Authenticated & Profile Complete | `confirmedItems`, `imageFile` |
| `Routes.mealResult` (`/meal-result`) | `MealResultScreen` | Authenticated & Profile Complete | `mealData`, `imageFile` |
| `Routes.history` (`/history`) | `MealHistoryScreen` | Authenticated & Profile Complete | None |
| `Routes.mealDetail` (`/meal-detail`) | `MealDetailScreen` | Authenticated & Profile Complete | `mealId` |
| `Routes.profile` (`/profile`) | `ProfileScreen` | Authenticated & Profile Complete | None |
| `Routes.biodata` (`/biodata`) | `BiodataScreen` | Authenticated & Profile Complete | None |
| `Routes.about` (`/about`) | `AboutScreen` | Authenticated & Profile Complete | None |
| `Routes.adminDashboard` (`/admin/dashboard`) | `AdminDashboardScreen` | Authenticated & Role == 'admin' | None |
