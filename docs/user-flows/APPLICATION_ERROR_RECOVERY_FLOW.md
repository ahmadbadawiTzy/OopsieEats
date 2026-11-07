# Application Error Recovery Flow

## 1. System Resilience & Error Handling Architecture

NutriView enforces structured error handling through `ErrorHandler`, `ApiException`, and transactional state rollbacks across all user interaction paths.

```mermaid
flowchart TD
    classDef start fill:#FCD34D,stroke:#000,stroke-width:2px;
    classDef tryBlock fill:#E0E7FF,stroke:#000,stroke-width:2px;
    classDef errBlock fill:#FEE2E2,stroke:#000,stroke-width:2px;
    classDef recoverBlock fill:#D1FAE5,stroke:#000,stroke-width:2px;

    UserAction["User Action Triggered"]:::start --> TryBlock["Execute Operation (API / Storage / Firestore)"]:::tryBlock
    
    TryBlock --> Success{"Operation\nSucceeded?"}
    Success -- Yes --> CommitState["Commit State & Notify Listeners"]:::recoverBlock
    
    Success -- No --> CatchBlock{"Error Type"}:::errBlock
    
    %% Error Taxonomy
    CatchBlock -->|Network Timeout / Offline| OfflineRecovery["Display Offline NeoSnackBar\nOffer Local Retry Action"]:::recoverBlock
    CatchBlock -->|FirebaseAuthException| AuthRecovery["Translate Code (e.g. user-not-found)\nSurface Friendly Form Error"]:::recoverBlock
    CatchBlock -->|Supabase Storage Error| StorageRecovery["Rollback Image State\nRetain Previous Photo / Avatar"]:::recoverBlock
    CatchBlock -->|Validation Error| ValidationRecovery["Mark Invalid Form Fields\nHighlight Out-of-Range Metrics"]:::recoverBlock
    CatchBlock -->|Camera Permission Denied| PermissionRecovery["Present Permission Request Dialog\nOffer Gallery Pick Alternative"]:::recoverBlock
    CatchBlock -->|Zero Food Detected| ZeroDetectionRecovery["Navigate to DetectionConfirmation\nOpen FoodSearchModal for Manual Entry"]:::recoverBlock

    OfflineRecovery --> UIUpdate["Update UI with Friendly Guidance"]
    AuthRecovery --> UIUpdate
    StorageRecovery --> UIUpdate
    ValidationRecovery --> UIUpdate
    PermissionRecovery --> UIUpdate
    ZeroDetectionRecovery --> UIUpdate
```

---

## 2. Granular Recovery Scenarios

### 2.1 Profile Photo Upload Error & State Rollback
When uploading a new photo to Supabase fails due to network outage or timeout:
1. `ProfileProvider.updateProfilePhoto()` intercepts the exception.
2. The transient photo preview is rolled back.
3. The previous `_user.photoUrl` and `_user.photoPath` remain completely untouched.
4. An error message (`Gagal memperbarui foto profil.`) is dispatched via `NeoSnackBars.error(context, ...)` without crash or state corruption.

### 2.2 Camera Permission Rejection Recovery
If the user denies camera access during food scanning:
```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Camera as CameraService
    participant UI as ScannerScreen
    participant Picker as ImagePicker (Gallery)

    User->>UI: Tap "Scan Makanan"
    UI->>Camera: Request Camera Permissions
    Camera-->>UI: Permission Denied
    UI->>User: Shows NeoDialog ("Izin Kamera Diperlukan")
    User->>UI: Tap "Pilih dari Galeri"
    UI->>Picker: Open Android Photo Picker
    Picker-->>UI: Selected Image File
    UI->>UI: Proceed to YOLO26n Inference Pipeline
```

### 2.3 Zero-Detection Fallback
If YOLO26n detects no recognized food classes in the image (e.g. poor lighting, non-food item):
1. The scanner pipeline navigates to `DetectionConfirmationScreen` with an empty detection array.
2. A prominent banner displays: `Tidak ada makanan yang terdeteksi otomatis`.
3. An action button triggers `FoodSearchModal`, allowing the user to search the 100+ item local nutrition database and manually add food items with custom portion sizes.
