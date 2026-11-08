import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/shared/neo/neo_button.dart';
import 'package:oopsieeats/shared/neo/neo_card.dart';
import 'package:oopsieeats/shared/neo/neo_progress_bar.dart';
import 'package:oopsieeats/shared/neo/neo_dialog.dart';

void main() {
  group('NeoMotion Design Tokens & Hierarchy', () {
    test('Motion durations follow strict perceptual hierarchy', () {
      expect(NeoMotion.durationInstant, Duration.zero);
      expect(
        NeoMotion.durationFast.inMilliseconds,
        lessThan(NeoMotion.durationShort.inMilliseconds),
      );
      expect(
        NeoMotion.durationShort.inMilliseconds,
        lessThan(NeoMotion.durationMedium.inMilliseconds),
      );
      expect(
        NeoMotion.durationMedium.inMilliseconds,
        lessThan(NeoMotion.durationLong.inMilliseconds),
      );
    });

    testWidgets('Respects standard animations when enabled', (tester) async {
      late Duration resolvedFast;
      late Duration resolvedMedium;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: false),
            child: Builder(
              builder: (context) {
                resolvedFast = NeoMotion.getDuration(
                  context,
                  NeoMotion.durationFast,
                );
                resolvedMedium = NeoMotion.getDuration(
                  context,
                  NeoMotion.durationMedium,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(resolvedFast, NeoMotion.durationFast);
      expect(resolvedMedium, NeoMotion.durationMedium);
    });

    testWidgets('Returns Duration.zero when OS reduced motion is active', (
      tester,
    ) async {
      late Duration resolvedFast;
      late Duration resolvedShort;
      late Duration resolvedMedium;
      late bool isDisabled;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                isDisabled = NeoMotion.isAnimationDisabled(context);
                resolvedFast = NeoMotion.getDuration(
                  context,
                  NeoMotion.durationFast,
                );
                resolvedShort = NeoMotion.getDuration(
                  context,
                  NeoMotion.durationShort,
                );
                resolvedMedium = NeoMotion.getDuration(
                  context,
                  NeoMotion.durationMedium,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isDisabled, isTrue);
      expect(resolvedFast, Duration.zero);
      expect(resolvedShort, Duration.zero);
      expect(resolvedMedium, Duration.zero);
    });
  });

  group('NeoButton Motion & Tactile Animation', () {
    testWidgets('NeoButton animates into offset on tap down and releases', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NeoButton(
                text: 'KLIK SAYA',
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(NeoButton);
      expect(buttonFinder, findsOneWidget);

      final gesture = await tester.startGesture(tester.getCenter(buttonFinder));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: buttonFinder,
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(animatedContainer.duration, NeoMotion.durationFast);

      await gesture.up();
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('NeoButton has Duration.zero when animations disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: NeoButton(text: 'REDUCED MOTION', onPressed: () {}),
              ),
            ),
          ),
        ),
      );

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(NeoButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(animatedContainer.duration, Duration.zero);
    });
  });

  group('NeoCard Motion & Tactile Animation', () {
    testWidgets('NeoCard with onTap uses NeoMotion durationFast', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NeoCard(
                onTap: () {},
                child: const Text('Interactive Card'),
              ),
            ),
          ),
        ),
      );

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(NeoCard),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(animatedContainer.duration, NeoMotion.durationFast);
      expect(animatedContainer.curve, NeoMotion.curveStandard);
    });
  });

  group('NeoProgressBar Motion', () {
    testWidgets('NeoProgressBar uses NeoMotion durationMedium and decelerate', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: NeoProgressBar(value: 0.65))),
        ),
      );

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(NeoProgressBar),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(animatedContainer.duration, NeoMotion.durationMedium);
      expect(animatedContainer.curve, NeoMotion.curveDecelerate);
    });
  });

  group('NeoDialog Motion & Transitions', () {
    testWidgets('NeoDialog.show mounts and dismisses with smooth transition', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    NeoDialog.show(
                      context,
                      title: 'Konfirmasi Keluar',
                      message: 'Apakah Anda yakin ingin keluar?',
                      confirmText: 'Ya, Keluar',
                    );
                  },
                  child: const Text('Buka Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Konfirmasi Keluar'), findsOneWidget);
      expect(find.byType(NeoDialog), findsOneWidget);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.byType(NeoDialog), findsNothing);
    });
  });
}
