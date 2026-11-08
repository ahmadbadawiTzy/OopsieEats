import 'package:flutter_test/flutter_test.dart';
import 'package:oopsieeats/core/age_calculator.dart';

void main() {
  group('AgeCalculator Unit Tests', () {
    test(
      'calculates correct age when birthday has already passed this year',
      () {
        final now = DateTime.now();
        // Birthday 25 years ago, earlier this year
        final birthDate = DateTime(now.year - 25, 1, 1);
        final age = AgeCalculator.calculateAge(birthDate);
        expect(age, equals(25));
      },
    );

    test(
      'calculates correct age when birthday has not occurred yet this year',
      () {
        final now = DateTime.now();
        // If today is December 31, birthday cannot be later this year,
        // but in general month 12 day 31 is later if now is before Dec 31
        final futureMonth = now.month < 12 ? now.month + 1 : 12;
        final futureDay = now.month < 12 ? now.day : 28;

        if (now.month < 12 || now.day < 28) {
          final birthDate = DateTime(now.year - 20, futureMonth, futureDay);
          final age = AgeCalculator.calculateAge(birthDate);
          expect(age, equals(19));
        }
      },
    );

    test('calculates correct age on exact birthday today', () {
      final now = DateTime.now();
      final birthDate = DateTime(now.year - 30, now.month, now.day);
      final age = AgeCalculator.calculateAge(birthDate);
      expect(age, equals(30));
    });

    test('handles leap year birthday (Feb 29)', () {
      // Leap year: 2000-02-29
      final birthDate = DateTime(2000, 2, 29);
      final age = AgeCalculator.calculateAge(birthDate);
      expect(age, isNotNull);
      expect(age! >= 24, isTrue);
    });

    test('returns null for future dates or null input', () {
      expect(AgeCalculator.calculateAge(null), isNull);
      final futureDate = DateTime.now().add(const Duration(days: 30));
      expect(AgeCalculator.calculateAge(futureDate), isNull);
    });

    test('validates age bounds (5 to 120)', () {
      final now = DateTime.now();
      final infant = DateTime(now.year - 2, 1, 1);
      expect(AgeCalculator.isValidAge(infant), isFalse);

      final validChild = DateTime(now.year - 10, 1, 1);
      expect(AgeCalculator.isValidAge(validChild), isTrue);

      final tooOld = DateTime(now.year - 125, 1, 1);
      expect(AgeCalculator.isValidAge(tooOld), isFalse);
    });

    test('formats and parses ISO date strings reliably', () {
      final date = DateTime(1998, 5, 17);
      final iso = AgeCalculator.toIsoDate(date);
      expect(iso, equals('1998-05-17'));

      final parsed = AgeCalculator.parseIsoDate('1998-05-17');
      expect(parsed, isNotNull);
      expect(parsed!.year, equals(1998));
      expect(parsed.month, equals(5));
      expect(parsed.day, equals(17));

      expect(AgeCalculator.parseIsoDate(null), isNull);
      expect(AgeCalculator.parseIsoDate('invalid-date'), isNull);
    });

    test('formats Indonesian human-readable date', () {
      final date = DateTime(2002, 10, 24);
      final formatted = AgeCalculator.formatIndonesian(date);
      expect(formatted, contains('2002'));
      expect(formatted, contains('Oktober'));
      expect(AgeCalculator.formatIndonesian(null), equals('-'));
    });
  });
}
