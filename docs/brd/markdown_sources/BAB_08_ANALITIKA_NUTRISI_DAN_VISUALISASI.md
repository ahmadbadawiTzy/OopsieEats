# BAB 8: Analitika Nutrisi dan Visualisasi

**Formula Ilmiah Mifflin-St Jeor, Safe Calorie Floor, Faktor Atwater, dan Komponen Visualisasi Data**

---

**Aplikasi:** OopsieEats (`com.oopsieeats.app`) | **Versi:** 1.0.0+2002  
**Penyusun:** Ahmad Badawi (NIM 20090015) — Universitas Bina Insani  
**Status:** Approved & Baselined | **Klasifikasi:** Confidential / Restricted

---


## 8.1 Model Perhitungan Kebutuhan Energi (Mifflin-St Jeor)

OopsieEats menolak penggunaan tebakan kalori empiris atau model AI generatif yang rentan halusinasi angka. Seluruh perhitungan kebutuhan metabolisme basal (Basal Metabolic Rate / BMR) dieksekusi secara murni deterministik menggunakan persamaan Mifflin-St Jeor yang telah divalidasi oleh American Dietetic Association (ADA) sebagai formula paling akurat:

- <strong>Formula BMR Pria (kcal/hari)</strong>: <code>BMR = (10 * berat_kg) + (6.25 * tinggi_cm) - (5 * usia_tahun) + 5</code>
- <strong>Formula BMR Wanita (kcal/hari)</strong>: <code>BMR = (10 * berat_kg) + (6.25 * tinggi_cm) - (5 * usia_tahun) - 161</code>
- <strong>Kalkulasi Pengeluaran Energi Total (TDEE)</strong>: <code>TDEE = BMR * faktor_aktivitas</code>

**Tabel 8.1: Koefisien Pengali Aktivitas Fisik Pengguna (Physical Activity Factor)**

| Tingkat Aktivitas Fisik | Koefisien Pengali | Deskripsi Gaya Hidup Pengguna | Contoh Aktivitas Mingguan |
| --- | --- | --- | --- |
| Sedentary (Sangat Sedikit) | 1.20 | Pekerja kantoran / duduk sepanjang hari | Tidak berolahraga teratur |
| Lightly Active (Ringan) | 1.375 | Aktivitas harian ringan dengan jalan kaki santai | Olahraga ringan 1 - 3 hari per minggu |
| Moderately Active (Sedang) | 1.55 | Aktivitas dinamis dan bergerak aktif | Olahraga intensitas sedang 3 - 5 hari per minggu |
| Very Active (Sangat Aktif) | 1.725 | Aktivitas fisik berat / latihan atletik rutin | Latihan fisik intensif 6 - 7 hari per minggu |


## 8.2 Safe Calorie Floor (Batas Bawah Aman: 1500 kcal Pria, 1200 kcal Wanita)

Dalam rekayasa aplikasi kesehatan, keselamatan metabolisme pengguna adalah prioritas tertinggi. Defisit kalori ekstrem yang memotong asupan energi di bawah batas kebutuhan fisiologis organ vital dapat memicu malnutrisi, kehilangan massa otot, dan perlambatan metabolisme (starvation mode).

> **Catatan Arsitektural**: OopsieEats mengimplementasikan mekanisme Safe Calorie Floor yang tidak dapat diganggu gugat: Target kalori harian terhitung dikunci dengan batas bawah minimum absolut: 1.500 kcal/hari untuk pria dan 1.200 kcal/hari untuk wanita, bahkan jika pengguna memilih program penurunan berat badan agresif (weight loss deficit).


## 8.3 Perhitungan Makronutrien Deterministik (Faktor Atwater 4-4-9)

Distribusi makronutrien makro diturunkan dari total target energi harian menggunakan rasio seimbang rekomendasi Kemenkes RI:

- <strong>Karbohidrat (Carbohydrates)</strong>: 50% dari total kalori harian. Mengingat 1 gram karbohidrat setara 4 kkal, gramasi dihitung: <code>target_carbs_g = (total_calories * 0.50) / 4.0</code>.
- <strong>Protein</strong>: 20% dari total kalori harian. Dengan nilai energi 4 kkal per gram: <code>target_protein_g = (total_calories * 0.20) / 4.0</code>.
- <strong>Lemak Sehat (Fat)</strong>: 30% dari total kalori harian. Dengan nilai energi 9 kkal per gram: <code>target_fat_g = (total_calories * 0.30) / 9.0</code>.

Untuk setiap hidangan yang dikonsumsi, kandungan nutrisi aktual dihitung secara linear terhadap bobot porsi saji (gram): <code>nilai_nutrisi = (nilai_per_100g * porsi_gram) / 100.0</code>.

Alur komputasi nutrisi terpadu dari pengisian data fisik, penerapan guard batas aman kalori, hingga pembaruan indikator gizi dimodelkan secara terstruktur pada Diagram Sekuensial UML berikut:


![Gambar 8.1: Diagram Sekuensial UML — Pipeline Kalkulasi Nutrisi Deterministik & Safe Calorie Floor Guard](docs/brd/diagrams/rendered/uml-nutrition-calc-sequence.png)
*Gambar 8.1: Diagram Sekuensial UML — Pipeline Kalkulasi Nutrisi Deterministik & Safe Calorie Floor Guard*


## 8.4 Tracking Harian & Visualisasi Hero Calorie Dial

Komponen <code>HeroCalorieDial</code> pada layar beranda menyajikan visualisasi radial interaktif berbasis <code>CustomPainter</code>. Dial lingkaran tebal (stroke width 16dp berbingkai hitam Neo-Brutalism) menampilkan persentase akumulasi kalori yang telah dikonsumsi terhadap target harian. Indikator warna bertransisi dinamis: Hijau Mint (asupan ideal < 90%), Kuning Elektrik (hampir tercapai 90-100%), dan Merah Koral dengan getaran haptik (asupan melebihi batas 100%).


## 8.5 Visualisasi Distribusi Makronutrien (Karbohidrat, Protein, Lemak)

Dasbor nutrisi mengadopsi struktur tata letak <strong>Bento Grid</strong> yang mengelompokkan tiga makronutrien utama dalam kartu individual berdinding tebal:

**Tabel 8.2: Spesifikasi Elemen Kartu Makronutrien Bento Grid**

| Makronutrien | Warna Lencana Visual | Target Rasio Standar | Informasi yang Ditampilkan |
| --- | --- | --- | --- |
| Karbohidrat | Vibrant Orange (#FF6B00) | 50% Energi Harian | Gramasi terkonsumsi, sisa gramasi, dan batang progres linier tebal |
| Protein | Mint Green (#00E599) | 20% Energi Harian | Gramasi tercapai, indikator kecukupan asam amino, dan persentase target |
| Lemak (Lipid) | Lavender Purple (#9D7BFF) | 30% Energi Harian | Akumulasi lemak gram, batas aman harian, dan grafik mikro |


## 8.6 Analitik Tren Mingguan & Bulanan

Layar <code>NutritionAnalysisScreen</code> memanfaatkan pustaka <code>fl_chart: ^0.69.0</code> untuk menyajikan grafik batang (Bar Chart) asupan 7 hari terakhir dan diagram lingkaran (Pie Chart) rasio aktual makronutrien. Garis referensi horizontal (Target Reference Line) berwarna hitam putus-putus membantu pengguna mengevaluasi kepatuhan pola makan mingguan secara komparatif.


## 8.7 Validasi Konsistensi Kalori vs Makronutrien

Sistem menerapkan validasi Atwater terintegrasi pada model <code>FoodItem</code>. Setiap kali entri makanan dibaca atau disimpan oleh administrator, sistem memverifikasi kesesuaian matematis: <code>deviasi = abs(calories - (4 * protein + 4 * carbs + 9 * fat)) / calories</code>. Jika deviasi melampaui ambang batas 30%, entri ditandai dengan flag inkonsistensi gizi untuk ditinjau ulang.


## 8.8 Penyesuaian Dinamis Berdasarkan Usia & Aktivitas Fisik

Kebutuhan energi manusia tidak bersifat statis. Modul <code>AgeCalculator</code> menghitung usia pengguna secara dinamis berdasarkan tanggal lahir yang tersimpan. Ketika pengguna memperbarui berat badan pada profil pribadi, seluruh target harian dikalkulasi ulang secara otomatis seketika (recomputed in-memory) tanpa memerlukan restart aplikasi.


## 8.9 Ekspor Data Riwayat Nutrisi

Pengguna memiliki opsi untuk mengunduh rekapitulasi riwayat makan dalam format CSV terstruktur yang memuat stempel waktu, nama hidangan, takaran porsi saji, kalori, dan rincian makronutrien lengkap, memfasilitasi pelaporan berkala kepada ahli gizi klinis independen.


## 8.10 Pengujian Unit Formula Perhitungan Gizi

Seluruh persamaan matematika pada modul <code>NutritionCalculator</code> diuji menggunakan 50+ variasi kombinasi parameter antropometri pada berkas pengujian otomatis <code>nutrition_calculator_test.dart</code>. Seluruh skenario batas (boundary values) termasuk Safe Calorie Floor terbukti akurat 100% terhadap perhitungan manual baku ahli gizi.
