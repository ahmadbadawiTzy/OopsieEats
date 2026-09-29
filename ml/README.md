# Panduan ML & Pelatihan Model — NutriView

Dokumen ini menjelaskan dataset, pelatihan, evaluasi, dan keterbatasan model deteksi makanan YOLO26n untuk NutriView.

## 1. Daftar Kelas yang Didukung

Daftar kelas resmi didefinisikan dalam `classes.yaml`:
- `nasi_putih`
- `nasi_goreng`
- `ayam_goreng`
- `ikan_goreng`
- `telur_dadar`
- `telur_rebus`
- `tempe_goreng`
- `tahu_goreng`
- `perkedel`
- `sate_ayam`
- `rendang`
- `gado_gado`
- `bakso`
- `mie_goreng`
- `sayur_bening`

## 2. Keterbatasan Model

1. Model hanya mengenali **15 kelas makanan** yang terdaftar di atas dan **tidak mewakili seluruh variasi makanan Indonesia**.
2. Akurasi inferensi bergantung pada pencahayaan, sudut pengambilan gambar, dan derajat tumpang tindih makanan pada piring.
3. Model **hanya bertugas mendeteksi jenis makanan**. Model **TIDAK** menghitung kalori, protein, karbohidrat, lemak, atau porsi makanan.
4. Pengguna selalu memiliki kendali untuk mengonfirmasi, mengoreksi, menghapus, atau menambahkan makanan secara manual di aplikasi.

## 3. Alur Pelatihan (Google Colab)

Pelatihan model dilakukan menggunakan Google Colab GPU dengan Ultralytics YOLO26n:

```python
from ultralytics import YOLO

# 1. Load model pretrained YOLO26n
model = YOLO('yolo26n.pt')

# 2. Train model
results = model.train(
    data='dataset.yaml',
    epochs=50,
    imgsz=640,
    batch=16,
    name='nutriview_yolo26n'
)

# 3. Evaluasi validasi
metrics = model.val()
print("mAP@0.5:", metrics.box.map50)
```

## 4. Penempatan Bobot Model

Setelah pelatihan selesai:
1. Unduh file `best.pt` dari `runs/detect/nutriview_yolo26n/weights/best.pt`.
2. Letakkan di `backend/app/ml/weights/best.pt` (atau sesuaikan variabel lingkungan `MODEL_PATH`).
3. File bobot `*.pt` **tidak di-commit** ke repositori Git.
4. Jika bobot belum tersedia, backend tetap dapat berjalan dan endpoint `/api/v1/foods/detect` akan mengembalikan kode HTTP `503 MODEL_UNAVAILABLE` dengan pesan informatif, sementara seluruh fitur pencatatan manual tetap berfungsi normal.
