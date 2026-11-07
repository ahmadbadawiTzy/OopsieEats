# Application Master Flow

## 1. Executive Master Flow

The Master Flow maps the complete lifecycle of a NutriView session from cold launch, authentication check, mandatory onboarding guard, primary dashboard interactions, food scanning inference, meal persistence, and administrative delegation.

```mermaid
flowchart TD
    %% Styling
    classDef startEnd fill:#F59E0B,stroke:#000,stroke-width:2px,color:#000;
    classDef authNode fill:#FDE047,stroke:#000,stroke-width:2px,color:#000;
    classDef guardNode fill:#F87171,stroke:#000,stroke-width:2px,color:#000;
    classDef dashNode fill:#34D399,stroke:#000,stroke-width:2px,color:#000;
    classDef scanNode fill:#60A5FA,stroke:#000,stroke-width:2px,color:#000;
    classDef adminNode fill:#C084FC,stroke:#000,stroke-width:2px,color:#000;

    Start(["App Launch (Cold / Warm)"]):::startEnd --> Splash["SplashScreen\n(Check Token & Firebase Session)"]
    
    Splash --> AuthCheck{"Active User\nSession?"}
    
    %% Unauthenticated Branch
    AuthCheck -- No --> AuthRoute["/login\nLogin Screen"]:::authNode
    AuthRoute --> LoginAction{"User Action"}
    LoginAction -->|Email & Password| SubmitLogin["Authenticate via Firebase Auth"]
    LoginAction -->|Google Sign-In| SubmitGoogle["Google OAuth Credential Exchange"]
    LoginAction -->|New User| RegisterRoute["/register\nRegister Screen"]:::authNode
    LoginAction -->|Forgot Password| ForgotModal["ForgotPasswordModal"]:::authNode
    LoginAction -->|Biometric Stored| BiometricUnlock["Local Biometric Prompt"]:::authNode

    RegisterRoute --> RegisterSubmit["Create Account & Set Default Role"]
    RegisterSubmit --> RouteGuardCheck
    SubmitLogin --> RouteGuardCheck
    SubmitGoogle --> RouteGuardCheck
    BiometricUnlock --> RouteGuardCheck

    %% Authenticated Branch
    AuthCheck -- Yes --> RouteGuardCheck{"Route Guard:\nisProfileComplete?"}:::guardNode

    RouteGuardCheck -- No --> CompleteProfile["/complete-profile\nUnifiedBiodataForm (Onboarding)"]:::guardNode
    CompleteProfile --> SaveBiodata["Save Biodata (Firestore)\nCalculate Daily Targets (BMR/TDEE)"]
    SaveBiodata --> SyncAuthState["Sync Auth & Profile State"]
    SyncAuthState --> DashboardRoute["/dashboard\nMain Dashboard Screen"]:::dashNode

    RouteGuardCheck -- Yes --> RoleCheck{"User Role?"}
    RoleCheck -- Admin --> AdminPrompt{"Direct to Admin\nor Consumer UI?"}
    AdminPrompt -- Admin Console --> AdminRoute["/admin/dashboard\nAdmin Console Screen"]:::adminNode
    AdminPrompt -- Consumer UI --> DashboardRoute
    RoleCheck -- User / Nutritionist --> DashboardRoute

    %% Main Consumer Interactions
    DashboardRoute --> ConsumerAction{"User Journey"}
    
    %% Scanner Journey
    ConsumerAction -->|Tap Scan Food| ScannerRoute["/scanner\nCamera Viewport"]:::scanNode
    ScannerRoute --> CaptureOrPick["Capture Photo / Pick Gallery"]:::scanNode
    CaptureOrPick --> YOLOInference["On-Device YOLO26n Inference\n(Background Isolate)"]:::scanNode
    YOLOInference --> DetectionConfirm["/detection-confirmation\nReview Detected Items"]:::scanNode
    DetectionConfirm --> PortionInput["/portion-input\nGram / Portion Weight Entry"]:::scanNode
    PortionInput --> MacroCalculation["Calculate Calories & Macros\n(Atwater Formula)"]:::scanNode
    MacroCalculation --> MealResult["/meal-result\nAnalysis Summary"]:::scanNode
    MealResult --> SaveMealToCloud["Save to Firestore & Supabase Storage"]:::scanNode
    SaveMealToCloud --> RefreshDashboard["Invalidate & Refresh Dashboard Cache"]
    RefreshDashboard --> DashboardRoute

    %% Meal History Journey
    ConsumerAction -->|Tap Riwayat| HistoryRoute["/history\nMeal History Screen"]
    HistoryRoute --> ViewMealDetail["/meal-detail\nInspect Nutritional Breakdown"]
    ViewMealDetail --> DeleteMeal{"Delete Meal?"}
    DeleteMeal -- Yes --> DeleteFromFirestore["Delete Document & Storage Image"]
    DeleteMeal -- No --> HistoryRoute

    %% Profile & Biodata Journey
    ConsumerAction -->|Tap Profil| ProfileRoute["/profile\nUser Profile Screen"]
    ProfileRoute --> ProfileAction{"Manage Profile"}
    ProfileAction -->|Update Photo| PhotoPicker["Android Photo Picker / Camera"]
    PhotoPicker --> CompressUpload["Compress 512x512 & Upload Supabase"]
    CompressUpload --> UpdateFirestoreUser["Update Firestore photo_path & signed URL"]
    ProfileAction -->|Kelola Biodata| EditBiodata["/biodata\nUnifiedBiodataForm (Edit Mode)"]
    EditBiodata --> UpdateBiodata["Recalculate BMR/TDEE & Update Firestore"]
    ProfileAction -->|Tentang Aplikasi| AboutRoute["/about\nCreator Profile & App Info"]
    ProfileAction -->|Logout| ClearSession["Sign Out & Purge Local Cache"]
    ClearSession --> AuthRoute
```

---

## 2. Key Transitions & Milestones

1. **Deterministic App Initialization:** `SplashScreen` verifies Firebase Auth persistent token, loads user profile from Firestore, checks biometric availability, and resolves profile image signed URLs.
2. **Onboarding Gatekeeper:** If `is_profile_complete == false`, the route guard halts navigation to `/dashboard` and forces entry into `/complete-profile`. Only completing the `UnifiedBiodataForm` unlocks the main dashboard.
3. **Seamless Food Analysis:** The food scanning journey isolates ML inference to keep UI rendering smooth, validates nutrition values according to the Atwater physiological fuel factor system, and writes meal logs atomically.
4. **Resilient Session State:** When users update profile photo or physical biodata, changes immediately propagate to `AuthProvider`, `ProfileProvider`, and `DashboardProvider`.
