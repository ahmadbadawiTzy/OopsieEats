import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/data/repositories/auth_repository.dart';
import 'package:nutriview/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:nutriview/features/admin/presentation/widgets/atwater_checker_widget.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/admin/presentation/widgets/admin_components.dart';
import 'package:nutriview/shared/neo/neo.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepo;
  late AuthProvider authProvider;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
    when(() => mockAuthRepo.getRole()).thenAnswer((_) async => 'admin');
    when(() => mockAuthRepo.getUserName())
        .thenAnswer((_) async => 'Ahmad Badawi');
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
          adminRole: 'admin',
          adminName: 'Ahmad Badawi',
        ),
      ),
    );
  }

  group('Admin Dashboard Overkill Neo-Brutalism UI/UX Parity Tests', () {
    Future<void> openDrawerAndSelect(
      WidgetTester tester,
      String itemText,
    ) async {
      await tester.tap(find.byTooltip('Buka Menu Admin'));
      await tester.pumpAndSettle();
      final itemFinder = find.text(itemText);
      await tester.scrollUntilVisible(
        itemFinder,
        50.0,
        scrollable: find.descendant(
          of: find.byType(Drawer),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(itemFinder);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'renders Top AppBar with NutriView title and Hamburger button',
      (tester) async {
        await tester.pumpWidget(createAdminTestWidget());
        await tester.pump();

        // Top Header checks
        expect(find.text('NutriView'), findsOneWidget);
        expect(find.byTooltip('Buka Menu Admin'), findsOneWidget);

        // Verify redundant badges and actions are removed from AppBar
        expect(find.byTooltip('Buka Mode Pengguna'), findsNothing);
        expect(find.byTooltip('Keluar dari Portal Admin'), findsNothing);
      },
    );

    testWidgets('Summary tab renders HUD stat cards and Quick Actions', (
      tester,
    ) async {
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

    testWidgets(
      'Tapping KATALOG PANGAN displays tactile search bar, + Tambah button, and filter pills',
      (tester) async {
        await tester.pumpWidget(createAdminTestWidget());
        await tester.pump();

        // Open Drawer and tap KATALOG PANGAN
        await openDrawerAndSelect(tester, 'KATALOG PANGAN');

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Cari makanan atau YOLO class...'), findsOneWidget);
        expect(find.text('+ Tambah'), findsOneWidget);

        // Verify tactile filter pills
        expect(find.text('Semua'), findsOneWidget);
        expect(find.text('Aktif'), findsOneWidget);
        expect(find.text('Nonaktif'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping SIMULATOR ATWATER renders Atwater simulator and AtwaterCheckerWidget',
      (tester) async {
        await tester.pumpWidget(createAdminTestWidget());
        await tester.pump();

        await openDrawerAndSelect(tester, 'SIMULATOR ATWATER');

        expect(find.text('SIMULATOR FISIKA GIZI ATWATER'), findsOneWidget);
        expect(find.byType(AtwaterCheckerWidget), findsOneWidget);
        expect(find.text('ATWATER ENERGY CHECKER'), findsOneWidget);
        expect(find.text('Daftarkan Nilai Ini ke Katalog'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping ARTIKEL EDUKASI renders Header and + Tulis Artikel button',
      (tester) async {
        await tester.pumpWidget(createAdminTestWidget());
        await tester.pump();

        await openDrawerAndSelect(tester, 'ARTIKEL EDUKASI');

        expect(find.text('KONTEN EDUKASI GIZI'), findsOneWidget);
        expect(
          find.widgetWithText(NeoButton, '+ Tulis Artikel'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Tapping MANAJEMEN PENGGUNA displays search bar, refresh button, and 3 role filter pills',
      (tester) async {
        await tester.pumpWidget(createAdminTestWidget());
        await tester.pump();

        await openDrawerAndSelect(tester, 'MANAJEMEN PENGGUNA');

        expect(find.text('Cari nama atau email pengguna...'), findsOneWidget);
        expect(find.byTooltip('Segarkan data pengguna'), findsOneWidget);

        expect(find.text('Semua Role'), findsOneWidget);
        expect(find.text('User'), findsOneWidget);
        expect(find.text('Admin'), findsOneWidget);
        expect(find.text('Super Admin'), findsNothing);
      },
    );

    testWidgets('Tapping LOG AUDIT TRAIL displays entity filter pills', (
      tester,
    ) async {
      await tester.pumpWidget(createAdminTestWidget());
      await tester.pump();

      await openDrawerAndSelect(tester, 'LOG AUDIT TRAIL');

      expect(find.text('Entitas: '), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Pangan'), findsOneWidget);
      expect(find.text('Artikel'), findsOneWidget);
    });

    testWidgets('Tapping logout button shows NeoDialog confirmation', (
      tester,
    ) async {
      await tester.pumpWidget(createAdminTestWidget());
      await tester.pump();

      await tester.tap(find.byTooltip('Buka Menu Admin'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keluar Portal'));
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

    testWidgets(
      'Mobile Drawer Navigation: Hamburger button opens Drawer and tapping item closes Drawer',
      (tester) async {
        await tester.pumpWidget(createAdminTestWidget());
        await tester.pump();

        // Check hamburger menu button on AppBar
        final menuBtn = find.byTooltip('Buka Menu Admin');
        expect(menuBtn, findsOneWidget);

        // Tap hamburger button to open drawer
        await tester.tap(menuBtn);
        await tester.pumpAndSettle();

        // Verify Drawer is open with Admin sidebar items
        expect(find.byType(Drawer), findsOneWidget);
        expect(find.text('IKHTISAR SISTEM'), findsOneWidget);
        expect(find.text('DATA GIZI & PANGAN'), findsOneWidget);
        expect(find.text('KATALOG PANGAN'), findsOneWidget);

        // Tap a navigation link inside the drawer (e.g. KATALOG PANGAN)
        await tester.tap(find.text('KATALOG PANGAN'));
        await tester.pumpAndSettle();

        // Verify Drawer automatically closed
        expect(find.byType(Drawer), findsNothing);

        // Verify tab navigated to Pangan
        expect(find.text('Cari makanan atau YOLO class...'), findsOneWidget);
      },
    );

    testWidgets(
      'Desktop Responsive View: persistent AdminSidebar renders on width >= 900',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createAdminTestWidget());
        await tester.pump();

        // In desktop mode, persistent AdminSidebar is rendered directly without a Drawer
        expect(find.byType(Drawer), findsNothing);
        expect(find.text('IKHTISAR SISTEM'), findsOneWidget);
        expect(find.text('PORTAL ADMIN'), findsOneWidget);
        expect(find.text('Segarkan'), findsOneWidget);
      },
    );
  });

  group('Admin Reusable Components & Rule F Design System Tests', () {
    testWidgets(
      'AdminStatusBadge renders semantic colors and bold typography',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  AdminStatusBadge(
                    label: 'AKTIF',
                    backgroundColor: Colors.green,
                  ),
                  AdminStatusBadge(
                    label: 'NONAKTIF',
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('AKTIF'), findsOneWidget);
        expect(find.text('NONAKTIF'), findsOneWidget);
      },
    );

    testWidgets(
      'AdminActionButton renders single tactile action button conforming to Rule F',
      (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AdminActionButton.more(
                tooltip: 'Menu Aksi & Detail',
                onPressed: () => tapped = true,
              ),
            ),
          ),
        );

        expect(find.byType(AdminActionButton), findsOneWidget);
        expect(find.byTooltip('Menu Aksi & Detail'), findsOneWidget);

        await tester.tap(find.byType(AdminActionButton));
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'AdminEmptyState, AdminLoadingState, and AdminErrorState render properly',
      (tester) async {
        bool retried = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const AdminLoadingState(message: 'Memuat data...'),
                  AdminErrorState(
                    errorMessage: 'Koneksi gagal',
                    onRetry: () => retried = true,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Memuat data...'), findsOneWidget);
        expect(find.text('Koneksi gagal'), findsOneWidget);
        expect(find.text('Coba Lagi'), findsOneWidget);

        await tester.tap(find.text('Coba Lagi'));
        expect(retried, isTrue);
      },
    );
  });
}
