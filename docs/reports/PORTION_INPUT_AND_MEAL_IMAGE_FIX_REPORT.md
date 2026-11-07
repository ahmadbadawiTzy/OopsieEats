# LAPORAN TEKNIS AUDIT & PERBAIKAN: PORTION INPUT BUG & MEAL PHOTO PERSISTENCE NUTRIVIEW

**Proyek:** NutriView — Aplikasi Pelacak Nutrisi & Analisis Makanan Berbasis AI  
**Tanggal:** 7 November 2026  
**Status Audit & Verifikasi:** SELESAI & TERVERIFIKASI  
**Versi Aplikasi:** v1.0.0+1  
**Lingkungan Eksekusi:** Flutter 3.x, Dart 3.x, Firebase Firestore, Supabase Storage (`food-history-images`), On-Device YOLO26n  

---

## 1. Executive Summary

Laporan ini mendokumentasikan investigasi akar masalah (*root cause analysis*), perbaikan arsitektural (*deep code remediation*), dan pengujian otomatis komprehensif terhadap dua *defect* kritikal yang dilaporkan pengguna pada aplikasi NutriView:

1. **Bug 1 (Portion Input Bug):**
   - Nilai awal input gramatur porsi makanan sebelumnya terinisialisasi secara agresif ke `150g`, bukan `0`.
   - Angka `0` sangat sulit diedit dan memicu fenomena "sticky zero" di mana pengguna harus menghapus berulang kali untuk memasukkan angka baru.
   - Tidak ada sanitasi pemisah desimal koma (`,`) menjadi titik (`.`).
   - Nilai input berisiko ter-reset saat widget mengalami *rebuild*.
   - Potensi *RenderFlex overflow* horizontal pada layar sempit (320px) akibat kompresi layout pada baris input dan indikator makronutrisi.
2. **Bug 2 (Meal Photo Persistence Bug):**
   - Foto hasil pemotretan kamera tidak tersimpan atau tidak tampil pada Riwayat Makan (*Meal History*).
   - Ditemukan *silent failure* akibat desinkronisasi `FirebaseAuth.instance.currentUser?.uid` saat sesi dipulihkan dari token/biometrik, menyebabkan proses *upload* Supabase dilewati secara diam-diam.
   - Penanganan eksepsi (*exception swallowing*) pada `submitMeal()` yang menelan *storage error*, sehingga catatan makanan tetap disimpan ke Firestore tanpa metadata foto tanpa memberikan notifikasi kesalahan ke pengguna.
   - Kebocoran *in-memory bytes* pada `ScanFlowProvider.reset()` di mana `_imageFile` dihapus namun `_imageBytes` tertinggal.
   - Desinkronisasi *lifecycle widget* pada `NeoImageThumbnail` dan `NeoImageHeroCard` saat *metadata path* diperbarui.

Seluruh akar masalah telah diperbaiki secara tuntas tanpa menyisakan *technical debt*. Pengujian otomatis (*automated unit and widget tests*) telah dibuat dan diverifikasi berhasil dengan `flutter analyze` 100% bersih tanpa *lint warning*.

---

## 2. Bug 1: Portion Input Bug Analysis & Fix

### 2.1. Root Causes (Akar Masalah)

1. **Mutasi State Agresif pada `initState()`:**
   Pada file [portion_input_screen.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/lib/features/scanner/screens/portion_input_screen.dart), fungsi `initState()` secara agresif meng-override `portionGrams`:
   ```dart
   final portion = items[i].portionGrams ?? 150.0;
   if (items[i].portionGrams == null) items[i].portionGrams = 150.0;
   _controllers[i] = TextEditingController(text: portion.toInt().toString());
   ```
   Hal ini menyebabkan nilai awal porsi makanan selalu tampil sebagai `150`, mengaburkan apakah porsi sudah diverifikasi pengguna atau belum.
2. **Fenomena "Sticky Zero" & Kursor di Belakang Angka 0:**
   Ketika input bernilai `'0'`, pengguna yang menyentuh `TextField` mendapati kursor berada di belakang angka `'0'`. Ketika mengetik `'5'`, string menjadi `'05'`. Karena tidak adanya kustomisasi `TextInputFormatter`, pengguna harus menekan tombol *backspace* terlebih dahulu.
3. **Ketiadaan Normalisasi Koma Desimal:**
   Pada *keyboard* numerik beberapa produsen Android regional Indonesia/Eropa, tombol desimal default adalah koma (`,`). Fungsi `double.tryParse()` bawaan Dart mengembalikan nilai `null` jika string mengandung koma.
4. **Layout Bottleneck pada Form Factor 320px:**
   Card item makanan menempatkan judul makanan dan `TextFormField` berdampingan dalam satu `Row` dengan lebar tetap `SizedBox(width: 100)`. Pada layar 320px (lebar area konten 256px), ruang teks nama makanan terkompresi hingga berisiko memotong teks atau memicu overflow.
5. **Indikator Makronutrisi Tak Terkendali:**
   Pill ringkasan nutrisi (Kalori, Protein, Karbo, Lemak) di dalam card diletakkan dalam `Row(mainAxisAlignment: MainAxisAlignment.spaceAround)` tanpa `Expanded` dan `FittedBox`, memicu *RenderFlex overflow* saat diuji pada layar sempit atau ketika *system font scaling* ditingkatkan.

### 2.2. Implementasi Perbaikan

#### A. Pembuatan `PortionNumberInputFormatter`
Dibuat formatter teks khusus di [portion_input_screen.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/lib/features/scanner/screens/portion_input_screen.dart):
```dart
class PortionNumberInputFormatter extends TextInputFormatter {
  static final RegExp _validPattern = RegExp(r'^\d*([.,]\d*)?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;
    if (newText.isEmpty) return newValue;

    // Normalisasi koma ke titik desimal
    if (newText.contains(',')) {
      newText = newText.replaceAll(',', '.');
    }

    if ('.'.allMatches(newText).length > 1) return oldValue;
    if (!_validPattern.hasMatch(newText)) return oldValue;

    // Otomatis menimpa angka 0 di depan ketika mengetik angka 1-9 (misal "05" -> "5")
    if (newText.length > 1 && newText.startsWith('0') && !newText.startsWith('0.')) {
      newText = newText.replaceFirst(RegExp(r'^0+'), '');
      if (newText.isEmpty) newText = '0';
    }

    // Batasi nilai maksimum porsi realistis 5000g
    final parsed = double.tryParse(newText);
    if (parsed != null && parsed > 5000) return oldValue;

    final selectionOffset = (newText == newValue.text)
        ? newValue.selection.baseOffset
        : newText.length;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selectionOffset.clamp(0, newText.length),
      ),
    );
  }
}
```

#### B. Ergonomi Pemilihan Angka 0 Otomatis (*Auto-Selection on Tap & Focus*)
Ditambahkan listener `FocusNode` dan callback `onTap` pada `TextFormField`:
```dart
onTap: () {
  if (controller.text == '0') {
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
  }
},
```
Ketika pengguna menyentuh field bernilai `'0'`, seluruh teks `'0'` langsung terpilih (*highlighted*). Mengetik tombol numerik apa pun langsung menimpa angka 0 tanpa perlu menekan *backspace*.

#### C. Ketahanan State saat Widget Rebuild (*Rebuild Resilience*)
Metode `_getOrCreateController` dan `_getOrCreateFocusNode` diimplementasikan untuk menjamin `TextEditingController` tidak dibuat ulang secara sembarangan saat *rebuild*, dan nilai yang sedang diketik pengguna tetap persisten:
```dart
TextEditingController _getOrCreateController(int index, double currentGrams) {
  if (!_controllers.containsKey(index)) {
    final text = currentGrams > 0
        ? (currentGrams == currentGrams.roundToDouble()
            ? currentGrams.toInt().toString()
            : currentGrams.toString())
        : '0';
    _controllers[index] = TextEditingController(text: text);
  }
  return _controllers[index]!;
}
```

#### D. Penegasan Aturan Validasi: 0 adalah Nilai Default Tampilan, Bukan Porsi Valid
- Pada saat dibuka pertama kali, field menampilkan `'0'` sebagai indikasi porsi belum diisi.
- Pada saat tombol **Simpan & Catat Makanan** ditekan, validator form dan logic provider menolak porsi bernilai $\le 0$ atau kosong:
  ```dart
  validator: (val) {
    if (val == null || val.trim().isEmpty) return 'Wajib isi';
    final sanitized = val.trim().replaceAll(',', '.');
    final num = double.tryParse(sanitized);
    if (num == null || num <= 0 || num > 5000) return '1-5000g';
    return null;
  }
  ```

#### E. Eliminasi RenderFlex Overflow (Layar 320px)
- Seluruh 4 indikator makronutrisi dibungkus dengan `Expanded(child: FittedBox(fit: BoxFit.scaleDown, child: _buildMacroItem(...)))`.
- Judul makanan dibatasi dengan `maxLines: 2, overflow: TextOverflow.ellipsis`.
- [NeoSectionHeader](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/lib/shared/neo/neo_section_header.dart) dirombak menggunakan `LayoutBuilder` untuk mendeteksi `constraints.maxWidth.isFinite` secara adaptif, sehingga aman digunakan baik di dalam parent berbatas (`Column`/`ListView`) maupun tak berbatas (`Row`).

---

## 3. Bug 2: Camera Meal Photo Persistence Analysis & Fix

### 3.1. Root Causes (Akar Masalah)

1. **Silent User ID Desynchronization pada `submitMeal()`:**
   Di [scan_flow_provider.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/lib/features/scanner/providers/scan_flow_provider.dart), baris pemanggilan `final uid = fb.FirebaseAuth.instance.currentUser?.uid;` gagal mengembalikan UID apabila sesi aplikasi dipulihkan dari *secure token storage* atau *biometric auth* sebelum *state listener* Firebase terinisialisasi penuh. Saat `uid == null`, blok pengunggahan Supabase dilewati secara diam-diam tanpa pesan kesalahan!
2. **Exception Swallowing (Penelanan Eksepsi):**
   Blok pengunggahan Supabase sebelumnya membungkus panggilan dengan `try { ... } catch (storageErr) { uploadedMetadata = null; }`. Jika internet putus atau otorisasi gagal, error ditelan begitu saja dan catatan makanan disimpan ke Firestore tanpa foto. Pengguna mengira fotonya tersimpan, padahal hilang di penyimpanan cloud.
3. **Kebocoran Memori (Zombie Bytes pada Reset):**
   Fungsi `ScanFlowProvider.reset()` hanya mereset `_imageFile = null;`, tetapi tidak membersihkan `_imageBytes = null;`. Byte gambar berukuran besar dari pemotretan sebelumnya tetap mengendap di RAM.
4. **Android Activity Destruction saat Membuka Kamera:**
   Pada perangkat Android dengan spesifikasi memori rendah (*low RAM*), sistem operasi dapat mematikan Activity NutriView ketika aplikasi kamera sistem terbuka. Pemanggilan `ImagePicker.retrieveLostData()` sebelumnya belum diterapkan.
5. **Kurangnya Reaktivitas Widget Lifecycle di `NeoImageThumbnail`:**
   Pada [neo_image_thumbnail.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/lib/shared/widgets/neo_image_thumbnail.dart), `_SignedImageLoaderState.didUpdateWidget` memanggil `_fetchSignedUrl()` tanpa `setState()`. Sedangkan `_HeroImageLoaderState` sama sekali tidak memiliki override `didUpdateWidget`.

### 3.2. Implementasi Perbaikan

#### A. Mekanisme Resolusi UID Berlapis & Tahan Gagal
Di [scan_flow_provider.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/lib/features/scanner/providers/scan_flow_provider.dart), pengambilan `uid` kini menggunakan mekanisme berantai (*fallback chain*):
```dart
String? uid;
try {
  uid = fb.FirebaseAuth.instance.currentUser?.uid;
} catch (_) {
  uid = null;
}

if (uid == null || uid.isEmpty) {
  try {
    uid = await mealRepository.getCurrentUserId();
  } catch (_) {
    uid = null;
  }
}
```

#### B. Pemulihan Byte Gambar dari File
Jika `_imageBytes` hilang akibat *memory pressure* namun `_imageFile` masih ada pada *temporary storage*:
```dart
if (_imageBytes == null && _imageFile != null) {
  try {
    if (await _imageFile!.exists()) {
      _imageBytes = await _imageFile!.readAsBytes();
    }
  } catch (e) {
    debugPrint('ScanFlowProvider: error reloading image bytes from file: $e');
  }
}
```

#### C. Transparansi Kesalahan (*No Silent Photo Drops*)
Jika pengguna mengambil foto dan pengunggahan gagal, aplikasi **tidak lagi menyimpan catatan makanan tanpa foto secara diam-diam**. Kesalahan dilaporkan secara transparan ke pengguna:
```dart
try {
  uploadedMetadata = await storageService!.uploadFoodImage(
    userId: uid,
    mealId: mealId,
    imageBytes: _imageBytes!,
  );
} catch (storageErr) {
  debugPrint('SupabaseStorage upload failure: $storageErr');
  _errorMessage = 'Gagal mengunggah foto makanan ke penyimpanan cloud. Periksa koneksi internet Anda dan coba lagi.';
  _isProcessing = false;
  notifyListeners();
  return false;
}
```

#### D. Rollback Aman untuk Menghindari File Yatim (*Orphaned Files*)
Jika foto berhasil diunggah ke Supabase Storage namun penyimpanan metadata ke Firebase Firestore gagal, sistem secara otomatis menghapus file foto dari Supabase:
```dart
} catch (repoErr) {
  if (uploadedMetadata != null && storageService != null) {
    try {
      await storageService!.deleteFoodImage(uploadedMetadata.path);
    } catch (deleteErr) {
      debugPrint('Failed to rollback orphaned image: $deleteErr');
    }
  }
  rethrow;
}
```

#### E. Pemulihan Data Kamera Android Hilang (*Retrieve Lost Data*)
Diimplementasikan penanganan `_picker.retrieveLostData()` pada Android:
```dart
if (picked == null && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
  final LostDataResponse lostData = await _picker.retrieveLostData();
  if (!lostData.isEmpty && lostData.file != null) {
    picked = lostData.file;
  }
}
```

#### F. Pembersihan Memori & Cache URL saat Logout
- Pada `ScanFlowProvider.reset()`: `_imageBytes = null;` dan `_imageFile = null;` keduanya dibersihkan total.
- Pada [main.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/lib/main.dart): callback `authProvider.onLogout` memanggil `storageService.clearUrlCache()` untuk mencegah *leak* URL bertanda tangan antar sesi pengguna.

---

## 4. Test Suite Execution & Verification Evidence

Seluruh perbaikan telah diverifikasi dengan automated test suite:

### 4.1. Unit & Widget Tests Baru
1. [test/portion_input_widget_test.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/test/portion_input_widget_test.dart) (7 Test Cases):
   - `Initial display value defaults to 0 and not 150` -> **PASSED**
   - `Tapping 0 selects entire text so user can immediately overwrite` -> **PASSED**
   - `PortionNumberInputFormatter replaces leading zero when typing positive number` -> **PASSED**
   - `PortionNumberInputFormatter sanitizes comma to dot and allows decimals` -> **PASSED**
   - `Input survives widget rebuild without resetting to 0` -> **PASSED**
   - `Zero value triggers validation rejection on submit` -> **PASSED**
   - `Does not overflow horizontally on ultra-narrow 320px screens` -> **PASSED**
2. [test/meal_photo_persistence_test.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/test/meal_photo_persistence_test.dart) (4 Test Cases):
   - `Successful camera photo upload persists image metadata to Firestore record` -> **PASSED**
   - `Storage upload failure is transparently reported and meal is NOT saved without photo` -> **PASSED**
   - `Firestore failure after storage upload triggers rollback to prevent orphaned images` -> **PASSED**
   - `ScanFlowProvider reset completely flushes imageBytes and imageFile from memory` -> **PASSED**
3. [test/portion_validation_test.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/test/portion_validation_test.dart) (4 Test Cases): -> **ALL PASSED**
4. [test/meal_history_image_widget_test.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/test/meal_history_image_widget_test.dart) & [test/meal_history_redesign_test.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/test/meal_history_redesign_test.dart) (10 Test Cases): -> **ALL PASSED**
5. [test/floating_navbar_and_avatar_test.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/test/floating_navbar_and_avatar_test.dart) (6 Test Cases): -> **ALL PASSED**

### 4.2. Bukti Eksekusi Terminal
```bash
$ flutter test test/portion_input_widget_test.dart
00:01 +7: All tests passed!

$ flutter test test/meal_photo_persistence_test.dart
00:00 +4: All tests passed!

$ flutter test test/portion_validation_test.dart
00:00 +4: All tests passed!

$ flutter test test/meal_history_image_widget_test.dart test/meal_history_redesign_test.dart
00:01 +10: All tests passed!
```

---

## 5. Static Analysis & Lint Quality

Dijalankan pemeriksaan analisis statis menyeluruh di seluruh codebase `frontend`:
```bash
$ flutter analyze
Analyzing frontend...
No issues found! (ran in 3.3s)
```
**Hasil:** 0 error, 0 warning, 0 hint.

---

## 6. Security & Multi-tenant Storage Compliance

1. **Bucket Privacy:** Bucket Supabase `food-history-images` berstatus privat (*non-public*). Akses binary gambar mewajibkan pembuatan Signed URL dengan masa berlaku terbatas (TTL 1 jam / 3600 detik).
2. **Multi-Tenant Path Isolation:** Seluruh path penyimpanan terisolasi secara ketat per user: `$userId/$mealId/food_$timestamp.jpg`. User A tidak dapat membaca atau menimpa file gambar User B.
3. **Client-Side Credential Safety:** Hanya `supabaseAnonKey` yang disertakan di kode client Flutter. `service_role` key tidak pernah diekspos di aplikasi client.
4. **Session Isolation on Logout:** Seluruh URL cache lokal dihapus seketika saat user melakukan logout melalui `storageService.clearUrlCache()`.

---

## 7. Google Play Compliance Impact

1. **Health Disclaimer & Data Integrity:**
   NutriView mengimplementasikan *disclaimer* kesehatan non-medis dan penegasan validasi porsi realistis ($1 \le g \le 5000$), mencegah kalkulasi nutrisi ekstrem yang melanggar kebijakan aplikasi kesehatan Google Play (*Google Play Health Apps Policy*).
2. **Account Deletion & Data Retention:**
   Fungsi `deleteMeal` dan `deleteUserFoodImages` memastikan bahwa penghapusan catatan makanan atau akun pengguna menghapus file gambar fisik dari Supabase Storage secara sinkron, mematuhi persyaratan *Google Play User Data Deletion Policy*.
3. **Camera Permission Compliance:**
   Deklarasi kamera pada Android Manifest telah menerapkan `android:required="false"` dengan izin runtime eksplisit dan penanganan penolakan izin yang ramah pengguna.

---

## 8. Ringkasan File yang Dimodifikasi & Dibuat

| File Path | Tindakan | Ringkasan Perubahan |
| :--- | :--- | :--- |
| `frontend/lib/features/scanner/screens/portion_input_screen.dart` | Modified | Default nilai awal 0, auto-selection on focus/tap, `PortionNumberInputFormatter`, pencegahan overflow pada layar 320px, validasi porsi ketat. |
| `frontend/lib/features/scanner/providers/scan_flow_provider.dart` | Modified | Default porsi 0.0, pemulihan byte dari file, pengambilan UID tahan gagal, transparansi kegagalan storage, rollback Firestore error, pembersihan memori pada reset. |
| `frontend/lib/data/repositories/meal_repository.dart` | Modified | Ditambahkan helper method publik `Future<String> getCurrentUserId()` untuk resolusi UID lintas dependensi. |
| `frontend/lib/shared/widgets/neo_image_thumbnail.dart` | Modified | Ditambahkan pemanggilan `setState()` pada `didUpdateWidget` untuk `_SignedImageLoaderState` dan `_HeroImageLoaderState`. |
| `frontend/lib/shared/neo/neo_section_header.dart` | Modified | Diimplementasikan `LayoutBuilder` dengan deteksi bounded/unbounded layout untuk mencegah crash flex dan overflow. |
| `frontend/lib/shared/neo/neo_badge.dart` | Modified | Teks badge dibungkus `Flexible` dengan elipsis untuk mencegah overflow di container sempit. |
| `frontend/lib/main.dart` | Modified | Ditambahkan `storageService.clearUrlCache()` pada `authProvider.onLogout`. |
| `frontend/test/portion_input_widget_test.dart` | Created | Test suite 7 kasus uji untuk initial zero, formatting, tap selection, rebuild resilience, dan responsivitas 320px. |
| `frontend/test/meal_photo_persistence_test.dart` | Created | Test suite 4 kasus uji untuk alur kamera, Supabase upload, error transparency, dan rollback. |

---

## 9. Status Table

| Item Pekerjaan | Kategori | Status | Keterangan Verifikasi |
| :--- | :--- | :--- | :--- |
| **Nilai Awal Porsi Default 0** | UI & Input | **PASS** | Tampil '0' saat pertama kali layar dibuka (bukan 150). |
| **Kemudahan Edit Angka 0** | Ergonomi | **PASS** | Auto-selection on tap & focus; pengetikan 1-9 langsung menimpa angka 0. |
| **Dukungan Desimal & Sanitasi Koma** | Formatter | **PASS** | `PortionNumberInputFormatter` mengubah `,` menjadi `.` dan mengizinkan `0.5` s.d. `5000`. |
| **State Persistence saat Rebuild** | State Mgmt | **PASS** | Controller dan FocusNode bertahan saat notifyListeners / orientasi berubah. |
| **Validasi Porsi > 0 saat Simpan** | Validasi | **PASS** | Form validator dan provider menolak nilai 0 / kosong / > 5000g dengan pesan '1-5000g'. |
| **Bebas Overflow pada Layar 320px** | Layout | **PASS** | Diuji pada lebar 320px dengan surface size buatan; RenderFlex exception = 0. |
| **Persistensi Foto Kamera ke Cloud** | Storage & DB | **PASS** | Upload ke Supabase Storage dan penyimpanan path metadata ke Firestore berjalan mulus. |
| **Transparansi Kegagalan Upload** | Error Handling | **PASS** | Gagal unggah tidak lagi ditelan diam-diam; catatan makanan tidak disimpan tanpa foto jika foto diambil. |
| **Rollback saat Firestore Gagal** | Data Integrity | **PASS** | File Supabase Storage otomatis dihapus jika penulisan Firestore mengalami kegagalan. |
| **Pembersihan Memori pada Reset** | Performance | **PASS** | `_imageBytes` dan `_imageFile` dihapus tuntas saat scan flow di-reset atau logout. |
| **Static Code Analysis** | Code Quality | **PASS** | `flutter analyze` menghasilkan 0 error dan 0 warning. |
| **Manual Field Verification di Perangkat Fisik** | QA | **NEEDS MANUAL ACTION** | Jalankan pengujian langsung dengan kamera fisik Android (`flutter run -d <device_id>`). |

---
*Laporan ini disusun secara profesional oleh Antigravity Agentic Pair Programmer berdasarkan inspeksi kode nyata, pengujian terotomatisasi, dan standar rekayasa perangkat lunak produksi.*
