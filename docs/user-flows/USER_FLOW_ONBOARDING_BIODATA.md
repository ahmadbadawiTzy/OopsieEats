# User Flow: Mandatory Onboarding & Physical Biodata

## 1. Onboarding Gate & Biodata Flow

```mermaid
flowchart TD
    classDef startEnd fill:#F59E0B,stroke:#000,stroke-width:2px;
    classDef formNode fill:#FEF3C7,stroke:#000,stroke-width:2px;
    classDef calcNode fill:#BBF7D0,stroke:#000,stroke-width:2px;
    classDef errNode fill:#FCA5A5,stroke:#000,stroke-width:2px;

    Entry(["User Enters CompleteProfileScreen\n(Routes.completeProfile)"]):::startEnd --> Form["UnifiedBiodataForm\n(mode: BiodataFormMode.onboarding)"]:::formNode

    Form --> HeaderBanner["Educational Rationale Banner:\n'Satu Langkah Terakhir!'"]
    
    HeaderBanner --> FieldInputs["User Completes Required Fields:\n1. Nama Lengkap (min 2 chars)\n2. Jenis Kelamin (Segmented Chips)\n3. Tanggal Lahir (DatePicker)\n4. Tinggi Badan (100 - 250 cm)\n5. Berat Badan (30 - 300 kg)\n6. Tingkat Aktivitas (4 Matrix Cards)\n7. Target Gizi (3 Matrix Cards)\n8. Profesi / Pekerjaan"]:::formNode

    FieldInputs --> LiveAge["Live Age Badge Updates:\nDerived dynamically from Date of Birth"]
    
    LiveAge --> SubmitBtn["Tap 'Simpan & Lanjutkan'"]
    
    SubmitBtn --> ValidationCheck{"Form Validation\nPassed?"}
    
    ValidationCheck -- No --> ValidationErrors["Highlight Invalid Inputs\nSurface NeoSnackBar Warning"]:::errNode
    ValidationErrors --> FieldInputs

    ValidationCheck -- Yes --> CalculateMetrics["Calculate Deterministic Daily Targets:\n- Basal Metabolic Rate (BMR)\n- Total Daily Energy Expenditure (TDEE)\n- Macro Distribution (Protein, Carbs, Fat)"]:::calcNode

    CalculateMetrics --> PersistFirestore["Write to Cloud Firestore:\n- users/{uid} (is_profile_complete = true)\n- users/{uid}/profile/current\n- users/{uid}/daily_targets/current"]:::calcNode

    PersistFirestore --> SyncProviders["Synchronize Providers:\n- AuthProvider (isProfileComplete = true)\n- ProfileProvider (cached targets & user)\n- DashboardProvider (refreshed progress)"]

    SyncProviders --> RouteUnlock["Route Guard Automatically\nUnlocks & Navigates to /dashboard"]:::startEnd
```

---

## 2. Parity Comparison: Onboarding vs Edit Mode

NutriView uses a single unified form (`UnifiedBiodataForm`) to ensure 100% UI and validation parity across both onboarding and profile management.

| Aspect | Onboarding Mode (`CompleteProfileScreen`) | Edit Mode (`BiodataScreen`) |
| :--- | :--- | :--- |
| **Route Path** | `/complete-profile` | `/biodata` |
| **Form Mode** | `BiodataFormMode.onboarding` | `BiodataFormMode.edit` |
| **Initial Inputs** | Clean blank fields (Zero dummy values) | Pre-filled with saved metrics from Firestore |
| **Hero Card Copy** | *"Satu Langkah Terakhir!"* | *"Informasi Fisik & Kesehatan"* |
| **Primary Button** | `Simpan & Lanjutkan` (with `arrowForward` icon) | `Simpan Perubahan Biodata` (with `save` icon) |
| **Secondary Action** | `Ganti Akun / Keluar` (Sign out shortcut) | `Hapus Biodata Fisik` (with destructive confirmation) |
| **Exit Navigation** | Unlocks Route Guard to `/dashboard` | `Navigator.pop()` back to `/profile` |
| **Dynamic Age Pill** | Instant pill badge derived from DatePicker | Instant pill badge derived from DatePicker |
| **Validation Rules** | Strict: Height (100-250cm), Weight (30-300kg) | Identical strict validation |

---

## 3. Physical Metric Formulas (Harris-Benedict / Mifflin-St Jeor)

$$\text{BMR}_{\text{male}} = 10 \times \text{weight (kg)} + 6.25 \times \text{height (cm)} - 5 \times \text{age} + 5$$

$$\text{BMR}_{\text{female}} = 10 \times \text{weight (kg)} + 6.25 \times \text{height (cm)} - 5 \times \text{age} - 161$$

$$\text{TDEE} = \text{BMR} \times \text{Activity Multiplier}$$

Where Activity Multipliers are:
- Sedentary: $1.2$
- Lightly Active: $1.375$
- Moderately Active: $1.55$
- Very Active: $1.725$
