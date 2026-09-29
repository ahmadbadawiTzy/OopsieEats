import csv
import os

import yaml


def test_classes_yaml_mapped_to_foods_seed():
    """
    docs/ai.md §17.1:
    Setiap kelas di ml/classes.yaml terpetakan ke satu makanan pada foods.csv
    """
    classes_path = os.path.abspath(os.path.join("..", "ml", "classes.yaml"))
    assert os.path.exists(classes_path), f"File {classes_path} not found"

    with open(classes_path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)

    classes_dict = data.get("names", {})
    yolo_classes = set(classes_dict.values())
    assert len(yolo_classes) >= 10, "Minimum 10 classes required for MVP"

    csv_path = os.path.abspath(os.path.join("app", "db", "seed", "foods.csv"))
    assert os.path.exists(csv_path), f"File {csv_path} not found"

    seed_yolo_classes = set()
    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            cls = row.get("yolo_class", "").strip()
            if cls:
                seed_yolo_classes.add(cls)

    # Every class in classes.yaml MUST exist in seed_yolo_classes
    missing_in_seed = yolo_classes - seed_yolo_classes
    assert not missing_in_seed, f"Classes in classes.yaml missing from foods.csv: {missing_in_seed}"
