# Laporan Implementasi Password Recovery & Remember Me — NutriView

Dokumentasi audit, keputusan arsitektur, dan implementasi fitur **Lupa Password** dan **Ingat Saya (Remember Me)** pada aplikasi NutriView.

---

## 1. Skill Discovery & Execution Matrix

| Skill | Status | Penggunaan Aktual | Bukti |
|---|---|---|---|
| **Ponytail** | USED | Minimal diff, re-use komponen existing (`NeoInput`, `NeoButton`, `NeoCard`, `ApiClient`, `FlutterSecureStorage`), zero over-engineering, zero fake OTP. | Perubahan terpusat pada file existing tanpa dependensi baru. |
| **Flutter Architecture** | USED | MVVM layered structure: View di `login_screen.dart` & `forgot_password_modal.dart`, State di `auth_provider.dart`, Data di `auth_repository.dart` & `api_client.dart`. | Tidak ada business logic di View; isolasi layer terjaga. |
| **Dart Static Analysis** | USED | Menjalankan `flutter analyze` dengan standar strict typing dan zero warning. | Hasil `flutter analyze`: **No issues found!** |
| **Flutter Widget Testing** | USED | Pengujian interaksi widget Lupa Password, dialog modal pemulihan, validasi email, loading state, dan interaksi checkbox Remember Me. | `frontend/test/auth_recovery_widget_test.dart`. |
| **Dart Unit Testing** | USED | Pengujian method `sendPasswordResetEmail`, anti-account enumeration, penanganan error rate-limit/network, dan siklus persistensi Remember Me saat startup. | `frontend/test/auth_recovery_test.dart`. |
| **Pre-launch Checklist** | USED | Verifikasi keamanan: tidak ada secret/password tersimpan lokal, token reset tidak disimpan di Firestore, anti-enumerasi akun aktif. | Audit kode, secure storage preference, Firebase Auth official API. |

---

## 2. Arsitektur Autentikasi Existing & Titik Integrasi

```text
LoginScreen (NeoInput, NeoButton, Checkbox 'Ingat Saya', Link 'Lupa Password?')
  ├── Lupa Password -> ForgotPasswordModal.show()
  │     └── AuthProvider.sendPasswordResetEmail()
  │           └── AuthRepository.sendPasswordResetEmail()
  │                 └── FirebaseAuth.instance.sendPasswordResetEmail()
  │                       └── [Anti-Enumerasi Akun] jika 'user-not-found', tetap tampilkan pesan konfirmasi aman
  │
  └── Submit Login (Email/Password atau Google) + rememberMe boolean
        └── AuthProvider.login(..., rememberMe) / loginWithGoogle(..., rememberMe)
              └── AuthRepository.login(..., rememberMe)
                    ├── FirebaseAuth.signInWith...
                    ├── Firestore users/{uid} fetch/init
                    └── ApiClient.saveRememberMe(rememberMe)
                          └── FlutterSecureStorage (key: 'nutriview_remember_me')

SplashScreen (Startup Cold-Launch)
  └── AuthProvider.checkAuthStatus()
        ├── ApiClient.isRememberMeEnabled()
        │     ├── TRUE: Lanjutkan validasi auth status via Firebase & SecureStorage (auto-login ke Dashboard)
        │     └── FALSE: Sesi ephemeral terdeteksi! Panggil AuthRepository.logout() dan arahkan ke LoginScreen
```

---

## 3. Keputusan Keamanan & Desain Teknis

### A. Fitur Lupa Password
1. **Official Firebase Action Link, Zero Fake OTP**:
   Firebase Authentication mengirimkan tautan tindakan terverifikasi kriptografis ke email pengguna. NutriView tidak menggunakan kode OTP 6-digit palsu atau buatan sendiri tanpa backend server tepercaya ber-rate-limit.
2. **Pertahanan Anti-Account Enumeration**:
   Jika Firebase mengembalikan kode `user-not-found`, sistem tidak membocorkan ke UI bahwa email tidak terdaftar. Sebagai gantinya, sistem menampilkan pesan aman:
   *"Jika email tersebut terhubung dengan akun yang valid, instruksi pemulihan telah dikirim. Silakan periksa kotak masuk dan folder spam Anda."*
3. **Pencegahan Double-Submit & State Integrity**:
   Tombol dinonaktifkan dan menampilkan spinner saat pengiriman request berlangsung.

### B. Fitur Ingat Saya (Remember Me)
1. **Perilaku Nyata & Terverifikasi (Bukan Sekadar Dummy UI)**:
   - **Ingat Saya Aktif (Default)**: Sesi disimpan secara persisten. Ketika aplikasi ditutup dan dibuka kembali, startup splash screen memulihkan sesi dan langsung mengarahkan pengguna ke Dashboard.
   - **Ingat Saya Nonaktif**: Sesi bersifat *ephemeral*. Pengguna tetap dapat memakai aplikasi selama aplikasi masih berjalan. Namun ketika aplikasi mengalami cold-start restart, `checkAuthStatus()` mendeteksi `rememberMe == false`, menghapus token lokal dan sesi Firebase, lalu mengarahkan pengguna kembali ke halaman Login.
2. **Zero Plaintext Password**:
   Kata sandi tidak pernah disimpan di disk mau pun di `FlutterSecureStorage`. Hanya preferensi boolean `nutriview_remember_me` yang disimpan.

---

## 4. File Modification Registry

| File | Peran & Modifikasi |
|---|---|
| `lib/data/api_client.dart` | Menambahkan key `nutriview_remember_me`, method `saveRememberMe(bool enabled)`, dan `isRememberMeEnabled()` (default: `true`). |
| `lib/data/repositories/auth_repository.dart` | Menambahkan `sendPasswordResetEmail(email)` dengan validasi, official Firebase action link, penanganan anti-enumerasi (`user-not-found`), rate-limiting (`too-many-requests`), serta delegasi `isRememberMeEnabled()` dan `setRememberMe(enabled)`. Memperbarui `login` dan `loginWithGoogle` untuk menerima `rememberMe`. |
| `lib/features/auth/providers/auth_provider.dart` | Menambahkan state `_isResetPasswordLoading`, method `sendPasswordResetEmail(email)`, memperbarui `login` & `loginWithGoogle` dengan parameter `rememberMe`, serta memperbarui `checkAuthStatus()` untuk memeriksa `rememberMe` saat startup cold-launch. |
| `lib/features/auth/widgets/forgot_password_modal.dart` | Komponen Modal Bottom Sheet Neo-Brutalist responsif: input email dengan validasi realtime, feedback error banner, feedback sukses anti-enumerasi akun, dan integrasi penuh dengan `AuthProvider`. |
| `lib/features/auth/screens/login_screen.dart` | Menambahkan checkbox Neo-Brutalist kustom `Key('remember_me_checkbox')` (menggunakan `CustomPaint` tanpa melanggar batasan ikon), link `Key('forgot_password_link')`, serta meneruskan status `rememberMe` ke flow login email/password dan Google. |
| `test/auth_recovery_test.dart` | 13 Unit Tests mencakup validasi email, anti-enumerasi akun, penanganan exception, delegasi storage, serta pembersihan sesi ephemeral saat cold start. |
| `test/auth_recovery_widget_test.dart` | 8 Widget Tests menguji interaksi UI checkbox Remember Me, pembukaan modal Lupa Password, validasi form, visual loading, feedback sukses, dan dismiss modal. |
| `test/google_sign_in_test.dart` & `test/google_sign_in_widget_test.dart` | Diperbarui untuk mendukung parameter `rememberMe` dan memastikan kontinuitas pengujian suite login Google. |

---

## 5. Hasil Verifikasi & Pengujian

### A. Analisis Statis (Dart & Flutter Analyze)
```bash
flutter analyze
```
**Hasil**: `No issues found!` (0 error, 0 warning).

### B. Hasil Eksekusi Test Suite
1. **Unit Tests (`test/auth_recovery_test.dart`)**:
   - `sendPasswordResetEmail` empty/invalid validation: **PASSED**
   - `sendPasswordResetEmail` valid email execution: **PASSED**
   - Anti-account enumeration (`user-not-found` swallowed): **PASSED**
   - Rate limit handling (`too-many-requests` -> `RATE_LIMIT_EXCEEDED`): **PASSED**
   - Network failure handling (`network-request-failed` -> `NETWORK_ERROR`): **PASSED**
   - Invalid email code handling (`invalid-email` -> `INVALID_EMAIL`): **PASSED**
   - Delegation `isRememberMeEnabled` & `setRememberMe`: **PASSED**
   - `AuthProvider.sendPasswordResetEmail` loading and error states: **PASSED**
   - Cold-start session preservation when `rememberMe: true`: **PASSED**
   - Cold-start session purge when `rememberMe: false`: **PASSED**
   *Total*: **13 passed**.

2. **Widget Tests (`test/auth_recovery_widget_test.dart`)**:
   - Render `Remember Me` checkbox & `Lupa Password?` link: **PASSED**
   - Toggle state interaktif checkbox: **PASSED**
   - Link membuka `ForgotPasswordModal`: **PASSED**
   - Validasi email kosong pada modal: **PASSED**
   - Validasi format email pada modal: **PASSED**
   - Pengiriman sukses menampilkan banner konfirmasi aman: **PASSED**
   - Banner error saat gagal request: **PASSED**
   - Tombol tutup dismiss modal: **PASSED**
   *Total*: **8 passed**.

3. **Uji Kompatibilitas Desain & Ikon (`test/design_system_standards_test.dart` & `test/login_register_icon_test.dart`)**:
   - 100% kepatuhan terhadap standar `AppIcons` dan Material Rounded.
   - Pemanfaatan `CustomPaint` pada checkbox memastikan nol ikon liar tak terdaftar.
   *Total*: **15 passed**.

4. **Uji Regresi Autentikasi Google (`test/google_sign_in_test.dart` & `test/google_sign_in_widget_test.dart`)**:
   - 100% kompatibel dengan login Google yang mewarisi preferensi Remember Me.
   *Total*: **18 passed**.

---

## 6. Panduan Konfigurasi Konsol Firebase & Produksi

1. **Firebase Console > Authentication > Templates > Password reset**:
   - Sesuaikan pengirim (Sender name & reply-to email, misalnya `NutriView Support <support@nutriview.id>`).
   - Kustomisasi pesan email dalam Bahasa Indonesia dengan teks yang ramah pengguna.
   - Pastikan tautan action URL menggunakan domain resmi / custom domain yang telah terverifikasi.
2. **Firebase Console > Authentication > Settings > Authorized domains**:
   - Daftarkan domain aplikasi NutriView (misalnya `auth.nutriview.id`).
3. **App Check & Rate Limiting**:
   - Firebase Authentication secara otomatis memberlakukan rate limiting berbasis IP dan akun untuk mencegah spam abuse pada `sendPasswordResetEmail`.
   - Kode aplikasi telah menangani exception `too-many-requests` secara elegan dengan pesan bahasa Indonesia: *"Terlalu banyak permintaan pemulihan kata sandi. Silakan tunggu beberapa saat sebelum mencoba kembali."*
