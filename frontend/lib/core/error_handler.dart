class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final List<dynamic>? details;

  ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => message;

  String get friendlyMessage {
    switch (code) {
      case 'INVALID_CREDENTIALS':
        return 'Email atau kata sandi yang Anda masukkan salah.';
      case 'EMAIL_ALREADY_REGISTERED':
        return 'Email sudah terdaftar. Silakan gunakan email lain atau login.';
      case 'PROFILE_INCOMPLETE':
        return 'Profil Anda belum lengkap. Silakan lengkapi profil terlebih dahulu.';
      case 'MODEL_UNAVAILABLE':
        return 'Layanan deteksi makanan saat ini belum siap di server. Anda dapat mencatat makanan secara manual.';
      case 'FOOD_NOT_FOUND':
        return 'Makanan yang dipilih tidak ditemukan.';
      case 'FILE_TOO_LARGE':
        return 'Ukuran foto melebihi batas 5 MB. Silakan gunakan foto lain.';
      case 'UNSUPPORTED_IMAGE_TYPE':
        return 'Format file tidak didukung. Harap gunakan gambar JPEG, PNG, atau WebP.';
      case 'INVALID_IMAGE':
        return 'Berkas yang diunggah bukan gambar yang valid.';
      case 'TOKEN_EXPIRED':
      case 'TOKEN_REVOKED':
      case 'UNAUTHORIZED':
        return 'Sesi login telah berakhir. Silakan login kembali.';
      case 'VALIDATION_ERROR':
        if (details != null && details!.isNotEmpty) {
          final first = details!.first;
          if (first is Map && first.containsKey('message')) {
            return first['message'].toString();
          }
        }
        return message;
      default:
        return message.isNotEmpty ? message : 'Terjadi kesalahan pada sistem.';
    }
  }
}
