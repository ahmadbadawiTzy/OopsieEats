# User Flow: Meal History & Nutritional Tracking

## 1. Meal History Flow Diagram

```mermaid
flowchart TD
    classDef start fill:#F59E0B,stroke:#000,stroke-width:2px;
    classDef listNode fill:#FEF3C7,stroke:#000,stroke-width:2px;
    classDef detailNode fill:#BBF7D0,stroke:#000,stroke-width:2px;
    classDef deleteNode fill:#FCA5A5,stroke:#000,stroke-width:2px;

    Entry(["User Enters MealHistoryScreen (/history)"]):::start --> FetchHistory["MealHistoryProvider fetches logs\nfrom Cloud Firestore (paginated)"]
    
    FetchHistory --> ListUI["Renders Chronological Meal Feed:\n- Date Header & Daily Calorie Total\n- Meal Cards with NeoImageThumbnail\n- Meal Type Pill & Macro Badges"]:::listNode

    ListUI --> UserAction{"User Action"}
    
    UserAction -->|Filter by Date| DatePicker["Select Calendar Date\nFilter Stream by Selected Day"]:::listNode
    DatePicker --> ListUI

    UserAction -->|Pull to Refresh| RefreshStream["Force Sync with Firestore\nReload Image Signed URLs"]:::listNode
    RefreshStream --> ListUI

    UserAction -->|Tap Meal Card| MealDetail["Navigate to /meal-detail\n(Passes Meal Entity / mealId)"]:::detailNode

    MealDetail --> DetailUI["Renders Nutritional Breakdown:\n- High-Res Food Photo Preview\n- Total Calories & Energy Gauge\n- Macro Breakdown (Protein, Carbs, Fat)\n- Itemized Ingredient / Food Portions"]:::detailNode

    DetailUI --> DetailAction{"Detail Action"}
    
    DetailAction -->|Tap Back Button| ListUI
    
    DetailAction -->|Tap 'Hapus Makanan'| DeleteConfirm["Confirm Deletion Dialog\n'Hapus catatan makanan ini?'"]:::deleteNode
    
    DeleteConfirm -->|Cancel| DetailUI
    DeleteConfirm -->|Confirm| ExecDelete["Execute Deletion:\n1. Delete Firestore Document\n2. Delete Supabase Storage Image\n3. Deduct Macros from Daily Summary\n4. Invalidate Dashboard Cache"]:::deleteNode

    ExecDelete --> NavBack["Pop /meal-detail\nShow Success SnackBar"]:::start
    NavBack --> ListUI
```

---

## 2. Thumbnail & Asset Resilience (`NeoImageThumbnail`)
- When an image exists, it is loaded via a secure signed URL through `CachedNetworkImage` with a shimmer loading placeholder.
- If the image fails to load or the meal was logged without a photo, `NeoImageThumbnail` renders an elegant Material Rounded `restaurant` icon on a warm paper background, ensuring zero broken layouts.
