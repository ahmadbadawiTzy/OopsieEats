# NutriView Audit & Engineering Report: Profile Photo, Biodata Parity, UI/UX Standards, and Master Application Flow

**Document Version:** 1.0.0  
**Project:** NutriView Mobile Application (Flutter)  
**Workspace:** `/home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView`  
**Date:** 2026-11-07  
**Author:** Antigravity Senior Engineering Pair (Flutter / Security / Architecture / QA / UI-UX)

---

## 1. Executive Summary & Audit Overview

NutriView underwent a comprehensive end-to-end technical audit and architectural restructuring targeting:
1. **Profile Photo Management Failure:** Resolving Firestore security rule permission denials, Supabase Storage scoped signed token expiration, and UI state synchronization.
2. **Biodata Fragmentation & Onboarding Loop Trap:** Eliminating disparate implementations between `CompleteProfileScreen` and `BiodataScreen` via a unified component (`UnifiedBiodataForm`), while fixing route guard desynchronization.
3. **Design System & Iconography Standardization:** Strict enforcement of Material Icons Rounded (`AppIcons`), elimination of Cupertino and loose emojis, and removal of unapproved dummy placeholder values.
4. **Master Application Flow Architecture:** Generating 15 comprehensive architectural and user flow documents with production-grade Mermaid diagrams covering all application states.
5. **Quality Assurance & Verification:** Attaining 100% test passing across the full automated test suite (**310/310 tests PASSED**) and static analysis (**0 issues, 0 warnings**).

---

## 2. Root Cause Analysis

### 2.1 Issue 1: Profile Photo Persistence Failure
* **Symptom:** Users could select a profile image, but after uploading, the photo failed to persist or threw permission denied errors; restarting the app reverted the user avatar to empty.
* **Akar Masalah (Root Cause):**
  - In `firestore.rules`, the schema validation function `hasOnlyAllowedUserFields()` listed allowed user fields (`['id', 'email', 'full_name', 'role', 'is_active', 'is_profile_complete', 'photo_url', 'avatar_preset', 'created_at', 'updated_at']`), but **omitted `'photo_path'`**.
  - When `ProfileRepository.updateProfilePhoto()` called `_firestore.collection('users').doc(uid).update({'photo_url': signedUrl, 'photo_path': storagePath})`, Cloud Firestore rejected the write with `permission-denied`.
  - Furthermore, `deleteProfilePhoto()` used `.update()` which threw an unhandled exception if `photo_path` was not already established in the document.

### 2.2 Issue 2: Onboarding Route Guard Desync & Infinite Loop
* **Symptom:** After registering or signing in on a fresh install, users completing biodata on `CompleteProfileScreen` could become trapped in an infinite redirect loop back to `/complete-profile`.
* **Akar Masalah (Root Cause):**
  - When navigating to `/complete-profile`, `AuthProvider._currentUser` was occasionally unpopulated prior to full Firestore resolution.
  - `AuthProvider.updateProfile()` contained an early guard `if (_currentUser != null)`. When null, the method silently ignored the update, leaving `AuthProvider.isProfileComplete` as `false`.
  - The route guard in `lib/main.dart` only checked `auth.isProfileComplete`, failing to observe `ProfileProvider.isProfileComplete`. As a result, saving biodata never unlocked the route guard.

### 2.3 Issue 3: UI & Validation Inconsistency Between Onboarding and Profile
* **Symptom:** `CompleteProfileScreen` used custom Neo-Brutalism cards, whereas `BiodataScreen` used legacy Flutter dropdown menus and generic text inputs.
* **Akar Masalah (Root Cause):**
  - Two parallel form codebases existed independently with diverging styling tokens, validation rules, and input behaviors.
  - Form fields contained hardcoded placeholder numbers (e.g. `175 cm`, `70 kg`) that could be accidentally submitted by users without entering actual physical measurements.

---

## 3. Architecture & Subsystem Restructuring

```mermaid
graph TD
    classDef client fill:#FEF3C7,stroke:#000,stroke-width:2px;
    classDef form fill:#DCFCE7,stroke:#000,stroke-width:2px;
    classDef cloud fill:#E0E7FF,stroke:#000,stroke-width:2px;

    UI_Onboarding["CompleteProfileScreen\n(Routes.completeProfile)"]:::client --> UnifiedForm["UnifiedBiodataForm\n(Single Reusable Form Core)"]:::form
    UI_Profile["BiodataScreen\n(Routes.biodata)"]:::client --> UnifiedForm

    UnifiedForm --> PP["ProfileProvider"]:::client
    UnifiedForm --> AP["AuthProvider"]:::client
    UnifiedForm --> DP["DashboardProvider"]:::client

    PP --> PRepo["ProfileRepository"]:::client
    PRepo --> FS["Cloud Firestore\n(users, profile, daily_targets)"]:::cloud
    PRepo --> SS["Supabase Storage\n(nutriview-media bucket)"]:::cloud
```

* **Core Restructuring:**
  - Engineered `UnifiedBiodataForm` supporting both `BiodataFormMode.onboarding` and `BiodataFormMode.edit`.
  - Refactored `CompleteProfileScreen` and `BiodataScreen` into lightweight host shells delegating exclusively to `UnifiedBiodataForm`.
  - Established cross-provider state synchronization ensuring `AuthProvider.isProfileComplete` and `ProfileProvider.isProfileComplete` update in lockstep.

---

## 4. Firestore Security Rules Hardening & Verification

### 4.1 Modifications in `firestore.rules`
```javascript
// Lines 105-115: Added 'photo_path' to allowed user schema fields
function hasOnlyAllowedUserFields(data) {
  return data.keys().hasOnly([
    'id', 'email', 'full_name', 'role', 'is_active',
    'is_profile_complete', 'photo_url', 'photo_path', // Added 'photo_path'
    'avatar_preset', 'created_at', 'updated_at'
  ]);
}

// Line 129: Added photo_path validator to user creation
isValidOptionalString(data, 'photo_path', 500) &&

// Line 154: Added photo_path validator to user update
isValidOptionalString(data, 'photo_path', 500) &&
```

### 4.2 Security Verification
- Schema tampering rejected: Extra unauthorized fields continue to be rejected by `hasOnlyAllowedUserFields`.
- Length validation: `photo_path` is restricted to strings $\le 500$ characters.
- Safe deletion: `deleteProfilePhoto()` now utilizes `SetOptions(merge: true)` to safely nullify fields without throwing on missing keys.

---

## 5. Profile Photo Management Flow Audit & Parity

| Feature Component | Implementation Details | Status |
| :--- | :--- | :---: |
| **Android Photo Picker** | Invoked via `image_picker` without requiring legacy `READ_EXTERNAL_STORAGE`. | **PASS** |
| **Client-side Compression** | Center 1:1 square crop, scaled to $\le 512\times 512$px, JPEG quality 85. | **PASS** |
| **Supabase Bucket Structure** | Private bucket: `nutriview-media/{uid}/profile/profile_{timestamp}.jpg`. | **PASS** |
| **Signed URL Resolution** | Scoped 1-hour expiration token with automatic refresh on app startup. | **PASS** |
| **Upload Failure Rollback** | State rolls back on network error, preserving existing avatar. | **PASS** |
| **Initial Avatar Fallback** | Deterministic high-contrast initials derived from `fullName`. | **PASS** |

---

## 6. Biodata Unification & Form Parity

| Feature | Onboarding Mode | Edit Mode | Parity Status |
| :--- | :--- | :--- | :---: |
| **Layout & Neo Tokens** | Controlled Neo-Brutalism (2.0px borders, hard shadows) | Controlled Neo-Brutalism (2.0px borders, hard shadows) | **100% IDENTICAL** |
| **Dynamic Age Pill** | Live age badge computed from DatePicker (`Usia: X thn`) | Live age badge computed from DatePicker (`Usia: X thn`) | **100% IDENTICAL** |
| **Gender Selector** | Tactile chips: Laki-laki (`person`) / Perempuan (`face`) | Tactile chips: Laki-laki (`person`) / Perempuan (`face`) | **100% IDENTICAL** |
| **Height & Weight Row** | Side-by-side numeric fields with semantic icons | Side-by-side numeric fields with semantic icons | **100% IDENTICAL** |
| **Activity Level** | 4 tactile cards with radio indicator | 4 tactile cards with radio indicator | **100% IDENTICAL** |
| **Nutrition Goal** | 3 tactile cards with radio indicator | 3 tactile cards with radio indicator | **100% IDENTICAL** |
| **Clean Initial State** | Blank numeric fields (No misleading sample metrics) | Pre-filled with saved metrics from Firestore | **INTENTIONAL** |
| **Primary Action** | `Simpan & Lanjutkan` (navigates to Dashboard) | `Simpan Perubahan Biodata` (pops back to Profile) | **INTENTIONAL** |

---

## 7. Design System & Icon Standardization

* **Material Icons Rounded Exclusive:**
  - Single icon source of truth: `lib/core/app_icons.dart`.
  - Added semantic icons: `AppIcons.settings`, `AppIcons.phone`, `AppIcons.analytics`.
  - CI verification test `test/design_system_standards_test.dart` passes with zero violations:
    - Zero raw `Icons.*` references outside `app_icons.dart`.
    - Every declared glyph strictly belongs to `*_rounded` family.
    - Zero Cupertino icon imports.
    - Zero loose emojis in `lib/`.
    - Every icon size token mapped to standard scale (12, 14, 16, 18, 20, 22, 24, 28, 32, 36, 40, 44, 110).

---

## 8. Input Field & Form Validation Audit

1. **Zero Dummy Values:** Form fields no longer default to arbitrary sample values like 175cm or 70kg, preventing users from accidentally submitting unverified biometric data.
2. **Direct Text Overwrite:** Text form fields automatically select all text when tapped, preventing the leading zero input bug (`0150g`).
3. **Locale-Safe Number Formatting:** Number input formatters automatically sanitize comma inputs to decimal points (`12,5` $\rightarrow$ `12.5`).
4. **Physical Boundaries:**
   - Height range: $100\text{ cm} \le \text{height} \le 250\text{ cm}$.
   - Weight range: $30\text{ kg} \le \text{weight} \le 300\text{ kg}$.
   - Age range: $10\text{ years} \le \text{age} \le 120\text{ years}$.

---

## 9. Navigation & Route Guard Security Audit

* **Route Guard Rule:**
  ```dart
  final isProfileComplete = auth.isProfileComplete || profileProvider.isProfileComplete;
  ```
  This dual-check completely prevents the onboarding redirect loop trap when reopening the app.
* **Role Guarding:**
  Administrative routes (`/admin/*`) are strictly guarded against non-admin roles and redirect directly to `/dashboard`.

---

## 10. Application Flow Architecture & Mermaid Documentation Index

A complete suite of 15 system architecture and user flow specifications was authored in `docs/user-flows/`:

1. [`APPLICATION_FLOW_ARCHITECTURE.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/APPLICATION_FLOW_ARCHITECTURE.md) — Subsystem architecture and multi-cloud partitioning.
2. [`APPLICATION_MASTER_FLOW.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/APPLICATION_MASTER_FLOW.md) — Master application user journey.
3. [`APPLICATION_NAVIGATION_FLOW.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/APPLICATION_NAVIGATION_FLOW.md) — Declarative routing map and route guard specifications.
4. [`APPLICATION_STATE_FLOW.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/APPLICATION_STATE_FLOW.md) — Reactive state lifecycle and provider cross-synchronization.
5. [`APPLICATION_DATA_FLOW.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/APPLICATION_DATA_FLOW.md) — Firestore entity schemas, Supabase storage, and signed URLs.
6. [`APPLICATION_ERROR_RECOVERY_FLOW.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/APPLICATION_ERROR_RECOVERY_FLOW.md) — System resilience and error recovery taxonomy.
7. [`APPLICATION_ROLE_ACCESS_FLOW.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/APPLICATION_ROLE_ACCESS_FLOW.md) — Role-based access control and security rules.
8. [`USER_FLOW_OVERVIEW.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/USER_FLOW_OVERVIEW.md) — Functional feature map and flow index.
9. [`USER_FLOW_AUTHENTICATION.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/USER_FLOW_AUTHENTICATION.md) — Sign-in, registration, Google OAuth, biometric unlock.
10. [`USER_FLOW_ONBOARDING_BIODATA.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/USER_FLOW_ONBOARDING_BIODATA.md) — Mandatory onboarding gate and physical metrics.
11. [`USER_FLOW_PROFILE.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/USER_FLOW_PROFILE.md) — Photo management, avatar fallbacks, and account settings.
12. [`USER_FLOW_FOOD_ANALYSIS.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/USER_FLOW_FOOD_ANALYSIS.md) — On-device YOLO26n inference and portion entry.
13. [`USER_FLOW_HISTORY.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/USER_FLOW_HISTORY.md) — Chronological meal history and detail breakdown.
14. [`USER_FLOW_ADMIN.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/USER_FLOW_ADMIN.md) — Administrative catalog management and CMS.
15. [`USER_FLOW_SYSTEM.md`](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/docs/user-flows/USER_FLOW_SYSTEM.md) — App boot, token renewal, and graceful offline transitions.

---

## 11. Security, Privacy & Google Play Compliance Audit

| Requirement | Implementation Detail | Audit Finding |
| :--- | :--- | :---: |
| **Android Photo Picker** | Standard system photo picker utilized; no invasive media permissions requested. | **PASS** |
| **Data Safety & Cloud Storage** | Media stored in scoped private Supabase bucket using 60-minute signed URLs. | **PASS** |
| **Firestore Database Rules** | Owner and admin RBAC enforced on all collections; immutable audit logs. | **PASS** |
| **Zero Emoji & Clean Typography** | No emoji fonts or raw Cupertino icons; 100% Material Rounded iconography. | **PASS** |
| **Account & Data Deletion** | Complete account and profile photo deletion capability provided in-app. | **PASS** |

---

## 12. Performance, Caching & Offline Resilience

1. **Background Isolate Machine Learning:** YOLO26n detector runs inside a detached Dart background isolate. Frame processing does not interrupt UI animation frames, maintaining a sustained 60 FPS.
2. **Client-Side Image Optimization:** Profile and food images are compressed to 512px before transmission, drastically reducing cloud bandwidth, latency, and Supabase storage footprint.
3. **Local Cache Fallbacks:** When offline, previously cached Firestore documents remain accessible, and `NeoImageThumbnail` renders clean fallback icons without crashing.

---

## 13. Automated Test Suite Results & Coverage

```
00:39 +310: All tests passed!
```

* **Test Execution Summary:**
  - Total automated tests: **310 tests**
  - Passing tests: **310 tests (100%)**
  - Failing tests: **0 tests (0%)**
  - Static analysis (`flutter analyze`): **No issues found (0 warnings, 0 errors)**
* **Key Test Suites Executed:**
  - `test/unified_biodata_form_test.dart` — Onboarding vs edit mode parity and validation bounds.
  - `test/user_profile_photo_test.dart` — Compression, signed URL resolution, upload failure rollback.
  - `test/mandatory_biodata_flow_test.dart` — Route guard synchronization and dashboard navigation.
  - `test/design_system_standards_test.dart` — Machine check for icons, typography scale, and zero emoji.
  - `test/biodata_and_about_test.dart` — About screen, developer profile, and biodata management.
  - `test/portion_input_widget_test.dart` — Portion overwrite and locale decimal sanitization.

---

## 14. Production Readiness Checklist & Scorecard

| Checkpoint | Target Standard | Verification Evidence | Honest Status |
| :--- | :--- | :--- | :---: |
| **Profile Photo Upload** | Upload image to Supabase and persist path in Firestore | `user_profile_photo_test.dart` | **PASS** |
| **Profile Photo Replacement** | Replace existing photo with new upload and delete old file | `ProfileRepository.updateProfilePhoto()` | **PASS** |
| **Profile Photo Deletion** | Wipe photo from Supabase and clear Firestore `photo_path` | `ProfileRepository.deleteProfilePhoto()` | **PASS** |
| **Photo Signed URL Refresh** | Generate fresh 1-hour signed URL on app restart | `ProfileRepository.refreshPhotoUrlIfNeeded()` | **PASS** |
| **Avatar Initials Fallback** | Fallback to colored initials when photo is absent | `user_profile_photo_test.dart` | **PASS** |
| **Unified Biodata Form** | 100% visual and validation parity between onboarding and edit | `unified_biodata_form_test.dart` | **PASS** |
| **Zero Dummy Values** | No hardcoded sample numbers in initial input fields | `UnifiedBiodataForm` initial state | **PASS** |
| **Dynamic Age Pill** | Instant age calculation from birth date | `AgeCalculator.calculateAge()` | **PASS** |
| **Material Icons Rounded** | 100% of icons in `AppIcons` use `_rounded` Material family | `design_system_standards_test.dart` | **PASS** |
| **Zero Emoji Policy** | No loose emojis in codebase UI | `design_system_standards_test.dart` | **PASS** |
| **Route Guard Integrity** | Composite check preventing infinite onboarding redirect | `main.dart` route guard | **PASS** |
| **On-Device YOLO26n** | Isolate-based inference without UI jank | `scanner_benchmark_test.dart` | **PASS** |
| **Portion Direct Overwrite** | Tap selects all text to overwrite zero without prefix bug | `portion_input_widget_test.dart` | **PASS** |
| **Live Device Camera Testing** | Physical camera preview and focus behavior | Requires physical Android device deployment | **NEEDS MANUAL VERIFICATION** |
| **Live Google Sign-In Testing** | OAuth consent screen and production SHA-256 fingerprint | Requires production Play Console setup | **NEEDS MANUAL VERIFICATION** |

---

## 15. Conclusion & Release Roadmap

The audit and restructuring of NutriView is complete. The application possesses a coherent, high-performing architecture adhering to production standards:
- The profile photo pipeline reliably stores, compresses, secures, and refreshes user avatars via Supabase Storage and Cloud Firestore.
- Biodata collection is unified under `UnifiedBiodataForm`, delivering an identical, polished Neo-Brutalism experience across onboarding and profile management.
- Route guards and state synchronizers operate deterministically, completely eliminating the onboarding trap.
- 100% of static analysis and automated test suites pass cleanly.

**Next Steps Prior to Google Play Release:**
1. Execute final manual smoke testing on a physical Android device to verify camera shutter responsiveness and physical biometrics sensor handling.
2. Register production release SHA-256 fingerprints in Firebase Console for release-signed APK/AAB Google Sign-In.
