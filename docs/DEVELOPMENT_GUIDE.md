# NutriView — Panduan Pengembangan & Standar Rekayasa

Dokumen ini memuat panduan komprehensif bagi developer mengenai konvensi kode, arsitektur perangkat lunak, sistem desain antarmuka, serta penanganan error pada aplikasi **NutriView**.

---

## 1. Konvensi & Standar Kode Dart

NutriView mengikuti pedoman resmi [*Effective Dart*](https://dart.dev/effective-dart) yang ditegakkan secara otomatis melalui linter `flutter_lints`:

1. **Penamaan Berkas & Simbol**:
   - Berkas: `snake_case.dart` (contoh: `nutrition_calculator.dart`, `dashboard_screen.dart`).
   - Kelas, Enum, & Typedef: `PascalCase` (contoh: `FoodRepository`, `DailyTarget`, `AppRoutes`).
   - Variabel, Parameter, & Method: `camelCase` (contoh: `calculateDailyTarget`, `portionGrams`).
   - Konstanta Global & Token: `camelCase` atau `SCREAMING_SNAKE_CASE` untuk konfigurasi lingkungan statis.
2. **Immutability & Stateless Preference**:
   - Seluruh model data (DTO) bersifat `immutable` dengan anotasi `@immutable`, menggunakan field `final`, dan menyertakan konstruktor `const` bilamana memungkinkan.
   - Gunakan `StatelessWidget` sebagai pilihan utama. Gunakan `StatefulWidget` hanya jika widget mengelola status transien lokal (misal: pengontrol animasi teks atau tab internal).
3. **Penyusunan Kode Terstruktur**:
   - Urutan komponen dalam berkas kelas:
     1. Deklarasi field statis / konstanta.
     2. Deklarasi field instance `final`.
     3. Konstruktor (`const` diutamakan).
     4. Getters / Setters.
     5. Public methods.
     6. Private helper methods.

---

## 2. Penerapan Prinsip SOLID & OOP

Arsitektur NutriView menerapkan kelima prinsip SOLID secara konsisten:

| Prinsip | Implementasi Aktual pada NutriView |
|---|---|
| **Single Responsibility Principle (SRP)** | - `NutritionCalculator`: Hanya berisi komputasi matematis BMR, TDEE, makronutrien, dan Atwater.<br>- `YoloDetector`: Hanya mengelola siklus hidup model dan inferensi TFLite.<br>- `ApiClient`: Hanya bertanggung jawab atas persistensi token dan preferensi sesi pada secure storage. |
| **Open/Closed Principle (OCP)** | - `AvatarCatalog`: Penambahan karakter avatar baru dilakukan dengan menambahkan entri objek `GameAvatarCharacter` ke dalam daftar tanpa perlu mengubah widget modal seleksi (`AvatarSelectionModal`) atau layar profil. |
| **Liskov Substitution Principle (LSP)** | - Seluruh repositori menerima klien dan database melalui antarmuka atau parameter opsional yang dapat digantikan sepenuhnya oleh objek tiruan (*test doubles/mocks*) tanpa merusak kontrak kode. |
| **Interface Segregation Principle (ISP)** | - `BiometricService` memisahkan fungsi pengecekan perangkat keras (`isAvailable`), query jenis sensor (`getAvailableBiometrics`), dan autentikasi (`authenticate`) secara atomik. |
| **Dependency Inversion Principle (DIP)** | - Kelas lapisan atas (Providers dan Screens) tidak bergantung pada instansiasi konkret SDK cloud secara langsung, melainkan bergantung pada repositori yang disuntikkan via `Provider` di `main.dart`. |

---

## 3. Manajemen Status (State Management via Provider)

Aplikasi menggunakan paket resmi `provider` (v6.1.2) dengan pemisahan peran yang tegas:

```text
┌────────────────────────────────────────────────────────┐
│                        main.dart                       │
│  MultiProvider: Registrasi Repositori & ViewModels     │
└──────────┬──────────────────────────────────┬──────────┘
           │ Inject Repositories             │ Expose ChangeNotifier
           ▼                                  ▼
┌──────────────────────┐           ┌──────────────────────┐
│  Repositories Layer  │           │   ChangeNotifier     │
│  (Auth, Meal, Food)  │           │   Providers Layer    │
└──────────────────────┘           └──────────┬───────────┘
                                              │ context.watch() / select()
                                              ▼
                                   ┌──────────────────────┐
                                   │  Presentation Layer  │
                                   │  (Consumer Widgets)  │
                                   └──────────────────────┘
```

### Praktik Terbaik Konsumsi State:
1. **Hindari `context.watch()` di Root Widget Build**:
   Gunakan `context.select<T, R>()` atau bungkus widget dengan `Consumer<T>` tepat pada elemen antarmuka yang memerlukan render ulang. Hal ini mencegah *re-render* seluruh halaman saat hanya satu nilai kecil yang berubah.
2. **Gunakan `context.read()` untuk Eksekusi Aksi**:
   Pada fungsi *callback* tombol atau event handler (`onPressed`, `onTap`), gunakan `context.read<AuthProvider>().login(...)`. Jangan menggunakan `watch` di dalam event handler.
3. **Invalidasi Cache Saat Logout**:
   `AuthProvider.onLogout` mengikat aksi invalidasi cache pada `DashboardRepository`, `FoodRepository`, dan `ArticleRepository` untuk menjamin tidak ada kebocoran data antar-sesi pengguna.

---

## 4. Sistem Desain Antarmuka: Overkill Neo-Brutalism

NutriView menggunakan bahasa visual **Overkill Neo-Brutalism** yang khas, energik, dan kontras tinggi:

### 4.1. Token Desain (`neo_tokens.dart`)
- **Warna Aksen**:
  - `NeoTokens.vividYellow` (`0xFFFFDE59`): Kalori harian & aksen utama hero.
  - `NeoTokens.mintGreen` (`0xFF2EE6A8`): Protein & indikator sukses/terpenuhi.
  - `NeoTokens.skyBlue` (`0xFF45B6FE`): Karbohidrat & elemen informatif.
  - `NeoTokens.coralRed` (`0xFFFF5757`): Lemak & peringatan batas/error.
  - `NeoTokens.creamBg` (`0xFFF9F6EE`): Warna kanvas latar belakang aplikasi.
- **Garis Batas (Border)**:
  - Ketebalan tegas: `borderWidth: 2.0` (komponen standar) atau `3.0` (komponen hero/modal).
  - Warna: Wajib hitam pekat `NeoTokens.black` (`0xFF111111`).
- **Bayangan Pejal (Drop Shadow)**:
  - Wajib menggunakan bayangan pejal tanpa blur (*hard solid shadow*):
    ```dart
    boxShadow: [
      BoxShadow(
        color: NeoTokens.black,
        offset: Offset(4, 4),
        blurRadius: 0, // Dilarang menggunakan blur radius!
      ),
    ]
    ```

### 4.2. Katalog Karakter Avatar Vektor (`AvatarCatalog`)
NutriView tidak meminta unggahan foto profil dari kamera untuk menjaga efisiensi penyimpanan dan privasi pengguna. Sebagai gantinya, aplikasi menyertakan karakter avatar game yang digambar menggunakan `CustomPainter` Flutter:
- `chef_pro` ("Master Koki" — Ahli Kuliner Sehat)
- `runner_ace` ("Pelari Tangguh" — Atlet Kebugaran)
- `cyber_gamer` ("Cyber Hero" — Pecinta Teknologi)
- dan karakter lainnya.

---

## 5. Hierarki Penanganan Kesalahan (Error Handling)

NutriView menerapkan sistem penanganan error terpusat yang ramah pengguna tanpa mengekspos detail teknis yang membingungkan:

```dart
class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final Map<String, dynamic>? details;
  ...
}
```

### Kode Error Terstandar:
- `UNAUTHORIZED`: Pengguna belum login atau token sesi kedaluwarsa (otomatis diarahkan ke layar Login).
- `ACCOUNT_DEACTIVATED`: Akun dinonaktifkan oleh administrator.
- `EMAIL_ALREADY_REGISTERED`: Email pendaftaran sudah digunakan.
- `FOOD_NOT_FOUND` / `MEAL_NOT_FOUND`: Data yang diminta tidak tersedia di basis data.
- `VALIDATION_ERROR`: Validasi formulir gagal (misal: password kurang dari 8 karakter).
- `FIREBASE_NOT_INITIALIZED`: Kesalahan internal inisialisasi cloud.

Seluruh pesan kesalahan ditampilkan kepada pengguna menggunakan `NeoSnackbar` yang memiliki batas hitam tebal dan ikon semantik yang jelas.

---

## 6. Konfigurasi Profil Kreator (`creator_config.dart`)

Informasi pengembang aplikasi dikelola secara terpusat pada `frontend/lib/core/config/creator_config.dart`:
- Memungkinkan pembaruan data biografi, media sosial (GitHub, LinkedIn, Instagram), dan versi rilis aplikasi tanpa mengubah tata letak UI pada `AboutScreen`.
- Menyediakan tautan portofolio profesional pengembang:
  - Nama: **Ahmad Badawi**
  - Peran: Pembuat & Pengembang NutriView
  - Domain: Web · AI · Mobile
  - Repositori: `https://github.com/ahmadbadawiTzy`
