class AppConfig {
  static const String appName = 'NutriView';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const String disclaimerText =
      'Hasil analisis aplikasi bersifat estimasi dan bukan saran medis. '
      'Konsultasikan dengan dokter atau ahli gizi untuk kebutuhan gizi khusus.';
}
