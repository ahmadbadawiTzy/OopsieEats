import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/data/repositories/food_repository.dart';
import 'package:oopsieeats/data/repositories/meal_repository.dart';
import 'package:oopsieeats/features/dashboard/providers/dashboard_provider.dart';
import 'package:oopsieeats/features/scanner/providers/scan_flow_provider.dart';
import 'package:oopsieeats/features/scanner/screens/portion_input_screen.dart';

class MockFoodRepository extends Mock implements FoodRepository {}
class MockMealRepository extends Mock implements MealRepository {}
class MockDashboardProvider extends Mock implements DashboardProvider {}

void main() {
  late MockFoodRepository mockFoodRepo;
  late MockMealRepository mockMealRepo;
  late ScanFlowProvider scanFlowProvider;

  setUp(() {
    mockFoodRepo = MockFoodRepository();
    mockMealRepo = MockMealRepository();
    scanFlowProvider = ScanFlowProvider(
      foodRepository: mockFoodRepo,
      mealRepository: mockMealRepo,
    );

    // Seed scan flow with a detected item
    scanFlowProvider.confirmedItems.add(
      ConfirmedFoodItem(
        foodId: 101,
        foodName: 'Nasi Goreng Spesial',
        portionGrams: 0.0,
        source: 'detected',
        caloriesPer100g: 168.0,
        proteinPer100g: 5.0,
        carbsPer100g: 22.0,
        fatPer100g: 7.0,
        hasNutritionData: true,
      ),
    );
  });

  Widget buildTestableScreen({double width = 390, double height = 844}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScanFlowProvider>.value(value: scanFlowProvider),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, height),
            textScaler: const TextScaler.linear(1.0),
          ),
          child: const PortionInputScreen(),
        ),
      ),
    );
  }

  group('PortionInputScreen Widget & Formatting Tests', () {
    testWidgets('Initial display value defaults to 0 and not 150', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextFormField);
      expect(textFieldFinder, findsOneWidget);

      final formField = tester.widget<TextFormField>(textFieldFinder);
      expect(formField.controller?.text, '0');
    });

    testWidgets('Tapping 0 selects entire text so user can immediately overwrite', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextFormField);
      final formField = tester.widget<TextFormField>(textFieldFinder);

      // Tap on the field
      await tester.tap(textFieldFinder);
      await tester.pumpAndSettle();

      // Selection must span full text [0, 1]
      expect(formField.controller?.selection.baseOffset, 0);
      expect(formField.controller?.selection.extentOffset, 1);
    });

    testWidgets('PortionNumberInputFormatter replaces leading zero when typing positive number', (tester) async {
      final formatter = PortionNumberInputFormatter();

      // Typing '5' when field was '0'
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '0',
          selection: TextSelection.collapsed(offset: 1),
        ),
        const TextEditingValue(
          text: '05',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );

      expect(result.text, '5');
      expect(result.selection.baseOffset, 1);
    });

    testWidgets('PortionNumberInputFormatter sanitizes comma to dot and allows decimals', (tester) async {
      final formatter = PortionNumberInputFormatter();

      // Typing '1,5' -> becomes '1.5'
      final resultComma = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '1',
          selection: TextSelection.collapsed(offset: 1),
        ),
        const TextEditingValue(
          text: '1,5',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(resultComma.text, '1.5');

      // Typing '0.5' -> preserves leading zero with decimal
      final resultDecimal = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '0',
          selection: TextSelection.collapsed(offset: 1),
        ),
        const TextEditingValue(
          text: '0.5',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(resultDecimal.text, '0.5');

      // Rejecting > 5000g
      final resultOver = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '500',
          selection: TextSelection.collapsed(offset: 3),
        ),
        const TextEditingValue(
          text: '5001',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      expect(resultOver.text, '500'); // Kept old value
    });

    testWidgets('Input survives widget rebuild without resetting to 0', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextFormField);
      await tester.enterText(textFieldFinder, '225');
      await tester.pumpAndSettle();

      expect(find.text('225'), findsOneWidget);

      // Trigger provider notify/rebuild
      scanFlowProvider.setMealType('dinner');
      await tester.pumpAndSettle();

      // Ensure value remains 225
      final formField = tester.widget<TextFormField>(textFieldFinder);
      expect(formField.controller?.text, '225');
    });

    testWidgets('Zero value triggers validation rejection on submit', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final saveButtonFinder = find.text('Simpan & Catat Makanan');
      expect(saveButtonFinder, findsOneWidget);

      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // Form validation error appears
      expect(find.text('1-5000g'), findsOneWidget);
    });

    testWidgets('Does not overflow horizontally on ultra-narrow 320px screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 600));
      await tester.pumpWidget(buildTestableScreen(width: 320, height: 600));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Nasi Goreng Spesial'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
