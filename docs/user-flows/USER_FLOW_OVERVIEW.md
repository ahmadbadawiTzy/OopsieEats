# User Flow: System Overview

## 1. Feature Map & Flow Index

The NutriView user journey is structured into 7 core functional feature modules:

```mermaid
mindmap
  root((NutriView App))
    Authentication
      Email / Password
      Google OAuth
      Biometric Fast Unlock
      Password Reset Modal
    Onboarding & Biodata
      Mandatory Onboarding Gate
      Unified Biodata Form
      Live Age Calculation
      Physical Metrics & Activity
      BMR & TDEE Target Generation
    Dashboard & Daily Targets
      Calorie Progress Wheel
      Macronutrient Breakdown (Protein, Carbs, Fat)
      Recent Meals Log
      Scan Floating Action CTA
    Food Scanner & ML Pipeline
      Camera Viewport & Gallery Picker
      On-Device YOLO26n Isolate
      Detection Confirmation & Bounding Boxes
      Portion Input (Gram / Unit)
      Meal Summary & Atwater Calculation
    Meal Tracking & History
      Paginated Daily Meal List
      Nutritional Breakdown Detail
      Image Thumbnail Caching
      Meal Deletion & Target Recalculation
    Profile & Settings
      Avatar & Custom Photo Picker
      Supabase Signed Image Storage
      Kelola Biodata (Unified Form Parity)
      Tentang Aplikasi & Developer Profile
    Administration
      Food Catalog CRUD
      Article Editorial System
      User Audit & Access Control
      System Audit Logs
```

---

## 2. Directory & Documentation Index

| Documentation File | Module Focus | Primary Flow & Sequence |
| :--- | :--- | :--- |
| `USER_FLOW_AUTHENTICATION.md` | Authentication | Sign-in, Register, Google OAuth, Biometric fast unlock. |
| `USER_FLOW_ONBOARDING_BIODATA.md` | Onboarding | Mandatory gate, UnifiedBiodataForm, zero-dummy inputs. |
| `USER_FLOW_PROFILE.md` | Profile & Identity | Photo upload, Supabase signed storage, edit biodata. |
| `USER_FLOW_FOOD_ANALYSIS.md` | Scanner & YOLO | Camera capture, background isolate ML, portion input. |
| `USER_FLOW_HISTORY.md` | Meal Records | History list, date filtering, meal detail breakdown. |
| `USER_FLOW_ADMIN.md` | Admin Portal | Food DB, article publishing, user audits. |
| `USER_FLOW_SYSTEM.md` | System Operations | App launch, token refresh, offline caching, error recovery. |
