# User Flow: Authentication & Identity

## 1. Authentication Flow Diagram

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Login as LoginScreen
    participant Register as RegisterScreen
    participant AP as AuthProvider
    participant FA as Firebase Auth
    participant FS as Cloud Firestore
    participant Guard as RouteGuard

    alt Email & Password Login
        User->>Login: Enters Email & Password, taps "Masuk"
        Login->>AP: signInWithEmail(email, password)
        AP->>FA: signInWithEmailAndPassword()
        FA-->>AP: Returns UserCredential & JWT
        AP->>FS: getDoc('users/{uid}')
        FS-->>AP: Returns User profile document
        AP-->>Login: Authentication Success
        Login->>Guard: Evaluate Session State
    else Google OAuth Login
        User->>Login: Taps "Masuk dengan Google"
        Login->>AP: signInWithGoogle()
        AP->>FA: GoogleSignIn credential exchange
        FA-->>AP: Returns Google UserCredential
        AP->>FS: Check if 'users/{uid}' exists
        alt First-time Google User
            AP->>FS: Create base user document (is_profile_complete: false)
        else Returning Google User
            AP->>FS: Read existing user document
        end
        AP-->>Login: Google Auth Success
        Login->>Guard: Evaluate Session State
    else New Registration Flow
        User->>Login: Taps "Daftar Akun"
        Login->>Register: Push /register
        User->>Register: Enters Name, Email, Password, Confirm Password
        User->>Register: Taps "Daftar Sekarang"
        Register->>AP: register(email, password, fullName)
        AP->>FA: createUserWithEmailAndPassword()
        FA-->>AP: Returns new UserCredential
        AP->>FS: Create user document (role: 'user', is_profile_complete: false)
        AP-->>Register: Registration Success
        Register->>Guard: Evaluate Session State
    end

    alt Profile Incomplete (is_profile_complete == false)
        Guard->>User: Route to /complete-profile
    else Profile Complete (is_profile_complete == true)
        Guard->>User: Route to /dashboard
    end
```

---

## 2. Biometric Authentication & Password Fallback

```mermaid
flowchart TD
    Start(["Launch LoginScreen"]):::start --> BioCheck{"Biometric Available\n& Enrolled?"}
    
    BioCheck -- No --> StandardForm["Render Standard Email/Password Form"]
    
    BioCheck -- Yes --> QuickCard["Render Biometric Quick-Unlock Card"]
    QuickCard --> UserTap{"User Selection"}
    
    UserTap -- Tap Fingerprint / Face --> Prompt["Trigger Local Biometrics API"]
    Prompt --> BioResult{"Authentication\nSuccess?"}
    
    BioResult -- Yes --> TokenExchange["Unlock Stored Refresh Token\nAuthenticate Session"]
    TokenExchange --> RouteGuard["Evaluate Route Guard"]
    
    BioResult -- No / Cancel --> QuickCard
    
    UserTap -- Tap 'Masuk dengan Kata Sandi' --> StandardForm
    UserTap -- Tap 'Ganti Akun' --> SwitchModal["Confirm Switch Account Dialog"]
    SwitchModal --> PurgeLocalSession["Purge Cached Biometric Tokens\nReset to Blank Form"]
```

---

## 3. Password Recovery Flow
1. User taps `Lupa Kata Sandi?` on `LoginScreen`.
2. `ForgotPasswordModal` appears as a bottom sheet.
3. User enters registered email address and taps `Kirim Tautan Reset`.
4. Firebase Auth sends an out-of-band password reset email.
5. User receives a confirmation snackbar, and the modal safely dismisses.
