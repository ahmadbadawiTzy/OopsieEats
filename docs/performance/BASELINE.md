# NutriView — Performance & Production Baseline Report

**Date of Audit:** 2026-10-28
**Environment:** Linux (Pop!_OS 24.04 LTS), Flutter 3.47.5, Dart 3.13.4
**Physical Test Device:** Xiaomi Redmi 12 (23053RN02A), Android 15 (API 35), ARM64-v8a
**Target Platform:** Android Release (Play Store Target)

---

## 1. System & Environment Baseline

| Component | Baseline Status | Notes |
| :--- | :--- | :--- |
| **Flutter SDK** | `3.47.5` (channel stable) | Engine hash `ab59836859` |
| **Dart Runtime** | `3.13.4` | DevTools `2.60.0` |
| **Android SDK** | API 35 / 36 / 37 installed | Build tools `36.0.0`, OpenJDK 25 |
| **Test Device** | Xiaomi Redmi 12 (`23053RN02A`) | Physical Android 15 device connected via ADB |
| **Static Analysis** | `0 errors, 0 warnings, 0 lints` | `flutter analyze` clean |
| **Automated Tests**| `136 / 136 passed` | Unit and widget test suite passing |

---

## 2. Release Artifacts Size Baseline

Measurement performed via `flutter build apk --release --split-per-abi`:

| Artifact | Baseline File Size | Exact Bytes | Notes |
| :--- | :--- | :--- | :--- |
| **Universal APK (`app-release.apk`)** | `52.2 MB` | 52,215,070 bytes | Combined multi-ABI build |
| **ARM64-v8a APK (`app-arm64-v8a-release.apk`)** | **38.8 MB** | 38,832,316 bytes | Primary modern device target |
| **ARMeabi-v7a APK (`app-armeabi-v7a-release.apk`)** | **34.3 MB** | 34,299,192 bytes | 32-bit legacy Android target |
| **x86_64 APK (`app-x86_64-release.apk`)** | **42.3 MB** | 42,252,898 bytes | Emulator / Chromebook target |
| **App Bundle (AAB)** | NOT MEASURED (Baseline) | Pending evaluation | Measured in Phase E |

### Internal APK Composition (ARM64-v8a)
- `libflutter.so`: ~11.75 MB
- `best.tflite` (On-Device Model): ~9.86 MB (uncompressed asset)
- `libapp.so` (Dart AOT Compiled): ~7.87 MB
- `libtensorflowlite_jni.so`: ~4.32 MB
- `classes.dex`: ~3.56 MB
- `libtensorflowlite_gpu_jni.so`: ~2.50 MB
- Other assets/resources: ~0.9 MB

---

## 3. Device Runtime & Startup Baseline

Measured on Xiaomi Redmi 12 (Android 15):

| Metric | Baseline Measurement | Measurement Method | Evaluation |
| :--- | :--- | :--- | :--- |
| **Cold Startup (`TotalTime`)** | **5,176 ms** (~5.18 s) | `adb shell am start-activity -W -n com.nutriview.nutriview/.MainActivity -S` | **CRITICAL BOTTLENECK**: Blocked by synchronous YOLO model load in `main()` before `runApp()` |
| **Warm Startup (`TotalTime`)** | **< 15 ms** | `adb shell am start-activity -W` (cached process) | Excellent |
| **Memory PSS (Startup Idle)** | **370,093 KB (~370 MB)** | `adb shell dumpsys meminfo com.nutriview.nutriview` | High initial footprint due to eager model allocation & unbounded Firestore cache |
| **Memory RSS (Startup Idle)** | **505,762 KB (~505 MB)** | `adb shell dumpsys meminfo com.nutriview.nutriview` | Total resident memory |
| **Graphics Memory** | **43,434 KB (~43 MB)** | `dumpsys meminfo` (EGL + GL track) | Healthy Vulkan/Skia render buffers |

---

## 4. AI On-Device Scanner Baseline

Measured on synthetic 720p food image (1280x720, typical smartphone capture):

| Step | Baseline Latency | Execution Isolate | Evaluation |
| :--- | :--- | :--- | :--- |
| **Model Initialization** | `28 ms` (desktop) / ~`1,800 ms` (mobile cold) | Main Dart Isolate | Blocks startup if in `main()` |
| **Image Decode & Orientation** | `75 ms` (desktop) / ~`350 ms` (mobile) | Main Dart Isolate | Freezes UI spinner during capture |
| **Resize (to 640x640)** | `14 ms` (desktop) / ~`80 ms` (mobile) | Main Dart Isolate | Freezes UI spinner |
| **Tensor Packing (Nested List)**| `18 ms` (desktop) / ~`95 ms` (mobile) | Main Dart Isolate | Heavy memory allocations |
| **Inference (`_interpreter.run`)** | `850 ms` (desktop) / ~`1,200 ms` (mobile) | Native C++ runtime (2 threads) | Suboptimal thread concurrency |
| **Output Parsing & NMS** | `20 ms` (desktop) / ~`110 ms` (mobile) | Main Dart Isolate | 730,000 bounds checks in 3D loops |
| **Total Pipeline Latency** | **977 ms** (desktop) / ~`2,600 ms` (mobile) | Main Dart Isolate | High jank risk; UI loader stutter |

---

## 5. Network & Firestore Query Baseline

| Flow | Current Query Behavior | Issue Identified |
| :--- | :--- | :--- |
| **Food Search (`searchFoods`)** | Calls `db.collection('foods').get()` on EVERY keystroke | Typing "nasi goreng" triggers 11 full collection reads. No caching, no debounce. |
| **Meal History (`getMeals`)** | Calls `db.collection('users/$uid/meals').get()` without query filters | Downloads the entire user meal history into memory and filters locally. |
| **Dashboard Init** | 4 concurrent calls: `dash.loadDashboard()`, `profileProv.loadProfile()`, `_loadTodayMeals()`, `_loadAnnouncementsAndArticles()` | Redundant reads of `users/$uid` and `meals` for today. |
| **Firestore Cache** | `cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED` | Risk of unbounded storage and memory bloat over prolonged usage. |

---

## 6. Bottleneck Prioritization Matrix

1. **P0 (Critical): Startup Time Blocker** — Remove synchronous `yoloDetector.initialize()` from `main()`. Move to background post-frame initialization or lazy-loading.
2. **P0 (Critical): Isolate Offloading for Scanner** — Move image decoding, orientation baking, and resizing into `Isolate.run` to guarantee 60fps/120fps UI responsiveness during scans.
3. **P1 (High): Firestore Query & Keystroke Throttling** — Cache `_getAllFoods()` in `FoodRepository`, debounce search input in `FoodSearchModal`, and add server-side bounds to `MealRepository.getMeals()`.
4. **P1 (High): Memory & Cache Bound** — Cap Firestore cache at 100 MB (`104,857,600` bytes). Optimize tensor parsing loops.
5. **P2 (Medium): Release Size Shrinking** — Apply `--split-debug-info`, `--obfuscate`, and R8 code/resource shrinking with ProGuard keep rules.
