import ast
import os


def get_imports(filepath: str) -> list[str]:
    with open(filepath, "r", encoding="utf-8") as f:
        tree = ast.parse(f.read(), filename=filepath)

    imports = []
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                imports.append(alias.name)
        elif isinstance(node, ast.ImportFrom):
            if node.module:
                imports.append(node.module)
    return imports


def test_nutrition_service_architecture_boundaries():
    """
    docs/ai.md §2 & §17.1:
    nutrition_service DILARANG bergantung pada: app.ml, FastAPI, akses DB langsung.
    """
    path = os.path.join("app", "services", "nutrition_service.py")
    imports = get_imports(path)

    for imp in imports:
        assert not imp.startswith("app.ml"), f"nutrition_service cannot import app.ml ({imp})"
        assert not imp.startswith("fastapi"), f"nutrition_service cannot import fastapi ({imp})"
        assert not imp.startswith("sqlalchemy"), (
            f"nutrition_service cannot import sqlalchemy ({imp})"
        )
        assert not imp.startswith("app.db"), f"nutrition_service cannot import app.db ({imp})"
        assert not imp.startswith("app.models"), (
            f"nutrition_service cannot import app.models ({imp})"
        )


def test_ml_detector_architecture_boundaries():
    """
    docs/ai.md §2:
    app.ml.detector DILARANG bergantung pada: services, db, models.
    """
    path = os.path.join("app", "ml", "detector.py")
    imports = get_imports(path)

    for imp in imports:
        assert not imp.startswith("app.services"), f"detector.py cannot import app.services ({imp})"
        assert not imp.startswith("app.db"), f"detector.py cannot import app.db ({imp})"
        assert not imp.startswith("app.models"), f"detector.py cannot import app.models ({imp})"


def test_meal_service_architecture_boundaries():
    """
    docs/ai.md §2:
    meal_service DILARANG bergantung pada: app.ml.
    """
    path = os.path.join("app", "services", "meal_service.py")
    imports = get_imports(path)

    for imp in imports:
        assert not imp.startswith("app.ml"), f"meal_service cannot import app.ml ({imp})"
