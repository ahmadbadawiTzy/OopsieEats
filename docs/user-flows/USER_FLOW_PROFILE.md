# User Flow: Profile & Photo Management

## 1. Profile Screen Flow

```mermaid
flowchart TD
    classDef start fill:#F59E0B,stroke:#000,stroke-width:2px;
    classDef photoNode fill:#C4B5FD,stroke:#000,stroke-width:2px;
    classDef formNode fill:#FEF3C7,stroke:#000,stroke-width:2px;
    classDef exitNode fill:#FCA5A5,stroke:#000,stroke-width:2px;

    Profile["ProfileScreen (/profile)"]:::start --> UserInteractions{"User Interaction"}

    %% Photo Management Sub-flow
    UserInteractions -->|Tap Avatar / Camera Badge| AvatarSheet["Avatar Selection BottomSheet\n- Ambil Foto (Kamera)\n- Pilih dari Galeri (Photo Picker)\n- Pilih Preset Avatar\n- Hapus Foto Profil (if active)"]:::photoNode

    AvatarSheet -->|Kamera / Galeri| ImageSelection["User Selects / Captures Image"]:::photoNode
    ImageSelection --> ClientCompress["Client-side Crop 1:1 &\nCompress to 512x512 JPEG"]:::photoNode
    ClientCompress --> SupabaseUpload["Upload to Supabase Storage:\n/nutriview-media/{uid}/profile/profile_*.jpg"]:::photoNode
    SupabaseUpload --> GenerateSignedURL["Generate Scoped Signed URL\n(expires_in: 3600 seconds)"]:::photoNode
    GenerateSignedURL --> UpdateFirestore["Update Firestore users/{uid}:\n- photo_path\n- photo_url"]:::photoNode
    UpdateFirestore --> RefreshAvatarState["ProfileProvider & AuthProvider Updated\nUI Immediately Rerenders Avatar"]:::photoNode

    AvatarSheet -->|Hapus Foto| ConfirmDelete["Confirm Delete Dialog"]:::photoNode
    ConfirmDelete --> DeleteStorage["Delete from Supabase Storage\nNullify photo_path in Firestore"]:::photoNode
    DeleteStorage --> FallbackInitials["Revert to Colorful Initial Avatar"]:::photoNode

    %% Biodata Management Sub-flow
    UserInteractions -->|Tap 'Kelola Biodata'| BiodataRoute["Navigate to /biodata\n(UnifiedBiodataForm Edit Mode)"]:::formNode
    BiodataRoute --> PrePopulatedForm["Form Pre-filled with Saved Metrics"]:::formNode
    PrePopulatedForm --> SaveOrDelete{"User Action"}
    SaveOrDelete -->|Simpan Perubahan| Recalculate["Recalculate BMR/TDEE & Update Firestore"]:::formNode
    SaveOrDelete -->|Hapus Biodata Fisik| ConfirmBiodataDelete["Confirm Destructive Wipe Dialog"]:::formNode
    ConfirmBiodataDelete --> ResetProfile["Wipe Physical Metrics from Firestore"]:::formNode

    %% About & System Sub-flow
    UserInteractions -->|Tap 'Tentang Aplikasi'| AboutRoute["Navigate to /about\n- Creator Profile (Ahmad Badawi)\n- Social & Portfolio Links (Copy on Tap)\n- App Version & Architecture"]

    %% Logout Sub-flow
    UserInteractions -->|Tap 'Keluar Akun'| LogoutModal["Confirm Logout Dialog"]:::exitNode
    LogoutModal --> PurgeSession["Sign out Firebase Auth\nClear Local Preferences\nRoute to /login"]:::exitNode
```

---

## 2. Avatar Rendering Hierarchy

The `UserProfileAvatar` widget guarantees an intuitive visual presentation across all network conditions:

```mermaid
graph TD
    Start["Render UserProfileAvatar"] --> CheckPhoto{"Does user have\nphotoUrl?"}
    
    CheckPhoto -- Yes --> RenderNetwork["Render CachedNetworkImage\n(Using Supabase Signed URL)"]
    RenderNetwork --> LoadSuccess{"Image Load\nSuccess?"}
    LoadSuccess -- Yes --> DisplayImage["Display Custom Profile Photo"]
    LoadSuccess -- No / Expired --> RefreshSignedURL["Trigger refreshPhotoUrlIfNeeded()\nFallback to Initial temporarily"]
    
    CheckPhoto -- No --> CheckPreset{"Does user have\navatarPreset?"}
    CheckPreset -- Yes --> RenderPreset["Render NeoAvatar\n(Vector Character Illustration)"]
    CheckPreset -- No --> RenderInitials["Render High-Contrast Initial Badge\n(Derived deterministically from Name)"]
```

---

## 3. Persistence Across App Restarts
- **Cloud Reference:** `photo_path` is permanently saved to `users/{uid}` in Cloud Firestore.
- **Signed URL Resolution:** On cold startup or re-login, `ProfileRepository.refreshPhotoUrlIfNeeded()` checks the signed URL expiration. If stale, it requests a fresh signed token from Supabase Storage without requiring the user to re-upload.
