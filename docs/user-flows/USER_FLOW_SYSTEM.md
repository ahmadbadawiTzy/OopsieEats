# User Flow: System Boot, Session Lifecycle & Recovery

## 1. System Boot & Startup Sequence

```mermaid
sequenceDiagram
    autonumber
    participant Engine as Flutter Engine
    participant Main as main.dart
    participant Splash as SplashScreen
    participant Auth as AuthProvider
    participant Profile as ProfileProvider
    participant Supabase as SupabaseStorageService
    participant Router as RouteGuard

    Engine->>Main: runApp(NutriViewApp)
    Main->>Main: Initialize Firebase, Supabase, Date Formatting
    Main->>Main: Instantiate MultiProvider Tree
    Main->>Splash: Mount SplashScreen (Routes.splash)
    
    Splash->>Auth: checkAuthStatus()
    Auth->>Auth: Inspect Firebase currentUser & Local Token
    
    alt Unauthenticated
        Auth-->>Splash: isAuthenticated = false
        Splash->>Router: Navigate to /login (Clear Navigation Stack)
    else Authenticated
        Auth->>Profile: loadProfile()
        Profile->>Profile: Fetch users/{uid} & users/{uid}/profile
        
        opt Profile Image Exists
            Profile->>Supabase: refreshPhotoUrlIfNeeded(photo_path)
            Supabase-->>Profile: Fresh 1-hour signed URL
        end
        
        Profile-->>Splash: Profile loaded
        
        alt isProfileComplete == false
            Splash->>Router: Navigate to /complete-profile
        else isProfileComplete == true
            Splash->>Router: Navigate to /dashboard
        end
    end
```

---

## 2. Session Invariants & Security Architecture

1. **Deterministic Boot Route:** Regardless of the previous screen prior to app closure, the application always initializes through `SplashScreen` (`/`). This ensures session tokens, remote user profiles, and storage signed URLs are verified before any user screen renders.
2. **Infinite Loop Immunity:**
   - In earlier builds, if `_currentUser` was null when launching directly to `/complete-profile`, updating the profile would silently fail and cause an infinite redirect loop.
   - The hardened `AuthProvider.updateProfile()` instantiates a valid `User` model on demand, and the route guard checks composite completeness (`auth.isProfileComplete || profileProvider.isProfileComplete`), guaranteeing that saving biodata immediately unlocks the dashboard.
3. **Graceful Degradation:**
   - When device connectivity drops, the on-device YOLO26n food scanner continues to operate seamlessly because the model and inference pipeline run completely locally in a Dart `Isolate`.
   - Firestore provides offline persistence for previously fetched meal history and dashboard metrics.
