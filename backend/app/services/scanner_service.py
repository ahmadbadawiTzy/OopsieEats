import logging
from typing import Any, Dict, List, Union

from sqlalchemy.orm import Session

from app.core.config import settings
from app.services.food_service import get_food_by_yolo_class

logger = logging.getLogger("nutriview.scanner")


def process_detections(
    db: Session,
    raw_detections: Union[List[Dict[str, Any]], Dict[str, Any]],
) -> Dict[str, Any]:
    """
    Processes raw detections from YOLO26n model:
    1. Maps class_name to active food item (ignores unsupported/unmapped classes with WARNING).
    2. Merges duplicates per food item, keeping highest confidence.
    3. Flags low_confidence if confidence < DETECTION_LOW_CONFIDENCE_THRESHOLD.
    4. Sorts descending by confidence, limited to MAX_DETECTED_ITEMS (10).
    5. Returns dict with detections list and low_confidence_threshold.
    """
    if isinstance(raw_detections, dict):
        detection_list = raw_detections.get("detections", [])
    else:
        detection_list = raw_detections

    food_best_confidence: Dict[int, Dict[str, Any]] = {}

    for det in detection_list:
        class_name = det.get("class_name", "")
        conf = float(det.get("confidence", 0.0))

        food = get_food_by_yolo_class(db, class_name)
        if not food:
            logger.warning(f"Detection class '{class_name}' is not mapped to any active food.")
            continue

        if (
            food.id not in food_best_confidence
            or conf > food_best_confidence[food.id]["confidence"]
        ):
            food_best_confidence[food.id] = {
                "food_id": food.id,
                "food_name": food.name,
                "confidence": round(conf, 2),
                "low_confidence": conf < settings.DETECTION_LOW_CONFIDENCE_THRESHOLD,
            }

    # Sort descending by confidence
    sorted_detections = sorted(
        food_best_confidence.values(),
        key=lambda x: x["confidence"],
        reverse=True,
    )[: settings.MAX_DETECTED_ITEMS]

    return {
        "detections": sorted_detections,
        "low_confidence_threshold": settings.DETECTION_LOW_CONFIDENCE_THRESHOLD,
    }
