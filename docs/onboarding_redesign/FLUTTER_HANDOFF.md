# Prompt Tahap 2 — Implementasi Flutter Native

Jalankan di Claude Code **dari folder project NutriView** (folder `docs/onboarding_redesign/` ini sudah harus ada di sana).

---

Baca `docs/onboarding_redesign/README.md` dan buka `docs/onboarding_redesign/onboarding_preview.html` sebagai referensi desain final (3 slide onboarding, Extreme Neo-Brutalism). Aset sudah siap di `docs/onboarding_redesign/assets/` (foto sticker die-cut + 14 ilustrasi makanan PNG transparan).

Tugas:

1. **Audit dulu**: temukan implementasi onboarding yang ada (screen, routing, penyimpanan status "sudah onboarding", dependency, design token/warna/font). Jangan ubah Firebase Auth, Firestore, Supabase Storage, YOLO26n, meal history, profil, scan makanan, maupun skema database.
2. **Pindahkan aset** ke `assets/onboarding/` (foto + makanan), daftarkan di `pubspec.yaml`. Jangan tambah dependency baru; pakai `Image.asset` dengan PNG.
3. **Implementasi native** (dilarang WebView / screenshot HTML sebagai gambar penuh): `PageView` + widget per slide, `Text`/`RichText` untuk headline (highlight kata dengan background), tombol native Skip/Next/"Mulai Sekarang", pagination native, `CustomClipper` untuk tepi kertas sobek, hard shadow dengan `BoxShadow(blurRadius: 0)`. Ukuran memakai `LayoutBuilder`/rasio lebar, bukan angka tetap. Pertahankan swipe, Skip, penyimpanan status, dan routing yang sudah ada.
4. **Samakan warna & font** dengan token project; kalau berbeda dari token `--nv-*` di HTML, ikuti project dan catat di README.
5. **QA visual**: jalankan di emulator Android, screenshot ketiga slide, bandingkan dengan HTML, perbaiki selisih. Cek tidak ada overflow, foto tidak terpotong tak wajar, wajah tidak tertutup makanan.
6. Jalankan `flutter analyze` dan `flutter test`, perbaiki error akibat perubahan onboarding, lalu isi bagian "Hasil pengujian (Flutter)" di README dengan hasil nyata.
7. Jangan commit atau push.
