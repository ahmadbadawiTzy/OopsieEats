# NutriView

NutriView is an offline-first mobile nutrition tracking application built with **Flutter**, featuring **on-device YOLO computer vision AI** and **Firebase**.

Users configure their personal physical profile, receive deterministic daily calorie and macronutrient targets calculated via the Mifflin-St Jeor equation, and log meals by capturing photos. An embedded **YOLO26n TensorFlow Lite** model classifies food items directly on the device without requiring an active internet connection. Users confirm portion weights, and nutrition metrics are computed with Atwater factor consistency before synchronizing with Cloud Firestore with full offline persistence.

> **Disclaimer**: Nutritional values and recommendations provided by NutriView are algorithmic estimates intended for general health tracking and do not constitute professional medical advice or clinical diagnosis.

---

## Architecture Overview

NutriView employs a serverless edge-AI mobile architecture:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        FLUTTER CLIENT APPLICATION                      │
│                                                                        │
│   ┌─────────────────────┐               ┌───────────────────────────┐  │
│   │ On-Device YOLO26n   │               │   Nutrition Engine        │  │
│   │ TFLite [1,3,640,640]│               │   Mifflin-St Jeor +       │  │
│   │ (best.tflite 9.4MB) │               │   Atwater Validation      │  │
│   └──────────┬──────────┘               └─────────────┬─────────────┘  │
│              │                                        │                │
│              ▼                                        ▼                │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │        Data Repositories & Local Persistent Cache (Offline)     │  │
│   │  (FoodRepository, MealRepository, ProfileRepo, AuthRepo)        │  │
│   └────────────────────────────────┬────────────────────────────────┘  │
└────────────────────────────────────┼───────────────────────────────────┘
                                     │ Direct Firebase SDK Connection
                                     ▼ (Firestore Rules & Strict RBAC)
┌────────────────────────────────────────────────────────────────────────┐
│                        FIREBASE BACKEND SERVICES                       │
│                                                                        │
│   ┌──────────────────────┐  ┌─────────────────┐  ┌──────────────────┐  │
│   │ Firebase Auth        │  │ Cloud Firestore │  │ Firebase Storage │  │
│   │ (Email/Password,     │  │ (Multi-tenant   │  │ (Media Assets &  │  │
│   │  Google Sign-In,     │  │  Meals, Foods,  │  │  Images, <= 5MB) │  │
│   │  Biometric Session)  │  │  CMS, Audit)    │  │                  │  │
│   └──────────────────────┘  └─────────────────┘  └──────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

### Key Architectural Characteristics
1. **100% On-Device Food Inference**: The YOLO26n model (9.4 MB) executes on-device via `tflite_flutter` isolates with zero server round-trip latency, preserving user privacy.
2. **Serverless Backend**: Relies exclusively on managed Firebase services (Authentication, Cloud Firestore, Firebase Storage) within free/Spark tier limits.
3. **Data Isolation & Security**: User meal logs and private health records reside under `users/{uid}/meals/{mealId}`, strictly isolated by declarative `firestore.rules`.
4. **Neo-Brutalism Overkill UI**: Bespoke design system with crisp high-contrast borders, solid shadows, integer spacing scale, and curated Material Symbols (`AppIcons`).

---

## Core Features

- **On-Device Food Detection**: Real-time object recognition using a quantized YOLO26n model recognizing 29 distinct food classes.
- **Biometric & Secure Authentication**: Multi-layered login flow supporting Email/Password, Google Sign-In, biometric authentication (fingerprint/face unlock) with encrypted session fallback.
- **Deterministic Nutrition Engine**: BMR and TDEE calculations utilizing the Mifflin-St Jeor formula and macronutrient energy verification using 4-4-9 Atwater factors.
- **Interactive Daily Dashboard**: Real-time calorie summary, macro breakdown bento cards (Protein, Carbohydrates, Fat), and intake logging.
- **Offline Resilient Storage**: Offline food database fallback via `seed_foods.json` and Firestore offline persistence.
- **Nutrition Educational CMS**: Curated nutrition articles and announcements with category filtering and offline caching.
- **Administrative Control Panel**: Role-based administration for managing food databases, viewing system audit logs, and monitoring meal distribution.

---

## Technology Stack

- **Framework**: Flutter 3.x (Dart 3.x)
- **Computer Vision & ML**: TensorFlow Lite (`tflite_flutter`), custom YOLO26n float16/int8 model
- **Authentication**: `firebase_auth`, `google_sign_in`, `local_auth`, `flutter_secure_storage`
- **Database & Cloud**: `cloud_firestore`, `firebase_storage`, `firebase_core`
- **State Management**: Provider architecture with layered Repository pattern
- **Image Processing**: `image` package for camera frame transformations and letterbox padding

---

## Development Prerequisites

- **Flutter SDK**: 3.24.x or higher (Stable channel)
- **Dart SDK**: 3.5.x or higher
- **Android SDK**: `minSdkVersion 23`, `compileSdkVersion 34`
- **Java Development Kit (JDK)**: OpenJDK 17 or 21
- **Device / Emulator**: Physical device or emulator with camera/file picker support

---

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/ahmadbadawiTzy/NutriView.git
cd NutriView
```

### 2. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 3. Machine Learning Model Setup
The required model files are included in the repository:
- Model Weights: `frontend/assets/models/best.tflite` (9.4 MB)
- Label Map: `frontend/assets/models/classes.txt` (29 food labels)

Ensure these are declared in `frontend/pubspec.yaml` under `flutter.assets`.

### 4. Firebase Configuration
NutriView connects to Firebase using standard configuration files:
- Android: `frontend/android/app/google-services.json`
- Flutter Options: `frontend/lib/firebase_options.dart`

To configure your own Firebase project:
1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com).
2. Enable **Authentication** (Email/Password, Google Sign-In).
3. Enable **Cloud Firestore** and deploy `firestore.rules` and `firestore.indexes.json` using the Firebase CLI:
   ```bash
   firebase deploy --only firestore
   ```
4. Generate platform configuration files using the FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

---

## Verification & Testing

### Running Static Analysis
Enforce Dart and Flutter code quality guidelines:
```bash
cd frontend
flutter analyze
```

### Running Test Suite
Execute unit tests, widget tests, and benchmark suites:
```bash
cd frontend
flutter test
```
All 251 test cases cover:
- Mifflin-St Jeor formula and Atwater equation validation
- YOLO26n scanner latency, isolate offloading, and memory stability
- Biometric authentication fallback and secure storage
- Overkill Neo-Brutalism UI components and responsive layout scaling

---

## Building for Production

### Android Release APK
```bash
cd frontend
flutter build apk --release
```
The output APK will be generated at `frontend/build/app/outputs/flutter-apk/app-release.apk`.

### Android App Bundle (AAB)
```bash
cd frontend
flutter build appbundle --release
```
The output bundle will be generated at `frontend/build/app/outputs/bundle/release/app-release.aab`.

> **Note**: For Google Play Store deployment, configure release signing keys in `frontend/android/key.properties` (excluded from version control).

---

## Project Structure

```text
NutriView/
├── .agents/                    # Agent skills and engineering guides
├── data/                       # Nutritional data references (e.g. foods.csv)
├── docs/                       # Architecture decisions, benchmarks, and API guides
├── firebase.json               # Firebase CLI configuration
├── firestore.rules             # Cloud Firestore security rules & RBAC
├── firestore.indexes.json      # Firestore composite indexes
├── scripts/                    # Database seeding and migration utilities
└── frontend/                   # Main Flutter application package
    ├── assets/
    │   ├── data/seed_foods.json    # Offline food database seed
    │   ├── images/                 # Brand logos and illustration assets
    │   └── models/
    │       ├── best.tflite         # YOLO26n TFLite on-device model (9.4 MB)
    │       └── classes.txt         # 29 Food classification labels
    ├── lib/
    │   ├── core/                   # Design tokens, theme, and utility functions
    │   ├── data/                   # Models, repositories, and API clients
    │   ├── features/               # Feature modules (Auth, Dashboard, Scan, CMS)
    │   └── shared/                 # Reusable Neo-Brutalist UI widgets
    └── test/                       # Unit, widget, and regression test suites
```

---

## Development Status & Roadmap

- [x] Complete Overkill Neo-Brutalism user and admin interfaces.
- [x] On-device YOLO26n inference pipeline with camera feed integration.
- [x] Multi-factor authentication with biometric fallback.
- [x] Unit and widget test suite passing with 100% pass rate.
- [ ] Multi-language localization (Indonesian / English).
- [ ] Barcode scanning integration for packaged consumer food products.

---

## License & Attribution

- **Nutritional Reference Data**: Tabel Komposisi Pangan Indonesia (TKPI 2020), Kementerian Kesehatan Republik Indonesia.
- **YOLO Vision Model**: Custom YOLO26n architecture trained on annotated food datasets.
- **Icons**: Material Symbols (`rounded` style).
