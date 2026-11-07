# SUPABASE STORAGE INTEGRATION — FOOD DETECTION HISTORY IMAGES
**NutriView Mobile Application (Flutter / Firebase / Supabase Storage)**

---

## 1. Executive Summary & Architectural Scope

NutriView retains **Firebase** as its primary, authoritative backend ecosystem:
- **Firebase Authentication:** Sole identity provider managing user registration, logins, tokens, and sessions.
- **Firebase Firestore:** Primary application database storing user profiles, dietary targets, nutrition database, meal detection history, YOLO26n bounding boxes/confidence scores, and timestamps.
- **On-Device YOLO26n:** Neural network food inference runs strictly offline on the client device without sending images to external inference APIs.

**Supabase Storage** is used **EXCLUSIVELY** for binary image file storage of food detection photos:
- Bucket: `food-history-images` (**Private bucket**).
- Project Name: `nutriview-storage`
- Project Ref: `rnfvudxqcwcwilcyicow`
- Region: `ap-southeast-1` (Singapore)
- URL: `https://rnfvudxqcwcwilcyicow.supabase.co`
- Public Key: `sb_publishable_zkmZHcq6D4fTB1L9qvIvYw_izbuSHDj`
- No Supabase Database, Auth, or Edge Functions are utilized.
- No sensitive keys (`service_role`) are embedded in client code. The Flutter client only uses the public `publishableKey` with Firebase JWT token exchange.

---

## 2. Directory & Path Specification

All food inspection photos are stored in Supabase Storage with strict user and meal folder isolation:

```
food-history-images/
  └── {userId}/
        └── {mealId}/
              └── food_{timestamp}.jpg
```

### Component Details
| Component | Value / Source | Description |
| :--- | :--- | :--- |
| `bucket` | `food-history-images` | Private Supabase Storage bucket with RLS enabled |
| `{userId}` | Firebase User UID (`auth.currentUser.uid`) | Strict root partition ensuring multi-tenant data isolation |
| `{mealId}` | Millisecond Epoch timestamp | Unique identifier matching the Firestore meal record ID |
| `food_{timestamp}.jpg` | Epoch timestamp string | Compressed JPEG inspection image |

---

## 3. Image Metadata Schema in Firestore

In Cloud Firestore, the `meals/{mealId}` document stores a lightweight image metadata object under the `image` field:

```json
{
  "id": 1741334400000,
  "meal_type": "lunch",
  "consumed_at": "2026-11-07T12:30:00.000Z",
  "consumed_date": "2026-11-07",
  "image": {
    "provider": "supabase_storage",
    "bucket": "food-history-images",
    "path": "aB3dEfGh123/1741334400000/food_1741334400123.jpg",
    "width": 1024,
    "height": 768,
    "size_bytes": 142580,
    "mime_type": "image/jpeg",
    "created_at": "2026-11-07T12:30:01.000Z"
  },
  "items": [ ... ],
  "totals": { ... }
}
```

### Backward Compatibility
Historical records created before this feature, or manual meal entries created without a camera/gallery scan, have `image: null` (or omitted `image` field). The data model `MealRecord.fromJson` deserializes this safely without NPE, and the UI displays a clean Neo-Brutalist fallback icon with zero layout shift.

---

## 4. Supabase Storage Row Level Security (RLS) Policies

To enforce that users can only upload, read, and delete their own images using their Firebase Authentication credentials, the following SQL must be executed in the Supabase project SQL Editor:

```sql
-- 1. Create the private storage bucket if not already present
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'food-history-images',
  'food-history-images',
  false,
  5242880, -- 5 MB max
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = false,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];

-- 2. Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 3. Policy: Allow users to SELECT / read their own images
-- Verifies that the first path segment matches the Firebase UID in the JWT
CREATE POLICY "Users can view their own food images"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'food-history-images'
  AND (
    (auth.jwt()->>'sub') = (storage.foldername(name))[1]
    OR (auth.jwt()->>'user_id') = (storage.foldername(name))[1]
  )
);

-- 4. Policy: Allow users to INSERT / upload their own images
CREATE POLICY "Users can upload their own food images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'food-history-images'
  AND (
    (auth.jwt()->>'sub') = (storage.foldername(name))[1]
    OR (auth.jwt()->>'user_id') = (storage.foldername(name))[1]
  )
);

-- 5. Policy: Allow users to UPDATE their own images
CREATE POLICY "Users can update their own food images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'food-history-images'
  AND (
    (auth.jwt()->>'sub') = (storage.foldername(name))[1]
    OR (auth.jwt()->>'user_id') = (storage.foldername(name))[1]
  )
);

-- 6. Policy: Allow users to DELETE their own images
CREATE POLICY "Users can delete their own food images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'food-history-images'
  AND (
    (auth.jwt()->>'sub') = (storage.foldername(name))[1]
    OR (auth.jwt()->>'user_id') = (storage.foldername(name))[1]
  )
);
```

---

## 5. Client Processing & Performance Pipeline

### A. Background Isolate Image Compression
Before uploading, the raw camera/gallery image is processed in an independent Dart isolate via `Isolate.run(() => _compressImageWorker(imageBytes))` (`SupabaseStorageService`):
1. Decodes full-resolution bitmap bytes.
2. Checks dimensions: if `width > 1024` or `height > 1024`, downscales maintaining aspect ratio with linear interpolation.
3. Encodes as JPEG with quality factor `80`.
4. Enforces hard file size limit (5 MB).
5. Eliminates main-thread UI frame drops and jank during scan confirmation.

### B. In-Memory Signed URL Cache with TTL
Because `food-history-images` is a private bucket, viewing images requires generating signed URLs (`createSignedUrl`).
- Default expiration: 1 hour (`SupabaseConfig.signedUrlTtl`).
- `SupabaseStorageService` maintains an in-memory cache map: `path -> (url, expiresAt)`.
- If a cached signed URL has more than 10 minutes of remaining validity, it is returned synchronously without triggering an HTTP round-trip to Supabase.
- Prevents redundant cryptographic signing requests during list scrolling and widget rebuilds.

### C. Error Resilience & Rollback Patterns
1. **Network / Supabase Upload Failure:**
   - If image upload fails (timeout, quota, connectivity), the failure is caught and logged.
   - The meal submission proceeds to Firestore with `imageMetadata: null`.
   - **Crucial Rule:** Nutrition logging and YOLO detection data are never lost due to storage network errors.
2. **Firestore Write Failure (Orphan Rollback):**
   - If the image upload succeeds but the subsequent Firestore `createMeal()` document creation fails, `storageService.deleteFoodImage(uploadedMetadata.path)` is triggered immediately to clean up the orphaned binary file.
3. **Meal Record Deletion (Cascading):**
   - When a user deletes a meal history record via `MealRepository.deleteMeal()`, the associated image in Supabase Storage is deleted concurrently.
4. **Account Deletion (Purge):**
   - When a user requests account deletion via `AuthRepository.deleteAccount()`, Stage 2d purges the entire user storage directory (`{userId}/`) recursively from Supabase Storage.

---

## 6. Neo-Brutalism UI Components

1. **`NeoImageThumbnail` (`lib/shared/widgets/neo_image_thumbnail.dart`):**
   - 64x64 compact container rendered in each history card.
   - Solid 2px black border, hard offset shadow (`Offset(2, 2)`), rounded corners.
   - Shows loading indicator while signed URL resolves.
   - Shows `AppIcons.restaurant` fallback if image is null or unavailable.
2. **`NeoImageHeroCard` (`lib/shared/widgets/neo_image_thumbnail.dart`):**
   - 4:3 aspect ratio full-width card positioned above nutritional macros in `MealDetailScreen`.
   - Features "Foto Pemeriksaan" badge and fullscreen icon.
   - Interactive zoom & preview dialog with `InteractiveViewer`.
