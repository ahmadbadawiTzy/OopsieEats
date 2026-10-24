#!/usr/bin/env python3
"""
NutriView Firestore Migration & Seed Script.
Uploads seed foods, initial admin/users, categories, articles, and announcements
to Cloud Firestore (or Firestore Local Emulator).

Usage:
  # With Firestore Emulator:
  export FIRESTORE_EMULATOR_HOST="127.0.0.1:8080"
  export GCLOUD_PROJECT="nutriview-app"
  python scripts/migrate_to_firestore.py

  # With Live Firebase Service Account:
  export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
  python scripts/migrate_to_firestore.py
"""

import json
import os
import sys
from datetime import datetime, timezone

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print(
        "firebase-admin is required. Install via: pip install firebase-admin",
        file=sys.stderr,
    )
    sys.exit(1)


def init_firestore():
    if not firebase_admin._apps:
        cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
        project_id = os.environ.get("GCLOUD_PROJECT", "nutriview-app")

        if cred_path and os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred, {"projectId": project_id})
        else:
            # Emulator mode or default application credentials
            firebase_admin.initialize_app(options={"projectId": project_id})

    return firestore.client()


def seed_foods(db):
    print("--> Seeding foods...")
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    seed_json = os.path.join(repo_root, "frontend/assets/data/seed_foods.json")

    if not os.path.exists(seed_json):
        print(f"Error: {seed_json} not found", file=sys.stderr)
        return 0

    with open(seed_json, "r", encoding="utf-8") as f:
        foods = json.load(f)

    batch = db.batch()
    count = 0
    for item in foods:
        doc_ref = db.collection("foods").doc(str(item["id"]))
        doc_data = {
            "id": int(item["id"]),
            "name": str(item["name"]),
            "yolo_class": str(item.get("yolo_class") or ""),
            "is_active": bool(item.get("is_active", True)),
            "calories_kcal_per_100g": (
                float(item["calories_kcal_per_100g"])
                if item.get("calories_kcal_per_100g") is not None
                else None
            ),
            "protein_g_per_100g": (
                float(item["protein_g_per_100g"])
                if item.get("protein_g_per_100g") is not None
                else None
            ),
            "carbs_g_per_100g": (
                float(item["carbs_g_per_100g"])
                if item.get("carbs_g_per_100g") is not None
                else None
            ),
            "fat_g_per_100g": (
                float(item["fat_g_per_100g"])
                if item.get("fat_g_per_100g") is not None
                else None
            ),
            "source": str(item.get("source") or "TKPI 2020"),
            "has_nutrition_data": bool(item.get("has_nutrition_data", True)),
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
        batch.set(doc_ref, doc_data)
        count += 1

    batch.commit()
    print(f"    Successfully seeded {count} foods.")
    return count


def seed_users(db):
    print("--> Seeding default admin and user profiles...")
    users = [
        {
            "uid": "super_admin_nutriview",
            "id": 1,
            "email": "admin@nutriview.id",
            "full_name": "Super Administrator NutriView",
            "role": "super_admin",
            "is_active": True,
            "created_at": datetime.now(timezone.utc).isoformat(),
        },
        {
            "uid": "dietitian_nutriview",
            "id": 2,
            "email": "dietitian@nutriview.id",
            "full_name": "Dr. Nutrisi Klinis",
            "role": "dietitian",
            "is_active": True,
            "created_at": datetime.now(timezone.utc).isoformat(),
        },
        {
            "uid": "demo_user_nutriview",
            "id": 3,
            "email": "user@nutriview.id",
            "full_name": "Pengguna NutriView",
            "role": "user",
            "is_active": True,
            "profile": {
                "age": 28,
                "sex": "male",
                "weight_kg": 68.0,
                "height_cm": 172.0,
                "activity_level": "moderate",
                "goal": "maintain_weight",
            },
            "daily_target": {
                "calories_kcal": 2200,
                "protein_g": 80.0,
                "carbs_g": 270.0,
                "fat_g": 60.0,
                "bmr_kcal": 1620.0,
                "tdee_kcal": 2200.0,
            },
            "created_at": datetime.now(timezone.utc).isoformat(),
        },
    ]

    for u in users:
        db.collection("users").doc(u["uid"]).set(u)
    print(f"    Successfully seeded {len(users)} users.")


def seed_cms(db):
    print("--> Seeding CMS categories, articles, and announcements...")
    categories = [
        {"id": 1, "name": "Edukasi Gizi", "slug": "edukasi-gizi"},
        {"id": 2, "name": "Tips Pola Makan", "slug": "tips-pola-makan"},
        {"id": 3, "name": "Resep Sehat", "slug": "resep-sehat"},
    ]
    for cat in categories:
        cat["created_at"] = datetime.now(timezone.utc).isoformat()
        db.collection("cms_categories").doc(str(cat["id"])).set(cat)

    articles = [
        {
            "id": 1,
            "title": "Pedoman Gizi Seimbang & Piring Makanku",
            "slug": "pedoman-gizi-seimbang",
            "category_id": 1,
            "category_name": "Edukasi Gizi",
            "author_id": 2,
            "author_name": "Dr. Nutrisi Klinis",
            "status": "published",
            "excerpt": "Ketahui cara membagi piring makan harian Anda dengan proporsi 50% sayur dan buah, 25% karbohidrat, dan 25% protein.",
            "content_markdown": """# Pedoman Gizi Seimbang

Konsep **Piring Makanku** adalah acuan sajian sekali makan dari Kementerian Kesehatan Republik Indonesia:

- **1/3 piring**: Makanan pokok (nasi, jagung, kentang, ubi).
- **1/3 piring**: Sayur-mayur aneka warna.
- **1/6 piring**: Lauk-pauk berprotein (ikan, telur, ayam, tahu, tempe).
- **1/6 piring**: Buah-buahan segar.

### Kunci Sehat
Minum air putih minimal 8 gelas sehari, cuci tangan sebelum makan, dan batasi konsumsi gula, garam, serta lemak.
""",
            "published_at": datetime.now(timezone.utc).isoformat(),
            "created_at": datetime.now(timezone.utc).isoformat(),
        },
        {
            "id": 2,
            "title": "Mengenal Kebutuhan Kalori Harian (BMR & TDEE)",
            "slug": "kebutuhan-kalori-bmr-tdee",
            "category_id": 2,
            "category_name": "Tips Pola Makan",
            "author_id": 2,
            "author_name": "Dr. Nutrisi Klinis",
            "status": "published",
            "excerpt": "Rumus Mifflin-St Jeor menghitung energi dasar yang dibutuhkan tubuh saat istirahat untuk menjaga metabolisme stabil.",
            "content_markdown": """# Memahami BMR & TDEE

Setiap individu memiliki laju metabolisme basal (*Basal Metabolic Rate*) dan kebutuhan energi harian (*Total Daily Energy Expenditure*).

Dengan mengetahui kebutuhan kalori harian yang akurat, Anda dapat merencanakan penurunan atau peningkatan berat badan secara sehat dan berkelanjutan.
""",
            "published_at": datetime.now(timezone.utc).isoformat(),
            "created_at": datetime.now(timezone.utc).isoformat(),
        },
    ]
    for art in articles:
        db.collection("cms_articles").doc(str(art["id"])).set(art)

    announcements = [
        {
            "id": 1,
            "title": "Selamat Datang di NutriView Firebase Engine!",
            "message": "NutriView kini ditenagai oleh On-Device AI YOLO26n dan Firebase Cloud Firestore untuk pelacakan nutrisi instan tanpa internet.",
            "type": "info",
            "is_active": True,
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
    ]
    for ann in announcements:
        db.collection("cms_announcements").doc(str(ann["id"])).set(ann)

    # Initial audit log
    db.collection("cms_audit_logs").doc("initial_migration").set({
        "id": 1,
        "user_id": 1,
        "user_email": "admin@nutriview.id",
        "action": "bootstrap",
        "entity_type": "system",
        "entity_id": "firestore_migration",
        "details": "Initialized Firestore database collections with seed foods, admin users, and CMS content.",
        "created_at": datetime.now(timezone.utc).isoformat(),
    })
    print("    Successfully seeded CMS categories, articles, announcements, and audit log.")


def main():
    print("==================================================")
    print("   NutriView Cloud Firestore Migration Tool       ")
    print("==================================================")
    db = init_firestore()
    seed_foods(db)
    seed_users(db)
    seed_cms(db)
    print("==================================================")
    print(" Migration to Firestore completed successfully!   ")
    print("==================================================")


if __name__ == "__main__":
    main()
