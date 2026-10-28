/// Utility for accurate age calculation and birth date validation.
class AgeCalculator {
  static const int minAge = 5;
  static const int maxAge = 120;

  /// Calculates the exact completed age in years from a given [birthDate].
  ///
  /// Correctly handles:
  /// - Whether the user's birthday has already occurred in the reference year
  /// - Leap years (e.g. February 29th)
  /// - Same-day birthdays (turning a year older on the exact day)
  ///
  /// Returns `null` if [birthDate] is null or in the future.
  static int? calculateAge(DateTime? birthDate, [DateTime? referenceDate]) {
    if (birthDate == null) return null;

    final now = referenceDate ?? DateTime.now();

    // Check if birthDate is in the future
    if (birthDate.isAfter(now)) return null;

    // Normalizing to date components to ignore time differences
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentDay = now.day;

    final birthYear = birthDate.year;
    final birthMonth = birthDate.month;
    final birthDay = birthDate.day;

    int age = currentYear - birthYear;

    // If the birthday has not yet occurred this year, subtract 1
    if (currentMonth < birthMonth ||
        (currentMonth == birthMonth && currentDay < birthDay)) {
      age--;
    }

    return age >= 0 ? age : null;
  }

  /// Validates a [birthDate] for app usage.
  /// Returns an error message string if invalid, or `null` if valid.
  static String? validateBirthDate(
    DateTime? birthDate, [
    DateTime? referenceDate,
  ]) {
    if (birthDate == null) {
      return 'Tanggal lahir wajib diisi.';
    }

    final now = referenceDate ?? DateTime.now();
    if (birthDate.isAfter(now)) {
      return 'Tanggal lahir tidak boleh berada di masa depan.';
    }

    final age = calculateAge(birthDate, now);
    if (age == null) {
      return 'Tanggal lahir tidak valid.';
    }

    if (age < minAge) {
      return 'Usia minimal adalah $minAge tahun.';
    }

    if (age > maxAge) {
      return 'Usia tidak boleh melebihi $maxAge tahun.';
    }

    return null;
  }

  /// Formats a [DateTime] to ISO date format `YYYY-MM-DD`.
  static String formatIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Alias for [formatIsoDate].
  static String toIsoDate(DateTime date) => formatIsoDate(date);

  /// Checks if [birthDate] represents an age within [minAge] and [maxAge].
  static bool isValidAge(DateTime? birthDate, [DateTime? referenceDate]) =>
      validateBirthDate(birthDate, referenceDate) == null;

  /// Formats a [DateTime] to Indonesian string representation, e.g. "17 Mei 1998".
  static String formatIndonesian(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final m = date.month >= 1 && date.month <= 12 ? months[date.month - 1] : '';
    return '${date.day} $m ${date.year}';
  }

  /// Parses an ISO date string `YYYY-MM-DD` or returns `null` if invalid.
  static DateTime? parseIsoDate(String? isoDate) {
    if (isoDate == null || isoDate.trim().isEmpty) return null;
    try {
      final parts = isoDate.trim().split('-');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }
}
