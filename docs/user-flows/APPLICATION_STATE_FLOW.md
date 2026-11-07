# Application State Flow

## 1. Multi-Provider State Architecture

NutriView utilizes Provider (`ChangeNotifier`) for reactive state management, maintaining clear state boundaries and decoupled lifecycle domains across the application.

```mermaid
graph TD
    classDef providerNode fill:#DBEAFE,stroke:#1E40AF,stroke-width:2px;
    classDef uiNode fill:#FEF3C7,stroke:#B45309,stroke-width:2px;
    classDef actionNode fill:#D1FAE5,stroke:#065F46,stroke-width:2px;

    subgraph "Authentication & Session Domain"
        AP["AuthProvider"]:::providerNode
        AP_State["_currentUser\n_token\n_isProfileComplete\n_isBiometricEnrolled"]
        AP --- AP_State
    end

    subgraph "User & Biometrics Domain"
        PP["ProfileProvider"]:::providerNode
        PP_State["_user (photo_url, photo_path)\n_profile (age, sex, height, weight)\n_dailyTarget (BMR, TDEE, macros)"]
        PP --- PP_State
    end

    subgraph "Nutrition & Food Scanner Domain"
        SFP["ScanFlowProvider"]:::providerNode
        SFP_State["_capturedImage\n_detectedBoxes & classes\n_portionMap (grams)\n_calculatedMacros"]
        SFP --- SFP_State
    end

    subgraph "Dashboard & Consumption Analytics"
        DP["DashboardProvider"]:::providerNode
        DP_State["_dailyDashboard (calories, protein, carbs, fat)\n_recentMeals\n_streakCount"]
        DP --- DP_State
    end

    subgraph "Meal History Domain"
        MHP["MealHistoryProvider"]:::providerNode
        MHP_State["_meals (paginated list)\n_selectedDate\n_isDeleting"]
        MHP --- MHP_State
    end

    %% State Cross-Synchronization
    AP -->|Session Token & UID| PP
    AP -->|Session Token & UID| DP
    AP -->|Session Token & UID| MHP

    PP -->|Updated Daily Targets| DP
    
    SFP -->|Meal Saved Event| DP
    SFP -->|Meal Saved Event| MHP

    %% UI Binding
    LoginUI["LoginScreen"]:::uiNode --> AP
    CompleteProfileUI["CompleteProfileScreen"]:::uiNode --> PP
    CompleteProfileUI --> AP
    DashboardUI["DashboardScreen"]:::uiNode --> DP
    DashboardUI --> PP
    ScannerUI["ScannerScreen / PortionInputScreen"]:::uiNode --> SFP
    HistoryUI["MealHistoryScreen"]:::uiNode --> MHP
    ProfileUI["ProfileScreen / BiodataScreen"]:::uiNode --> PP
    ProfileUI --> AP
```

---

## 2. State Mutation & Cross-Provider Synchronization

### 2.1 Profile Completion & Synchronization Flow
When a user completes their physical biodata in either `CompleteProfileScreen` (onboarding) or `BiodataScreen` (edit mode):

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Form as UnifiedBiodataForm
    participant PP as ProfileProvider
    participant PRepo as ProfileRepository
    participant AP as AuthProvider
    participant DP as DashboardProvider
    participant FS as Cloud Firestore

    User->>Form: Taps "Simpan & Lanjutkan"
    Form->>Form: Validates Inputs (Height, Weight, Age, Gender)
    Form->>PP: saveBiodata(fullName, newProfile)
    PP->>PRepo: saveBiodata(...)
    PRepo->>FS: set('users/{uid}', merge: true)
    PRepo->>FS: set('users/{uid}/profile', data)
    PRepo->>PRepo: calculateDailyTarget(profile)
    PRepo-->>PP: Returns Updated UserProfile & DailyTarget
    
    PP->>AP: updateProfile(newProfile)
    Note over AP: Updates _currentUser.profile and sets isProfileComplete = true
    
    PP->>DP: loadDashboard() (if mounted)
    Note over DP: Recalculates remaining calories with new BMR/TDEE targets
    
    PP-->>Form: Returns success = true
    Form->>Form: Calls onSavedSuccessfully()
    Note over Form: Route Guard unlocks /dashboard
```

### 2.2 Profile Photo Lifecycle State Management
```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Screen as ProfileScreen
    participant PP as ProfileProvider
    participant PRepo as ProfileRepository
    participant SS as SupabaseStorageService
    participant FS as Cloud Firestore

    User->>Screen: Selects photo from Gallery / Camera
    Screen->>PP: updateProfilePhoto(imageBytes)
    PP->>PP: Set isLoading = true, notifyListeners()
    PP->>PRepo: updateProfilePhoto(imageBytes)
    PRepo->>SS: compressProfilePhoto(rawBytes) [512x512]
    PRepo->>SS: uploadProfilePhoto(uid, compressedBytes)
    SS-->>PRepo: Returns storagePath ('uid/profile/profile_timestamp.jpg')
    PRepo->>SS: createSignedUrl(storagePath, expiresIn: 3600)
    SS-->>PRepo: Returns temporary signed photoUrl
    PRepo->>FS: update('users/{uid}', {photo_path, photo_url})
    PRepo-->>PP: Returns updated User instance
    PP->>PP: _user = updatedUser, isLoading = false, notifyListeners()
    PP-->>Screen: Success
    Screen->>User: Displays newly uploaded avatar
```
