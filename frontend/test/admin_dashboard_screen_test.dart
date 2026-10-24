import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:nutriview/features/admin/presentation/widgets/atwater_checker_widget.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepo;
  late AuthProvider authProvider;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
    when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'super_admin');
    when(() => mockAuthRepo.getUserName()).thenAnswer((_) async => 'Ahmad Badawi');
    when(() => mockAuthRepo.getUserEmail())
        .thenAnswer((_) async => 'ahmadbadawi.biu.si@gmail.com');
    when(() => mockAuthRepo.logout()).thenAnswer((_) async {});

    authProvider = AuthProvider(mockAuthRepo);
  });

  Widget createAdminTestWidget() {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: const MaterialApp(
        home: AdminDashboardScreen(
          adminEmail: 'ahmadbadawi.biu.si@gmail.com',
          adminRole: 'super_admin',
          adminName: 'Ahmad Badawi',
        ),
      ),
    );
  }

  group('Admin Dashboard Overkill Neo-Brutalism UI/UX Parity Tests', () {
    testWidgets('renders Top AppBar with NutriView, PORTAL ADMIN badge, role badge, and actions', (tester) async {
      await tester.pumpWidget(createAdminTestWidget());
      await tester.pump();

      // Top Header checks
      expect(find.text('NutriView'), findsOneWidget);
      expect(find.text('PORTAL ADMIN'), findsOneWidget);
      expect(find.text('SUPER ADMIN'), findsOneWidget);
      expect(find.byTooltip('Buka Mode Pengguna'), findsOneWidget);
      expect(find.byTooltip('Keluar dari Portal Admin'), findsOneWidget);

      // Verify all 6 tabs exist in TabBar
      expect(find.text('RINGKASAN'), findsOneWidget);
      expect(find.text('PANGAN'), findsOneWidget);
      expect(find.text('ATWATER'), findsOneWidget);
      expect(find.text('ARTIKEL'), findsOneWidget);
      expect(find.text('PENGGUNA'), findsOneWidget);
      expect(find.text('LOG AUDIT'), findsOneWidget);
    });

    testWidgets('Summary tab renders HUD stat cards and Quick Actions', (tester) async {
      await tester.pumpWidget(createAdminTestWidget());
      await tester.pump();

      expect(find.text('TOTAL PANGAN'), findsOneWidget);
      expect(find.text('ARTIKEL TERBIT'), findsOneWidget);
      expect(find.text('ASET MEDIA'), findsOneWidget);
      expect(find.text('AKTIVITAS AUDIT'), findsOneWidget);
      expect(find.text('AKSI CEPAT MANAJEMEN GIZI'), findsOneWidget);
      expect(find.text('+ Pangan Baru'), findsOneWidget);
      expect(find.text('+ Tulis Artikel'), findsOneWidget);
      expect(find.text('LOG AUDIT TERAKHIR'), findsOneWidget);
    });

    testWidgets('Tapping PANGAN tab displays tactile search bar, + Tambah button, and filter pills', (tester) async {
      await tester.pumpWidget(createAdminTestWidget());
      await tester.pump();

      // Tap PANGAN tab
      await tester.tap(find.text('PANGAN'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cari makanan atau YOLO class...'), findsOneWidget);
      expect(find.text('+ Tambah'), findsOneWidget);

      // Verify tactile filter pills
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
      expect(find.text('Nonaktif'), findsOneWidget);
    });

    testWidgets('Tapping ATWATER tab renders Atwater simulator and AtwaterCheckerWidget', (tester) async {
      await tester.pumpWidget(createAdminTestWidget());
      await tester.pump();

      await tester.tap(find.text('ATWATER'));
      await tester.pumpAndSettle();

      expect(find.text('SIMULATOR FISIKA GIZI ATWATER'), findsOneWidget);
      expect(find.byType(AtwaterCheckerWidget), findsOneWidget);
      expect(find.text('ATWATER ENERGY CHECKER'), findsOneWidget);
      expect(find.text('Daftarkan Nilai Ini ke Katalog'), findsOneWidget);
    });

    testWidgets('Tapping ARTIKEL tab renders Header and + Tulis Artikel button', (tester) async {
      await tester.pumpWidget(createAdminTestWidget());
      await tester.pump();

      await tester.tap(find.text('ARTIKEL'));
      await tester.pumpAndSettle();

      expect(find.text('KONTEN EDUKASI GIZI'), findsOneWidget);
      expect(find.widgetWithText(NeoButton, '+ Tulis Artikel'), findsOneWidget);
    });

    testWidgets('Tapping PENGGUNA tab displays search bar, refresh button, and 4 role filter pills', (tester) async {
      await tester.pumpWidget(createAdminTestWidget());
      await tester.pump();

      await tester.tap(find.text('PENGGUNA'));
      await tester.pumpAndSettle();

      expect(find.text('Cari nama atau email pengguna...'), findsOneWidget);
      expect(find.byTooltip('Segarkan data pengguna'), findsOneWidget);

      expect(find.text('Semua Role'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      expect(find.text('Dietitian'), findsOneWidget);
      expect(find.text('Super Admin'), findsOneWidget);
    });

    testWidgets('Tapping LOG AUDIT tab displays entity filter pills', (tester) async {
      await tester.pumpWidget(createAdminTestWidget());
      await tester.pump();

      await tester.tap(find.text('LOG AUDIT'));
      await tester.pumpAndSettle();

      expect(find.text('Entitas: '), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Pangan'), findsOneWidget);
      expect(find.text('Artikel'), findsOneWidget);
    });

    testWidgets('Tapping logout button shows NeoDialog confirmation', (tester) async {
      await tester.pumpWidget(createAdminTestWidget());
      await tester.pump();

      await tester.tap(find.byTooltip('Keluar dari Portal Admin'));
      await tester.pumpAndSettle();

      // Check NeoDialog rendered
      expect(find.text('Keluar dari Portal Admin?'), findsOneWidget);
      expect(find.text('Ya, Keluar'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Keluar dari Portal Admin?'), findsNothing);
    });
  });
}
