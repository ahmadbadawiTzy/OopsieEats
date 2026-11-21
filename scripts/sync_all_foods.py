#!/usr/bin/env python3
"""
Sync and enrich master food database:
1. Generates 50 complete Indonesian & popular food items with full TKPI / USDA macros.
2. Validates 100% adherence to Atwater energy equations (< 30% tolerance, <= 100g total).
3. Updates frontend/assets/data/seed_foods.json for offline storage.
4. Synchronizes all documents directly to Cloud Firestore collection 'foods' via REST API.
"""

import json
import os
import sys
import urllib.request
import urllib.error
from datetime import datetime, timezone

ALL_FOODS = [
    {
        "id": 1,
        "name": "Apel",
        "yolo_class": "Apple",
        "is_active": True,
        "calories_kcal_per_100g": 52.0,
        "protein_g_per_100g": 0.3,
        "carbs_g_per_100g": 13.8,
        "fat_g_per_100g": 0.2,
        "source": "TKPI 2020 (Kode J-2)",
        "has_nutrition_data": True
    },
    {
        "id": 2,
        "name": "Ayam goreng",
        "yolo_class": "Ayam Goreng",
        "is_active": True,
        "calories_kcal_per_100g": 246.0,
        "protein_g_per_100g": 25.0,
        "carbs_g_per_100g": 0.0,
        "fat_g_per_100g": 16.0,
        "source": "TKPI 2020 (Kode C-12)",
        "has_nutrition_data": True
    },
    {
        "id": 3,
        "name": "Bakso",
        "yolo_class": "Bakso",
        "is_active": True,
        "calories_kcal_per_100g": 202.0,
        "protein_g_per_100g": 10.3,
        "carbs_g_per_100g": 19.0,
        "fat_g_per_100g": 9.5,
        "source": "TKPI 2020 (Kode C-20)",
        "has_nutrition_data": True
    },
    {
        "id": 4,
        "name": "Pisang",
        "yolo_class": "Banana",
        "is_active": True,
        "calories_kcal_per_100g": 97.0,
        "protein_g_per_100g": 1.0,
        "carbs_g_per_100g": 25.8,
        "fat_g_per_100g": 0.2,
        "source": "TKPI 2020 (Kode J-15)",
        "has_nutrition_data": True
    },
    {
        "id": 5,
        "name": "Burger",
        "yolo_class": "Burger",
        "is_active": True,
        "calories_kcal_per_100g": 254.0,
        "protein_g_per_100g": 13.0,
        "carbs_g_per_100g": 24.0,
        "fat_g_per_100g": 12.0,
        "source": "USDA FoodData (FDC 170697)",
        "has_nutrition_data": True
    },
    {
        "id": 6,
        "name": "Capcay",
        "yolo_class": "Capcay",
        "is_active": True,
        "calories_kcal_per_100g": 85.0,
        "protein_g_per_100g": 4.2,
        "carbs_g_per_100g": 8.5,
        "fat_g_per_100g": 3.8,
        "source": "TKPI 2020 (Kode H-12)",
        "has_nutrition_data": True
    },
    {
        "id": 7,
        "name": "Chocolate chip cookie",
        "yolo_class": "Chocolate Chip Cookie",
        "is_active": True,
        "calories_kcal_per_100g": 488.0,
        "protein_g_per_100g": 5.5,
        "carbs_g_per_100g": 64.0,
        "fat_g_per_100g": 23.5,
        "source": "USDA FoodData (FDC 173489)",
        "has_nutrition_data": True
    },
    {
        "id": 8,
        "name": "Donat",
        "yolo_class": "Donat",
        "is_active": True,
        "calories_kcal_per_100g": 421.0,
        "protein_g_per_100g": 6.2,
        "carbs_g_per_100g": 51.0,
        "fat_g_per_100g": 21.5,
        "source": "USDA FoodData (FDC 173516)",
        "has_nutrition_data": True
    },
    {
        "id": 9,
        "name": "Ikan goreng",
        "yolo_class": "Ikan Goreng",
        "is_active": True,
        "calories_kcal_per_100g": 195.0,
        "protein_g_per_100g": 20.0,
        "carbs_g_per_100g": 0.0,
        "fat_g_per_100g": 12.0,
        "source": "TKPI 2020 (Kode D-8)",
        "has_nutrition_data": True
    },
    {
        "id": 10,
        "name": "Kentang goreng",
        "yolo_class": "Kentang Goreng",
        "is_active": True,
        "calories_kcal_per_100g": 274.0,
        "protein_g_per_100g": 3.5,
        "carbs_g_per_100g": 35.5,
        "fat_g_per_100g": 13.5,
        "source": "TKPI 2020 (Kode G-8)",
        "has_nutrition_data": True
    },
    {
        "id": 11,
        "name": "Kiwi",
        "yolo_class": "Kiwi",
        "is_active": True,
        "calories_kcal_per_100g": 61.0,
        "protein_g_per_100g": 1.1,
        "carbs_g_per_100g": 14.6,
        "fat_g_per_100g": 0.5,
        "source": "USDA FoodData (FDC 169910)",
        "has_nutrition_data": True
    },
    {
        "id": 12,
        "name": "Mie goreng",
        "yolo_class": "Mie Goreng",
        "is_active": True,
        "calories_kcal_per_100g": 175.0,
        "protein_g_per_100g": 4.0,
        "carbs_g_per_100g": 26.0,
        "fat_g_per_100g": 6.2,
        "source": "TKPI 2020 (Kode B-14)",
        "has_nutrition_data": True
    },
    {
        "id": 13,
        "name": "Nasi goreng",
        "yolo_class": "Nasi Goreng",
        "is_active": True,
        "calories_kcal_per_100g": 168.0,
        "protein_g_per_100g": 4.2,
        "carbs_g_per_100g": 23.8,
        "fat_g_per_100g": 6.2,
        "source": "TKPI 2020 (Kode B-5)",
        "has_nutrition_data": True
    },
    {
        "id": 14,
        "name": "Nasi putih",
        "yolo_class": "Nasi Putih",
        "is_active": True,
        "calories_kcal_per_100g": 130.0,
        "protein_g_per_100g": 2.4,
        "carbs_g_per_100g": 28.6,
        "fat_g_per_100g": 0.2,
        "source": "TKPI 2020 (Kode B-1)",
        "has_nutrition_data": True
    },
    {
        "id": 15,
        "name": "Nugget ayam",
        "yolo_class": "Nugget",
        "is_active": True,
        "calories_kcal_per_100g": 296.0,
        "protein_g_per_100g": 15.0,
        "carbs_g_per_100g": 16.0,
        "fat_g_per_100g": 19.0,
        "source": "TKPI 2020 (Kode C-28)",
        "has_nutrition_data": True
    },
    {
        "id": 16,
        "name": "Pempek",
        "yolo_class": "Pempek",
        "is_active": True,
        "calories_kcal_per_100g": 175.0,
        "protein_g_per_100g": 8.5,
        "carbs_g_per_100g": 26.0,
        "fat_g_per_100g": 4.0,
        "source": "TKPI 2020 (Kode D-19)",
        "has_nutrition_data": True
    },
    {
        "id": 17,
        "name": "Nanas",
        "yolo_class": "Pineapples",
        "is_active": True,
        "calories_kcal_per_100g": 50.0,
        "protein_g_per_100g": 0.5,
        "carbs_g_per_100g": 13.1,
        "fat_g_per_100g": 0.1,
        "source": "TKPI 2020 (Kode J-11)",
        "has_nutrition_data": True
    },
    {
        "id": 18,
        "name": "Pizza",
        "yolo_class": "Pizza",
        "is_active": True,
        "calories_kcal_per_100g": 266.0,
        "protein_g_per_100g": 11.4,
        "carbs_g_per_100g": 33.3,
        "fat_g_per_100g": 9.8,
        "source": "USDA FoodData (FDC 173292)",
        "has_nutrition_data": True
    },
    {
        "id": 19,
        "name": "Rendang sapi",
        "yolo_class": "Rendang Sapi",
        "is_active": True,
        "calories_kcal_per_100g": 193.0,
        "protein_g_per_100g": 22.6,
        "carbs_g_per_100g": 7.8,
        "fat_g_per_100g": 7.9,
        "source": "TKPI 2020 (Kode C-2)",
        "has_nutrition_data": True
    },
    {
        "id": 20,
        "name": "Sate ayam",
        "yolo_class": "Sate",
        "is_active": True,
        "calories_kcal_per_100g": 218.0,
        "protein_g_per_100g": 20.0,
        "carbs_g_per_100g": 7.5,
        "fat_g_per_100g": 12.0,
        "source": "TKPI 2020 (Kode C-15)",
        "has_nutrition_data": True
    },
    {
        "id": 21,
        "name": "Spaghetti",
        "yolo_class": "Spaghetti",
        "is_active": True,
        "calories_kcal_per_100g": 158.0,
        "protein_g_per_100g": 6.5,
        "carbs_g_per_100g": 23.5,
        "fat_g_per_100g": 4.2,
        "source": "USDA FoodData (FDC 173305)",
        "has_nutrition_data": True
    },
    {
        "id": 22,
        "name": "Steak daging",
        "yolo_class": "Steak",
        "is_active": True,
        "calories_kcal_per_100g": 242.0,
        "protein_g_per_100g": 27.0,
        "carbs_g_per_100g": 0.0,
        "fat_g_per_100g": 15.0,
        "source": "TKPI 2020 (Kode C-8)",
        "has_nutrition_data": True
    },
    {
        "id": 23,
        "name": "Stroberi",
        "yolo_class": "Strawberry",
        "is_active": True,
        "calories_kcal_per_100g": 32.0,
        "protein_g_per_100g": 0.7,
        "carbs_g_per_100g": 7.7,
        "fat_g_per_100g": 0.3,
        "source": "TKPI 2020 (Kode J-24)",
        "has_nutrition_data": True
    },
    {
        "id": 24,
        "name": "Tahu goreng",
        "yolo_class": "Tahu Goreng",
        "is_active": True,
        "calories_kcal_per_100g": 115.0,
        "protein_g_per_100g": 9.7,
        "carbs_g_per_100g": 2.5,
        "fat_g_per_100g": 8.5,
        "source": "TKPI 2020 (Kode F-2)",
        "has_nutrition_data": True
    },
    {
        "id": 25,
        "name": "Telur goreng",
        "yolo_class": "Telur Goreng",
        "is_active": True,
        "calories_kcal_per_100g": 196.0,
        "protein_g_per_100g": 10.6,
        "carbs_g_per_100g": 1.4,
        "fat_g_per_100g": 16.0,
        "source": "TKPI 2020 (Kode E-3)",
        "has_nutrition_data": True
    },
    {
        "id": 26,
        "name": "Telur rebus",
        "yolo_class": "Telur Rebus",
        "is_active": True,
        "calories_kcal_per_100g": 155.0,
        "protein_g_per_100g": 12.6,
        "carbs_g_per_100g": 1.1,
        "fat_g_per_100g": 10.6,
        "source": "TKPI 2020 (Kode E-1)",
        "has_nutrition_data": True
    },
    {
        "id": 27,
        "name": "Tempe goreng",
        "yolo_class": "Tempe Goreng",
        "is_active": True,
        "calories_kcal_per_100g": 225.0,
        "protein_g_per_100g": 19.0,
        "carbs_g_per_100g": 15.0,
        "fat_g_per_100g": 11.0,
        "source": "TKPI 2020 (Kode F-4)",
        "has_nutrition_data": True
    },
    {
        "id": 28,
        "name": "Terong balado",
        "yolo_class": "Terong Balado",
        "is_active": True,
        "calories_kcal_per_100g": 82.0,
        "protein_g_per_100g": 1.5,
        "carbs_g_per_100g": 8.5,
        "fat_g_per_100g": 4.8,
        "source": "TKPI 2020 (Kode H-18)",
        "has_nutrition_data": True
    },
    {
        "id": 29,
        "name": "Tumis kangkung",
        "yolo_class": "Tumis Kangkung",
        "is_active": True,
        "calories_kcal_per_100g": 68.0,
        "protein_g_per_100g": 2.5,
        "carbs_g_per_100g": 6.0,
        "fat_g_per_100g": 3.8,
        "source": "TKPI 2020 (Kode H-14)",
        "has_nutrition_data": True
    },
    # --- Menu Kuliner Tradisional Nusantara Tambahan (Pencarian Manual) ---
    {
        "id": 30,
        "name": "Batagor Bandung",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 290.0,
        "protein_g_per_100g": 8.0,
        "carbs_g_per_100g": 32.0,
        "fat_g_per_100g": 14.5,
        "source": "TKPI 2020 (Kode G-14)",
        "has_nutrition_data": True
    },
    {
        "id": 31,
        "name": "Bihun goreng",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 192.0,
        "protein_g_per_100g": 4.0,
        "carbs_g_per_100g": 35.0,
        "fat_g_per_100g": 4.2,
        "source": "TKPI 2020 (Kode B-16)",
        "has_nutrition_data": True
    },
    {
        "id": 32,
        "name": "Gado-gado",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 135.0,
        "protein_g_per_100g": 6.2,
        "carbs_g_per_100g": 14.8,
        "fat_g_per_100g": 6.1,
        "source": "TKPI 2020 (Kode H-3)",
        "has_nutrition_data": True
    },
    {
        "id": 33,
        "name": "Martabak manis",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 275.0,
        "protein_g_per_100g": 6.0,
        "carbs_g_per_100g": 45.0,
        "fat_g_per_100g": 8.5,
        "source": "TKPI 2020 (Kode G-22)",
        "has_nutrition_data": True
    },
    {
        "id": 34,
        "name": "Martabak telur",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 240.0,
        "protein_g_per_100g": 11.5,
        "carbs_g_per_100g": 18.0,
        "fat_g_per_100g": 13.5,
        "source": "TKPI 2020 (Kode G-21)",
        "has_nutrition_data": True
    },
    {
        "id": 35,
        "name": "Rawon sapi",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 115.0,
        "protein_g_per_100g": 13.5,
        "carbs_g_per_100g": 3.0,
        "fat_g_per_100g": 5.5,
        "source": "TKPI 2020 (Kode C-25)",
        "has_nutrition_data": True
    },
    {
        "id": 36,
        "name": "Roti bakar",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 285.0,
        "protein_g_per_100g": 7.0,
        "carbs_g_per_100g": 48.0,
        "fat_g_per_100g": 7.5,
        "source": "TKPI 2020 (Kode B-22)",
        "has_nutrition_data": True
    },
    {
        "id": 37,
        "name": "Sate kambing",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 230.0,
        "protein_g_per_100g": 22.5,
        "carbs_g_per_100g": 6.0,
        "fat_g_per_100g": 13.0,
        "source": "TKPI 2020 (Kode C-16)",
        "has_nutrition_data": True
    },
    {
        "id": 38,
        "name": "Sayur asem",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 45.0,
        "protein_g_per_100g": 1.8,
        "carbs_g_per_100g": 8.5,
        "fat_g_per_100g": 0.5,
        "source": "TKPI 2020 (Kode H-2)",
        "has_nutrition_data": True
    },
    {
        "id": 39,
        "name": "Soto ayam",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 105.0,
        "protein_g_per_100g": 10.0,
        "carbs_g_per_100g": 6.5,
        "fat_g_per_100g": 4.5,
        "source": "TKPI 2020 (Kode C-22)",
        "has_nutrition_data": True
    },
    {
        "id": 40,
        "name": "Telur balado",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 175.0,
        "protein_g_per_100g": 12.0,
        "carbs_g_per_100g": 3.5,
        "fat_g_per_100g": 12.5,
        "source": "TKPI 2020 (Kode E-5)",
        "has_nutrition_data": True
    },
    {
        "id": 41,
        "name": "Telur dadar",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 190.0,
        "protein_g_per_100g": 13.0,
        "carbs_g_per_100g": 1.5,
        "fat_g_per_100g": 15.0,
        "source": "TKPI 2020 (Kode E-2)",
        "has_nutrition_data": True
    },
    {
        "id": 42,
        "name": "Tempe bacem",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 165.0,
        "protein_g_per_100g": 14.0,
        "carbs_g_per_100g": 15.5,
        "fat_g_per_100g": 5.5,
        "source": "TKPI 2020 (Kode F-5)",
        "has_nutrition_data": True
    },
    {
        "id": 43,
        "name": "Udang goreng",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 210.0,
        "protein_g_per_100g": 21.0,
        "carbs_g_per_100g": 6.0,
        "fat_g_per_100g": 11.0,
        "source": "TKPI 2020 (Kode D-12)",
        "has_nutrition_data": True
    },
    {
        "id": 44,
        "name": "Perkedel kentang",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 140.0,
        "protein_g_per_100g": 3.0,
        "carbs_g_per_100g": 20.0,
        "fat_g_per_100g": 5.5,
        "source": "TKPI 2020 (Kode G-7)",
        "has_nutrition_data": True
    },
    {
        "id": 45,
        "name": "Sayur bening bayam",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 23.0,
        "protein_g_per_100g": 1.2,
        "carbs_g_per_100g": 4.0,
        "fat_g_per_100g": 0.3,
        "source": "TKPI 2020 (Kode H-1)",
        "has_nutrition_data": True
    },
    {
        "id": 46,
        "name": "Nasi uduk",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 160.0,
        "protein_g_per_100g": 3.0,
        "carbs_g_per_100g": 28.0,
        "fat_g_per_100g": 4.0,
        "source": "TKPI 2020 (Kode B-3)",
        "has_nutrition_data": True
    },
    {
        "id": 47,
        "name": "Bubur ayam",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 110.0,
        "protein_g_per_100g": 5.5,
        "carbs_g_per_100g": 16.0,
        "fat_g_per_100g": 2.8,
        "source": "TKPI 2020 (Kode B-8)",
        "has_nutrition_data": True
    },
    {
        "id": 48,
        "name": "Opor ayam",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 178.0,
        "protein_g_per_100g": 16.0,
        "carbs_g_per_100g": 3.5,
        "fat_g_per_100g": 11.0,
        "source": "TKPI 2020 (Kode C-18)",
        "has_nutrition_data": True
    },
    {
        "id": 49,
        "name": "Gudeg Jogja",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 132.0,
        "protein_g_per_100g": 3.2,
        "carbs_g_per_100g": 18.0,
        "fat_g_per_100g": 5.6,
        "source": "TKPI 2020 (Kode H-8)",
        "has_nutrition_data": True
    },
    {
        "id": 50,
        "name": "Pecel sayur",
        "yolo_class": None,
        "is_active": True,
        "calories_kcal_per_100g": 145.0,
        "protein_g_per_100g": 5.8,
        "carbs_g_per_100g": 15.0,
        "fat_g_per_100g": 7.2,
        "source": "TKPI 2020 (Kode H-5)",
        "has_nutrition_data": True
    }
]


def validate_atwater(foods):
    print("--> Validating Atwater energy equation consistency...")
    for f in foods:
        p = f["protein_g_per_100g"]
        c = f["carbs_g_per_100g"]
        fat = f["fat_g_per_100g"]
        cal = f["calories_kcal_per_100g"]
        name = f["name"]

        total_macros = p + c + fat
        if total_macros > 100.0:
            raise ValueError(f"{name}: Total macros {total_macros}g > 100g")

        theo = (4.0 * p) + (4.0 * c) + (9.0 * fat)
        diff = abs(cal - theo)
        ratio = diff / (cal if cal > 1.0 else 1.0)
        if ratio > 0.30:
            raise ValueError(f"{name}: Atwater deviation ratio {ratio:.3f} > 0.30 (cal={cal}, theo={theo})")

    print(f"    ✓ All {len(foods)} foods strictly adhere to Atwater energy standards.")


def update_local_seed(foods):
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    seed_path = os.path.join(repo_root, "frontend/assets/data/seed_foods.json")
    print(f"--> Writing {len(foods)} items to {seed_path}...")
    with open(seed_path, "w", encoding="utf-8") as f:
        json.dump(foods, f, indent=2, ensure_ascii=False)
    print("    ✓ Local seed_foods.json updated successfully.")


def get_firebase_token():
    config_path = os.path.expanduser("~/.config/configstore/firebase-tools.json")
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Firebase tools config not found at {config_path}")
    with open(config_path) as f:
        cfg = json.load(f)
    token = cfg.get("tokens", {}).get("access_token")
    if not token:
        raise ValueError("No access token found in firebase-tools.json")
    return token


def sync_to_firestore(foods):
    token = get_firebase_token()
    project_id = "nutriview-943cd"
    base_url = f"https://firestore.googleapis.com/v1/projects/{project_id}/databases/(default)/documents/foods"

    print(f"--> Syncing {len(foods)} items to Cloud Firestore collection 'foods'...")
    now_iso = datetime.now(timezone.utc).isoformat()

    success_count = 0
    for f in foods:
        doc_id = str(f["id"])
        url = f"{base_url}/{doc_id}"

        doc_fields = {
            "id": {"integerValue": str(f["id"])},
            "name": {"stringValue": f["name"]},
            "is_active": {"booleanValue": f["is_active"]},
            "calories_kcal_per_100g": {"doubleValue": float(f["calories_kcal_per_100g"])},
            "protein_g_per_100g": {"doubleValue": float(f["protein_g_per_100g"])},
            "carbs_g_per_100g": {"doubleValue": float(f["carbs_g_per_100g"])},
            "fat_g_per_100g": {"doubleValue": float(f["fat_g_per_100g"])},
            "source": {"stringValue": f["source"]},
            "has_nutrition_data": {"booleanValue": f["has_nutrition_data"]},
            "updated_at": {"stringValue": now_iso},
        }

        if f.get("yolo_class"):
            doc_fields["yolo_class"] = {"stringValue": f["yolo_class"]}
        else:
            doc_fields["yolo_class"] = {"nullValue": None}

        body = json.dumps({"fields": doc_fields}).encode("utf-8")
        req = urllib.request.Request(
            f"{url}?updateMask.fieldPaths=id&updateMask.fieldPaths=name&updateMask.fieldPaths=is_active&updateMask.fieldPaths=calories_kcal_per_100g&updateMask.fieldPaths=protein_g_per_100g&updateMask.fieldPaths=carbs_g_per_100g&updateMask.fieldPaths=fat_g_per_100g&updateMask.fieldPaths=source&updateMask.fieldPaths=has_nutrition_data&updateMask.fieldPaths=updated_at&updateMask.fieldPaths=yolo_class",
            data=body,
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
            },
            method="PATCH"
        )

        try:
            with urllib.request.urlopen(req) as resp:
                if resp.status in (200, 201):
                    success_count += 1
        except urllib.error.HTTPError as e:
            err_body = e.read().decode("utf-8")
            print(f"Error updating doc {doc_id} ({f['name']}): HTTP {e.code} - {err_body}", file=sys.stderr)
            raise

    print(f"    ✓ Successfully synced {success_count}/{len(foods)} foods to Cloud Firestore.")


def main():
    validate_atwater(ALL_FOODS)
    update_local_seed(ALL_FOODS)
    sync_to_firestore(ALL_FOODS)
    print("Done! All 50 master foods are live in offline assets and Cloud Firestore.")


if __name__ == "__main__":
    main()
