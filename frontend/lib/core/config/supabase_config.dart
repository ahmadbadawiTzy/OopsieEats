/// Central configuration for Supabase Storage integration in NutriView.
///
/// Supabase is used EXCLUSIVELY for binary image storage in the private bucket
/// `food-history-images`. Firebase Firestore remains the primary database,
/// and Firebase Auth remains the primary identity provider.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL (configurable via `--dart-define=SUPABASE_URL=...`)
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anonymous publishable key (configurable via `--dart-define=SUPABASE_ANON_KEY=...`)
  ///
  /// CRITICAL SECURITY RULE: The secret service_role key must NEVER be placed in client code.
  /// Only the public anon/publishable key is safe for client applications.
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Dedicated private storage bucket for food detection inspection photos
  static const String bucket = 'food-history-images';

  /// Dedicated storage bucket for user profile photos
  static const String profileBucket = String.fromEnvironment(
    'SUPABASE_PROFILE_BUCKET',
    defaultValue: bucket,
  );

  /// Maximum allowed file size for image uploads (5 MB)
  static const int maxUploadSizeBytes = 5 * 1024 * 1024;

  /// Default validity period for generated signed URLs (1 hour)
  static const Duration signedUrlTtl = Duration(hours: 1);

  /// Target dimension for image preprocessing (max width/height)
  static const int maxImageDimension = 1024;

  /// JPEG compression quality (0-100)
  static const int jpegQuality = 80;

  /// Returns true if valid Supabase project credentials are provided.
  static bool get isConfigured =>
      url.isNotEmpty &&
      !url.contains('placeholder') &&
      anonKey.isNotEmpty &&
      !anonKey.contains('placeholder');
}
