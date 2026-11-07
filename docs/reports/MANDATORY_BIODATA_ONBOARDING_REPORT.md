# LAPORAN TEKNIS KOMPREHENSIF — SISTEM MANDATORY BIODATA ONBOARDING & AUTHENTICATION FLOW NUTRIVIEW

**Project:** NutriView — Personal Nutrition & Calorie Tracking Mobile Application  
**Platform:** Flutter / Dart (Android, iOS)  
**Security & Database:** Firebase Authentication, Cloud Firestore, Supabase Storage  
**Tanggal:** 7 November 2026  
**Status:** **SELESAI, TERVERIFIKASI & PRODUCTION-READY**  

---

## 1. Executive Summary

Sistem **Mandatory Biodata Onboarding** telah berhasil diimplementasikan secara menyeluruh di aplikasi NutriView. Sistem ini memastikan bahwa **setiap pengguna baru**, baik yang mendaftar melalui Email/Password Register maupun Google Sign-In, **WAJIB** menyelesaikan pengisian biodata fisik (Nama Lengkap, Jenis Kelamin, Tanggal Lahir / Usia, Tinggi Badan, Berat Badan, Tingkat Aktivitas Fisik, dan Target Kesehatan) sebelum diizinkan mengakses fitur-fitur utama aplikasi (Dashboard, AI Scanner, Riwayat Makan, Detail Makan, Artikel, dan Profil).

Implementasi dilakukan secara *defense-in-depth* (pertahanan berlapis) pada layer Model, Database, Repository, Provider, Routing, UI/UX, dan Security Rules, sehingga tidak ada celah bagi pengguna untuk melewati (*skip/bypass*) pengisian biodata, baik melalui tombol back perangkat keras, gesture navigation, direct route navigation, maupun session restoration saat aplikasi di-restart.

---

## 2. Arsitektur Data & Firestore Modeling

### A. Struktur Dokumen Firestore (`users/{userId}`)

Dokumen pengguna di Cloud Firestore disimpan dengan path multi-tenant terisolasi:
`users/{uid}`

Field yang dikelola:
```json
{
  "email": "user@example.com",
  "full_name": "Ahmad Badawi",
  "role": "user",
  "is_active": true,
  "is_profile_complete": false,
  "profile": {
    "age": 25,
    "birth_date": "2001-05-14T00:00:00.000Z",
    "sex": "male",
    "height_cm": 175.0,
    "weight_kg": 70.0,
    "activity_level": "moderate",
    "goal": "maintain_weight",
    "profession": "Umum"
  },
  "created_at": "2026-11-07T12:00:00.000Z",
  "updated_at": "2026-11-07T12:05:00.000Z"
}
```

### B. Aturan Penentuan Status Kelengkapan (`is_profile_complete`)

1. **Pengguna Baru (Email/Password Register):**
   * Saat registrasi di `AuthRepository.register()`, dokumen pengguna dibuat dengan default `'is_profile_complete': false`.
   * Model `User` yang dikembalikan ke UI memiliki `isProfileComplete: false`.
2. **Pengguna Baru (Google Sign-In Pertama Kali):**
   * Di `AuthRepository.loginWithGoogle()`, jika dokumen `users/{uid}` belum ada di Firestore, dokumen diinisialisasi dengan `'is_profile_complete': false`.
3. **Pengguna Lama (Returning User):**
   * Data diekstrak langsung dari Firestore.
   * Dilengkapi *backward-compatibility fallback*: jika dokumen lama belum memiliki key `'is_profile_complete'`, status dihitung secara otomatis berdasarkan ambang batas fisik:
     $$\text{isComplete} = (\text{heightCm} \ge 50) \land (\text{weightKg} \ge 20) \land (\text{birthDate} \ne \text{null} \lor \text{age} > 0) \land (\text{sex} \ne \text{""}) \land (\text{activityLevel} \ne \text{""})$$
4. **Pembaruan Biodata Berhasil:**
   * Method `ProfileRepository.saveBiodata()` dan `updateProfile()` menyimpan `'is_profile_complete': true` dan memperbarui `updated_at`.
   * Jika pengguna menghapus biodata (`deleteBiodata()`), flag diperbarui menjadi `false`.

### C. Keamanan Cloud Firestore (`firestore.rules`)

Aturan keamanan di `firestore.rules` telah diaudit dan divalidasi dengan `firebase deploy --only firestore:rules --dry-run`:
* Hanya pengguna terautentikasi dengan `request.auth.uid == userId` yang dapat membaca atau memperbarui dokumen profil mereka.
* Dilarang keras melakukan manipulasi role pengguna antar-akun.
* Isolasi multi-tenant terjamin penuh.

---

## 3. Arsitektur Pertahanan Berlapis (6-Layer Guard Architecture)

Untuk mencegah pengguna mengakses fitur inti tanpa mengisi biodata, sistem menerapkan 6 lapisan proteksi:

```
[ Pengguna Masuk / Buka Aplikasi ]
               │
               ▼
┌──────────────────────────────────────────────┐
│ Lapisan 1: Session Restoration (SplashScreen)│
│ - Cek apakah pengguna terautentikasi         │
│ - Load Profile & sinkronisasi isProfileComplete
│ - Jika !isProfileComplete -> /complete-profile
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│ Lapisan 2: Post-Login Route Selector          │
│ - Login via Email/Password & PasswordFallback│
│ - Admin -> /admin-dashboard                  │
│ - Non-admin incomplete -> /complete-profile  │
│ - Non-admin complete -> /dashboard           │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│ Lapisan 3: Post-Google-Login Route Selector  │
│ - Identifikasi akun Google baru vs lama      │
│ - Akun baru -> /complete-profile             │
│ - Akun lama lengkap -> /dashboard            │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│ Lapisan 4: Registration Redirect Direct     │
│ - RegisterScreen sukses -> /complete-profile │
│   (tidak lagi ke /profile atau /dashboard)   │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│ Lapisan 5: Global Route Guard (main.dart)    │
│ - onGenerateRoute mencegat rute-rute inti:    │
│   /dashboard, /scanner, /detection-confirm,  │
│   /portion-input, /meal-result, /meals,      │
│   /meal-detail, /articles, /profile          │
│ - Jika auth.isLoggedIn && !auth.isAdmin &&   │
│   !auth.isProfileComplete -> redirect paksa  │
│   ke CompleteProfileScreen                   │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│ Lapisan 6: Hardware/Gesture Back Lock (UI)   │
│ - PopScope(canPop: false) di CompleteProfile │
│ - Blokir tombol Back & gesture Android/iOS   │
│ - Modal konfirmasi jika ingin Ganti Akun/Keluar
└──────────────────────────────────────────────┘
```

---

## 4. Desain UI/UX CompleteProfileScreen (Controlled Neo-Brutalism)

Layar **CompleteProfileScreen** (`frontend/lib/features/auth/screens/complete_profile_screen.dart`) dirancang khusus dengan standar ketat:

1. **Neo-Brutalism Editorial Identity:**
   * Border solid 2.0px `NeoTokens.black`.
   * Hard offset shadows `Offset(3, 3)` dan `Offset(2, 2)` tanpa blur radius.
   * Palet vibrant: `warmBackground` (`#FBF9F4`), `paper` (`#FFFFFF`), `lime` (`#CCFF00`), `hazard` (`#FFD600`), `recess` (`#F0ECE1`), `alert` (`#EF4444`).
2. **Zero Emoji & Single Icon Family:**
   * 100% menggunakan `AppIcons.*` dari Material Rounded (`Icons.*_rounded`).
   * Bebas dari karakter emoji apapun.
   * Lolos pengujian otomatis `test/design_system_standards_test.dart`.
3. **Form Biodata Lengkap:**
   * **Nama Lengkap:** Pre-filled dari Google/Firebase Auth jika tersedia.
   * **Jenis Kelamin:** Segmented tactile chips (Laki-laki & Perempuan) dengan icon `AppIcons.person` dan `AppIcons.face`.
   * **Tanggal Lahir:** Native styled DatePicker dengan live calculation usia dalam badge `hazard` (misal: "Usia: 25 thn"). Validasi umur 5 - 120 tahun.
   * **Tinggi Badan:** Input desimal cm (range validasi 100 - 250 cm).
   * **Berat Badan:** Input desimal kg (range validasi 30 - 300 kg).
   * **Tingkat Aktivitas Fisik:** 4-tier interactive radio cards (Sedentari, Ringan, Sedang, Aktif).
   * **Target Gizi & Berat Badan:** 3 opsi (Menurunkan BB, Mempertahankan BB, Menambah BB).
4. **Educational Rationale & Anti-Trap UX:**
   * Menampilkan kartu penjelasan ramah pengguna mengapa NutriView memerlukan data fisik untuk formula Harris-Benedict / Mifflin-St Jeor (BMR & TDEE).
   * Tidak ada tombol "Lewati" atau "Nanti".
   * Menyediakan tombol *"Ganti Akun / Keluar"* di bawah form yang membuka dialog konfirmasi logout, sehingga pengguna yang ingin mengganti email tidak terjebak (*trapped*).
5. **Keyboard & Responsive Safety:**
   * Menggunakan `SingleChildScrollView` dengan dynamic bottom padding `viewInsets.bottom`.
   * Keyboard dismiss on drag.
   * Bebas dari RenderFlex overflow di layar sempit 320dp hingga 430dp.

---

## 5. Ringkasan File yang Diubah & Dibuat

| File | Status | Perubahan Utama |
| :--- | :--- | :--- |
| `frontend/lib/core/routes.dart` | Diperbarui | Menambahkan rute konstanta `AppRoutes.completeProfile = '/complete-profile'`. |
| `frontend/lib/data/models/user.dart` | Diperbarui | Menambahkan `final bool isProfileComplete`, getter `hasCompleteProfile`, serialisasi JSON & copyWith fallback. |
| `frontend/lib/data/repositories/auth_repository.dart` | Diperbarui | Menambahkan helper `_extractProfileComplete()`, inisialisasi `is_profile_complete: false` pada register & first-time Google, preservasi data pada returning user & biometric. |
| `frontend/lib/data/repositories/profile_repository.dart` | Diperbarui | `saveBiodata()` & `updateProfile()` menyimpan `'is_profile_complete': true`; `deleteBiodata()` memperbarui flag ke `false`. |
| `frontend/lib/features/auth/providers/auth_provider.dart` | Diperbarui | Menambahkan getter `isProfileComplete`, method `updateProfile(UserProfile)`, dan `setCurrentUser(User)`. |
| `frontend/lib/features/profile/providers/profile_provider.dart` | Diperbarui | Menambahkan evaluasi kelengkapan profil fisik `isProfileComplete`. |
| `frontend/lib/features/auth/screens/complete_profile_screen.dart` | **Dibuat Baru** | Layar onboarding wajib Neo-Brutalism dengan form lengkap, `PopScope(canPop: false)`, logout fallback, prefilling, dan integrasi target harian. |
| `frontend/lib/features/auth/screens/register_screen.dart` | Diperbarui | Redirect post-register diarahkan langsung ke `AppRoutes.completeProfile`. |
| `frontend/lib/features/auth/screens/login_screen.dart` | Diperbarui | `_routePostLogin` memeriksa `isProfileComplete`; jika `false` diarahkan ke `AppRoutes.completeProfile`. |
| `frontend/lib/features/splash/screens/splash_screen.dart` | Diperbarui | Session restoration memuat profil fisik dan merutekan pengguna incomplete ke `AppRoutes.completeProfile`. |
| `frontend/lib/main.dart` | Diperbarui | Registrasi rute `AppRoutes.completeProfile` dan pemasangan Global Route Guard di `onGenerateRoute`. |
| `firestore.rules` | Diverifikasi | Security rules divalidasi dengan dry-run Firebase CLI. |
| `frontend/test/mandatory_biodata_flow_test.dart` | **Dibuat Baru** | Test suite otomatis komprehensif menguji 13 skenario onboarding, route guard, validasi form, dan model serialization. |

---

## 6. Bukti Verifikasi & Pengujian Otomatis

### A. Static Code Analysis (`flutter analyze`)
```bash
$ flutter analyze
Analyzing frontend...
No issues found! (ran in 4.7s)
```
**Hasil:** 0 warning, 0 error, 0 hint.

### B. Unit & Widget Test Suites
1. **`test/mandatory_biodata_flow_test.dart`:** 13/13 Passed (100%)
   * User model serialization & computation fallback.
   * ProfileProvider physical threshold evaluation.
   * Global Route Guard access interception pada Dashboard & Scanner.
   * Access permission bagi Admin dan user lengkap.
   * CompleteProfileScreen render, back navigation lock, input validator, dan submit flow.
2. **`test/splash_screen_test.dart`:** 7/7 Passed (100%)
   * Session restoration rute ke CompleteProfile vs Dashboard vs Login.
3. **`test/google_sign_in_widget_test.dart` & `google_sign_in_test.dart`:** 19/19 Passed (100%)
   * Google Sign-in akun baru diarahkan ke CompleteProfile; akun lama lengkap ke Dashboard.
4. **`test/register_screen_redesign_test.dart`:** 11/11 Passed (100%)
   * Registrasi baru berhasil langsung diarahkan ke CompleteProfile.
5. **`test/biometric_widget_test.dart`:** 13/13 Passed (100%)
   * Login biometrik dan password fallback sinkron dengan status kelengkapan profil.
6. **`test/design_system_standards_test.dart`:** 7/7 Passed (100%)
   * Standar Neo-Brutalism, Single Icon Family (`AppIcons`), Zero Emoji.

---

## 7. Kepatuhan Kebijakan Google Play Store

Implementasi ini mendukung penuh kesiapan publikasi NutriView di Google Play Store:
1. **Google Play Health Apps Policy:**
   * Aplikasi tidak membuat klaim medis berbahaya (*non-diagnostic, non-clinical wellness tracker*).
   * Edukasi transparan di layar `CompleteProfileScreen` menjelaskan data fisik digunakan murni untuk estimasi BMR & TDEE berbasis gizi umum.
2. **Data Safety & Privacy:**
   * Seluruh data tersimpan aman di Cloud Firestore terisolasi per-UID.
   * Pengguna memiliki hak penghapusan akun (*Account Deletion*) yang membersihkan seluruh biodata, catatan makan, dan file storage secara permanen.

---

## 8. Kesimpulan

Seluruh instruksi pada master prompt telah diimplementasikan dengan standar tertinggi rekayasa perangkat lunak mobile. Sistem **Mandatory Biodata Onboarding** NutriView saat ini kokoh, aman, bebas celah *bypass*, konsisten dengan identitas Controlled Neo-Brutalism, dan telah terverifikasi secara menyeluruh melalui test suite otomatis.
