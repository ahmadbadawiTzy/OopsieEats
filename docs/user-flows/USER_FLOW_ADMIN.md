# User Flow: Administrative Console & CMS

## 1. Admin Portal Flow Diagram

```mermaid
flowchart TD
    classDef start fill:#F59E0B,stroke:#000,stroke-width:2px;
    classDef authCheck fill:#FCA5A5,stroke:#000,stroke-width:2px;
    classDef adminTab fill:#E9D5FF,stroke:#000,stroke-width:2px;
    classDef opNode fill:#BBF7D0,stroke:#000,stroke-width:2px;

    Entry(["User Enters /admin/dashboard"]):::start --> GuardCheck{"Is Authenticated\n& role == 'admin'?"}:::authCheck
    
    GuardCheck -- No --> Reject["Access Denied:\nRedirect to /dashboard"]
    
    GuardCheck -- Yes --> ResponsiveShell["AdminDashboardShell:\n- Mobile: App Bar with Hamburger Drawer\n- Desktop (>=900px): Persistent Sidebar"]:::adminTab

    ResponsiveShell --> SectionSwitch{"Selected Section"}
    
    %% Section 1: Food Catalog
    SectionSwitch -->|Katalog Makanan| FoodCatalog["Food Catalog Management:\n- Search & Filter Foods\n- Real-time Firestore Stream"]:::adminTab
    FoodCatalog --> FoodAction{"Action"}
    FoodAction -->|Tambah / Edit| FoodForm["Food Entry Form:\n- Name & Category\n- Portion grams\n- Calories, Protein, Carbs, Fat\n- Atwater Consistency Check"]:::opNode
    FoodForm --> SaveFood["Write to /foods/{id}\nLog to /audit_logs"]:::opNode
    FoodAction -->|Hapus Makanan| DeleteFood["Delete from /foods\nLog to /audit_logs"]:::opNode

    %% Section 2: Articles
    SectionSwitch -->|Manajemen Artikel| ArticleCMS["Article Management System:\n- Published & Draft Articles\n- Featured Hero Selection"]:::adminTab
    ArticleCMS --> ArticleAction{"Action"}
    ArticleAction -->|Buat / Edit Artikel| ArticleEditor["Markdown Content Editor\nTagging & Cover Image Upload"]:::opNode
    ArticleEditor --> SaveArticle["Write to /articles/{id}\nLog to /audit_logs"]:::opNode

    %% Section 3: Users
    SectionSwitch -->|Manajemen Pengguna| UserAudit["User Directory & Audit:\n- Inspect User Roles\n- Profile Completion Status\n- Active / Banned State"]:::adminTab
    UserAudit --> UserUpdate["Update Role (User/Nutritionist/Admin)\nToggle Account State"]:::opNode

    %% Section 4: Audit Logs
    SectionSwitch -->|Log Audit Sistem| AuditLogs["Immutable Audit Trail Viewer:\n- Timestamp, Actor UID, Action Type\n- IP / User-Agent metadata"]:::adminTab

    %% Switcher to Consumer UI
    ResponsiveShell -->|Beralih ke Tampilan Pengguna| ConsumerUI["Navigate to /dashboard\n(Consumer Experience)"]:::start
```

---

## 2. Server-Side Security & Audit Invariants
1. **Atwater Mathematical Validation:** New food items created in the admin portal must satisfy the energy balance equation:
   $$\left|\text{Calories} - (4 \times \text{Protein} + 4 \times \text{Carbs} + 9 \times \text{Fat})\right| \le 5.0\text{ kcal}$$
   Mismatched values are rejected prior to Firestore commitment.
2. **Append-Only Audit Logs:** The `/audit_logs` collection can only be written to by authenticated admins and cannot be updated or deleted by any user or administrator, guaranteeing complete forensic integrity.
