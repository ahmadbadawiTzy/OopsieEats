# Application Role Access Flow

## 1. Role-Based Access Control (RBAC) Architecture

NutriView implements strict multi-tiered RBAC enforced at both the client-side Route Guard and the server-side Cloud Firestore Security Rules.

```mermaid
graph TD
    classDef public fill:#E2E8F0,stroke:#000,stroke-width:2px;
    classDef userRole fill:#BBF7D0,stroke:#000,stroke-width:2px;
    classDef adminRole fill:#FBCFE8,stroke:#000,stroke-width:2px;

    Client["Incoming App Request"] --> Auth{"Authenticated?"}
    
    Auth -- No --> Guest["Guest User"]:::public
    Guest --> AuthRoutes["Allowed: /login, /register, /splash"]
    
    Auth -- Yes --> RoleSwitch{"User Document\nrole field"}
    
    RoleSwitch -- "user" --> Consumer["Consumer Role"]:::userRole
    Consumer --> ConsumerRoutes["Allowed: /dashboard, /scanner, /history, /profile, /biodata, /articles"]
    Consumer --> RestrictAdmin["Blocked from /admin/* (Redirected to /dashboard)"]
    Consumer --> FirestoreUser["Firestore: Read/Write own /users/{uid}/*\nRead-only: /foods, /articles"]

    RoleSwitch -- "nutritionist" --> Specialist["Nutritionist Role"]:::userRole
    Specialist --> ConsumerRoutes
    Specialist --> SpecialistRights["Manage Assigned Nutrition Articles"]

    RoleSwitch -- "admin" --> Admin["Super Admin Role"]:::adminRole
    Admin --> ConsumerRoutes
    Admin --> AdminPortal["Allowed: /admin/dashboard\n- Food Database Management\n- Article Publishing\n- User Auditing\n- Audit Logs"]
    Admin --> FirestoreAdmin["Firestore: Full Access across collections\nAudit Log Write Only"]
```

---

## 2. Permission Matrix

| Capability / Resource | Guest | Standard User (`user`) | Nutritionist | Administrator (`admin`) |
| :--- | :---: | :---: | :---: | :---: |
| **View Splash & Auth Screens** | Yes | Yes | Yes | Yes |
| **Access Main Dashboard** | No | Yes | Yes | Yes |
| **Scan Food & On-Device YOLO** | No | Yes | Yes | Yes |
| **Log Meals & Upload Images** | No | Yes | Yes | Yes |
| **Read / Edit Own Profile** | No | Yes | Yes | Yes |
| **Read Nutrition Articles** | No | Yes | Yes | Yes |
| **Access Admin Dashboard (`/admin/dashboard`)** | No | No | No | Yes |
| **Create / Edit Food Catalog Items** | No | No | No | Yes |
| **Publish / Delete Articles** | No | No | Review Only | Yes |
| **View Audit Trail & System Logs** | No | No | No | Yes |
| **Change User Roles / Permissions** | No | No | No | Yes |

---

## 3. Server-Side Enforcement (Cloud Firestore Rules)

Client-side route guards are backed by declarative Firestore rules preventing tampering:

```javascript
// Firestore Security Rules Enforcement
match /foods/{foodId} {
  allow read: if request.auth != null;
  allow write: if isAdmin();
}

match /articles/{articleId} {
  allow read: if request.auth != null;
  allow write: if isAdmin();
}

match /users/{userId} {
  allow read: if isOwner(userId) || isAdmin();
  allow create: if isOwner(userId) && isValidUserCreate(userId);
  allow update: if (isOwner(userId) && isValidUserUpdateByOwner(userId)) || isAdmin();
  allow delete: if isAdmin();
}

match /audit_logs/{logId} {
  allow read: if isAdmin();
  allow create: if request.auth != null; // Append-only audit trail
  allow update, delete: if false; // Immutable audit log
}
```
