# User Flow: Food Scanning & Nutritional Inference

## 1. Scanner & YOLO26n Inference Pipeline

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Scanner as ScannerScreen
    participant Worker as Background Isolate
    participant YOLO as YOLO26n Detector
    participant Confirm as DetectionConfirmationScreen
    participant Portion as PortionInputScreen
    participant Result as MealResultScreen
    participant Storage as Supabase Storage
    participant FS as Cloud Firestore
    participant Dash as DashboardScreen

    User->>Scanner: Taps "Scan Makanan"
    Scanner->>User: Displays Live Camera Viewport
    User->>Scanner: Taps Shutter (Capture Photo) or Gallery
    Scanner->>Scanner: Freezes frame & shows processing indicator
    
    Scanner->>Worker: Send image bytes to Isolate
    Worker->>YOLO: Preprocess image & run model inference
    YOLO-->>Worker: Raw tensors (boxes, classes, confidence)
    Worker->>Worker: Non-Maximum Suppression (NMS) & thresholding
    Worker-->>Scanner: Return normalized detections array
    
    Scanner->>Confirm: Push /detection-confirmation with image & detections
    Confirm->>User: Renders bounding boxes & detected food cards
    User->>Confirm: Adjusts detections (optional manual search)
    User->>Confirm: Taps "Lanjut ke Porsi"
    
    Confirm->>Portion: Push /portion-input
    Portion->>User: Renders portion inputs (grams / units)
    User->>Portion: Enters portion weights (validated > 0)
    User->>Portion: Taps "Hitung Nutrisi"
    
    Portion->>Result: Push /meal-result with calculated macros
    Result->>User: Renders Caloric Breakdown & Daily Target Comparison
    User->>Result: Taps "Simpan Makanan"
    
    par Save Binary Image
        Result->>Storage: Upload compressed image to {uid}/meals/
        Storage-->>Result: Return image_path & signed URL
    and Persist Firestore Document
        Result->>FS: setDoc('users/{uid}/meals/{mealId}')
        Result->>FS: updateDoc('users/{uid}/daily_summaries/{date}')
    end
    
    Result->>Dash: Navigate to /dashboard & refresh daily totals
```

---

## 2. Portion Input Validation & Formatter Standards
- **Initial Clean State:** Numeric portion fields start at `0` without misleading default estimates (e.g., 150g).
- **Direct Overwrite:** Tapping the input automatically selects all text, allowing immediate overwrite without typing `0150`.
- **Locale Sanitization:** Replaces European commas with decimal points (`12,5` $\rightarrow$ `12.5`).
- **Zero-Value Protection:** Rejects submission if portion is $\le 0$ grams, preventing distorted macronutrient logs.

---

## 3. Atwater Specific Physiological Factor System
Nutrient energy totals are calculated via deterministic Atwater equations:

$$\text{Calories (kcal)} = (4 \times \text{Protein (g)}) + (4 \times \text{Carbohydrates (g)}) + (9 \times \text{Fat (g)})$$
