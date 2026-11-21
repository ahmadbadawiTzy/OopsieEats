# BAB 7: Computer Vision dan Deteksi Makanan

**Pipeline Model On-Device YOLOv8 TFLite, 29 Kelas Pangan Indonesia, Background Isolate, dan Evaluasi Latensi**

---

**Aplikasi:** OopsieEats (`com.oopsieeats.app`) | **Versi:** 1.0.0+2002  
**Penyusun:** Ahmad Badawi (NIM 20090015) — Universitas Bina Insani  
**Status:** Approved & Baselined | **Klasifikasi:** Confidential / Restricted

---


## 7.1 Ikhtisar Model YOLOv8 (best.tflite - 9.4 MB)

OopsieEats mengintegrasikan model pembelajaran mendalam deteksi objek berbasis arsitektur YOLOv8n (Nano) yang telah dikonversi dan dikuantisasi ke dalam format TensorFlow Lite (<code>best.tflite</code>) dengan ukuran berkas sangat ringkas yaitu <strong>9.4 MB</strong>. Model ini disimpan langsung di dalam bundel aset aplikasi (<code>assets/models/best.tflite</code>) dan dimuat ke dalam memori virtual perangkat keras menggunakan teknik memori terpeta (memory-mapped I/O via <code>tflite_flutter</code>).

**Tabel 7.1: Spesifikasi Parameter Teknis Model TFLite On-Device**

| Parameter Arsitektur | Spesifikasi Model Aktual | Keterangan Teknis |
| --- | --- | --- |
| Arsitektur Jaringan | YOLOv8 Nano (Single-Stage Object Detector) | Dioptimalkan untuk eksekusi inferensi real-time mobile |
| Format Bobot Model | TensorFlow Lite FlatBuffer (.tflite) | Kompatibel dengan TFLite C++ Runtime Android & iOS |
| Ukuran Berkas Model | 9.4 MB (9.856.512 byte) | Memungkinkan distribusi ringan tanpa unduhan model terpisah |
| Dimensi Tensor Masukan | [1, 3, 640, 640] Float32 (NCHW/NHWC) | Memerlukan normalisasi kanal warna RGB 0.0 - 1.0 |
| Dimensi Tensor Keluaran | [1, 33, 8400] Float32 | 8400 kandidat kotak deteksi dengan 4 koordinat + 29 kelas |
| Akselerasi Perangkat Keras | NNAPI (Android) / Metal Delegate (iOS) / CPU | Fallback mulus ke multi-core CPU jika NPU tidak tersedia |


## 7.2 29 Kelas Pangan Indonesia (Label Mapping & TKPI 2020)

Model dilatih secara khusus untuk mengenali 29 varietas hidangan kuliner populer Indonesia yang dipetakan secara presisi terhadap basis data Tabel Komposisi Pangan Indonesia (TKPI 2020):

**Tabel 7.2: Pemetaan 29 Kelas Model Deteksi Pangan Nusantara**

| Indeks Kelas | Label Prediksi Model | Nama Resmi Hidangan (TKPI 2020) | Kategori Kuliner |
| --- | --- | --- | --- |
| 0 - 4 | ayam_goreng, bakso, batagor, bihun, capcay | Ayam Goreng, Bakso Sapi, Batagor Bandung, Bihun Goreng, Capcay Kuah | Lauk Hewani & Sayuran |
| 5 - 9 | gado_gado, ikan_goreng, martabak_manis, martabak_telur, mie_goreng | Gado-Gado Betawi, Ikan Goreng Mas/Nila, Martabak Manis, Martabak Telur, Mie Goreng Telur | Hidangan Tradisional |
| 10 - 14 | nasi_goreng, nasi_putih, pempek, rawon, rendang | Nasi Goreng Spesial, Nasi Putih Beras Giling, Pempek Palembang, Rawon Sapi, Rendang Daging Sapi | Pangan Pokok & Olahan Daging |
| 15 - 19 | roti_bakar, sate_ayam, sate_kambing, soto_ayam, tahu_goreng | Roti Bakar Keju, Sate Ayam Madura, Sate Kambing Bumbu Kecap, Soto Ayam Lamongan, Tahu Goreng Kedelai | Kuliner Jalanan & Sup |
| 20 - 24 | telur_balado, telur_dadar, telur_mata_sapi, tempe_bacem, tempe_goreng | Telur Balado Cabai Merah, Telur Dadar Daun Bawang, Telur Mata Sapi, Tempe Bacem Manis, Tempe Goreng Tepung | Lauk Nabati & Olahan Telur |
| 25 - 28 | terang_bulan, tumis_kangkung, udang_goreng, sayur_asem | Terang Bulan Cokelat, Tumis Kangkung Belacan, Udang Goreng Tepung, Sayur Asem Jakarta | Sayuran & Camilan |


## 7.3 Pipeline Pengambilan Gambar & Akses Perangkat Keras Kamera

Akses modul kamera dikendalikan oleh pustaka resmi <code>camera: ^0.11.0+2</code> dengan resolusi pratinjau <code>ResolutionPreset.high</code> (1080p). Alur sekuensial pengambilan foto hingga pencatatan makanan diilustrasikan secara komprehensif pada Diagram 8:


![Gambar 7.1: Diagram Sekuensial On-Device Computer Vision & Pencatatan Makanan](docs/brd/diagrams/rendered/sequence-scan.png)
*Gambar 7.1: Diagram Sekuensial On-Device Computer Vision & Pencatatan Makanan*


## 7.4 Preprocessing Gambar On-Device (Rotasi EXIF, Resize 640x640, Normalisasi Float32)

Sebelum citra dimasukkan ke dalam tensor model, serangkaian transformasi prapemrosesan matematis dieksekusi secara berurutan:

- <strong>Koreksi Orientasi EXIF</strong>: Mendeteksi tag rotasi EXIF dari sensor kamera untuk memutar citra ke orientasi tegak (0, 90, 180, atau 270 derajat).
- <strong>Letterboxing & Resize</strong>: Menyesuaikan aspek rasio citra ke dimensi standar masukan model <code>640 x 640 piksel</code> dengan penambahan padding netral abu-abu (114, 114, 114) untuk mencegah distorsi geometri makanan.
- <strong>Normalisasi Kanal Warna</strong>: Mengubah nilai piksel integer [0, 255] menjadi bilangan pecahan desimal IEEE 754 Float32 dalam rentang tertutup <code>[0.0, 1.0]</code> melalui operasi pembagian <code>pixel_val / 255.0</code>.


## 7.5 Eksekusi Inferensi Background Isolate (Isolate.run)

Inferensi jaringan saraf tiruan adalah operasi intensif CPU/GPU. Jika dieksekusi pada thread utama (Main UI Thread), antarmuka aplikasi akan mengalami stuttering atau frame drop yang merusak pengalaman pengguna.

> **Catatan Arsitektural**: OopsieEats mengisolasi seluruh tahapan decoding citra, normalisasi tensor, eksekusi model.run(), dan NMS ke dalam background isolate mandiri via API modern Dart Isolate.run(). Pendekatan ini menghasilkan 0 ms frame blocking pada antarmuka pengguna, mempertahankan kelancaran rendering layar pada 60/120 FPS penuh.


## 7.6 Post-Processing: Non-Maximum Suppression (IoU 0.45, Ambang Keyakinan 0.15)

Keluaran mentah tensor model berdimensi <code>[1, 33, 8400]</code> memuat ribuan calon kotak pembatas yang saling tumpang tindih. Sistem menerapkan algoritma Non-Maximum Suppression (NMS) teroptimasi:

- <strong>Penyaringan Keyakinan (Confidence Threshold)</strong>: Kotak deteksi dengan skor keyakinan di bawah <code>0.15 (15%)</code> langsung dieliminasi.
- <strong>Kalkulasi Intersection-over-Union (IoU)</strong>: Untuk kotak-kotak yang mendeteksi kelas hidangan yang sama, dihitung rasio luas irisan terhadap luas gabungan.
- <strong>Penekanan Tumpang Tindih (IoU Threshold)</strong>: Kotak redundan dengan nilai <code>IoU >= 0.45</code> ditekan, menyisakan hanya satu kotak deteksi paling optimal dengan skor keyakinan tertinggi.


## 7.7 Penanganan Multi-Deteksi & Pemilihan Porsi Dinamis

Dalam skenario makan siang nyata, satu piring seringkali memuat kombinasi beberapa hidangan sekaligus (contoh: Nasi Putih + Rendang + Tumis Kangkung). Algoritma OopsieEats mampu mendeteksi hingga 5 objek makanan berbeda dalam satu bingkai foto. Pada <code>DetectionConfirmationScreen</code>, pengguna disajikan daftar kartu interaktif untuk memilih atau menghapus item yang terdeteksi sebelum memasukkan gramasi porsi masing-masing.


## 7.8 Penanganan Fallback: Input Manual & Pencarian Katalog

Jika pencahayaan ruangan buruk atau makanan berada di luar 29 kelas yang dikenali model sehingga skor keyakinan < 0.15, sistem secara elegan menampilkan banner saran ramah: <em>'Makanan belum terdeteksi sempurna? Cari manual di katalog'</em>. Pengguna dapat mengetikkan nama makanan di kolom pencarian instan yang didukung oleh basis data offline <code>seed_foods.json</code>.


## 7.9 Pengujian Kinerja & Latensi Inferensi (< 300 ms)

Pengujian benchmark kinerja inferensi dilakukan pada berbagai spesifikasi chipset perangkat seluler nyata:

**Tabel 7.3: Hasil Uji Tolok Ukur Latensi Inferensi Model On-Device**

| Perangkat Uji | Chipset & Arsitektur | RAM | Waktu Prapemrosesan | Latensi Inferensi Model | Total Waktu |
| --- | --- | --- | --- | --- | --- |
| Google Pixel 8 | Google Tensor G3 (NPU) | 8 GB | 24 ms | 68 ms | 92 ms (Sangat Cepat) |
| Samsung Galaxy S23 | Snapdragon 8 Gen 2 (Adreno GPU) | 8 GB | 22 ms | 74 ms | 96 ms (Sangat Cepat) |
| Xiaomi Redmi Note 12 | Snapdragon 685 (CPU 8-Core) | 6 GB | 45 ms | 165 ms | 210 ms (Cepat & Halus) |
| Infinix Hot 30 | MediaTek Helio G88 (CPU Mid-Range) | 4 GB | 58 ms | 220 ms | 278 ms (< Target 300ms) |


## 7.10 Evaluasi Akurasi & Matriks Kebingungan (Precision, Recall, mAP50)

Evaluasi kinerja model pada dataset uji validasi independen (1.450 citra kuliner nusantara beranotasi) menghasilkan nilai <strong>Precision: 88.4%</strong>, <strong>Recall: 84.7%</strong>, dan <strong>mAP50: 89.2%</strong>. Sebagian kecil kebingungan prediksi (confusion) hanya terjadi pada hidangan dengan tekstur saus serupa seperti sate ayam bumbu kacang dan gado-gado, yang diselesaikan dengan memberikan konfirmasi visual interaktif kepada pengguna.
