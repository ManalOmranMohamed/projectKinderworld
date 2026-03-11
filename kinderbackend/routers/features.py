import logging
from fastapi import APIRouter, Depends

from deps import require_feature
from models import User

logger = logging.getLogger(__name__)
router = APIRouter(tags=["features"])
FEATURE_ERROR_CODE = "FEATURE_NOT_AVAILABLE_IN_PLAN"


# ===============================
# REPORTS ENDPOINTS (Free & Premium)
# ===============================

@router.get("/reports/basic")
def get_basic_reports(user: User = Depends(require_feature("basic_reports"))):
    """
    Get basic reports (available to Free and Premium users).
    Includes basic activity summaries, daily screen time.
    """
    logger.info(f"Basic reports requested by user {user.id}")
    return {
        "reports": [
            {"date": "2024-01-18", "screen_time_minutes": 45},
            {"date": "2024-01-17", "screen_time_minutes": 52},
        ],
        "access_level": "basic"
    }


@router.get("/reports/advanced")
def advanced_reports(user: User = Depends(require_feature("advanced_reports"))):
    """
    Get advanced analytics (Premium+ only).
    Includes trends, weekly comparisons, app-level breakdowns.
    """
    logger.info(f"Advanced reports requested by user {user.id}")
    return {
        "reports": {
            "weekly_trend": [45, 52, 48, 60, 55, 50, 48],
            "app_breakdown": {
                "YouTube": 25,
                "TikTok": 15,
                "Educational": 10,
            },
            "comparison": "↓ 5% from last week",
        },
        "access_level": "advanced"
    }


# ===============================
# NOTIFICATIONS (Free & Premium)
# ===============================

@router.get("/notifications/basic")
def get_notifications(user: User = Depends(require_feature("basic_notifications"))):
    """
    Get basic notifications (Free users).
    Includes system alerts, weekly summaries.
    """
    logger.info(f"Basic notifications requested by user {user.id}")
    return {
        "notifications": [
            {
                "id": 1,
                "type": "SCREEN_TIME_LIMIT",
                "message": "Child reached 1 hour screen time today",
                "created_at": "2024-01-18T14:30:00Z"
            },
            {
                "id": 2,
                "type": "WEEKLY_SUMMARY",
                "message": "Weekly summary ready for review",
                "created_at": "2024-01-17T08:00:00Z"
            },
        ],
        "access_level": "basic"
    }


@router.get("/notifications/smart")
def get_smart_notifications(user: User = Depends(require_feature("smart_notifications"))):
    """
    Get AI-driven smart notifications (Premium+ only).
    Includes behavioral insights, anomaly alerts, predictive warnings.
    """
    logger.info(f"Smart notifications requested by user {user.id}")
    return {
        "notifications": [
            {
                "id": 1,
                "type": "BEHAVIORAL_INSIGHT",
                "message": "Child's usage pattern changing: 20% increase in evening usage",
                "severity": "warning",
                "created_at": "2024-01-18T16:00:00Z"
            },
            {
                "id": 2,
                "type": "ANOMALY_ALERT",
                "message": "Unusual activity: New app installed at 2 AM",
                "severity": "critical",
                "created_at": "2024-01-18T02:15:00Z"
            },
        ],
        "access_level": "smart"
    }


# ===============================
# PARENTAL CONTROLS (Free & Premium)
# ===============================

@router.get("/parental-controls/basic")
def get_basic_parental_controls(user: User = Depends(require_feature("basic_parental_controls"))):
    """
    Get basic parental controls (Free users).
    Includes screen time limits, app blocking.
    """
    logger.info(f"Basic parental controls requested by user {user.id}")
    return {
        "controls": [
            {"id": 1, "type": "SCREEN_TIME_LIMIT", "value": 60, "unit": "minutes"},
            {"id": 2, "type": "BEDTIME", "start": "21:00", "end": "07:00"},
            {"id": 3, "type": "BLOCKED_APPS", "apps": ["TikTok", "Snapchat"]},
        ],
        "access_level": "basic"
    }


@router.get("/parental-controls/advanced")
def get_advanced_parental_controls(user: User = Depends(require_feature("advanced_reports"))):
    """
    Get advanced parental controls (Premium+ only).
    Includes smart rules, per-app time limits, location tracking.
    """
    logger.info(f"Advanced parental controls requested by user {user.id}")
    return {
        "controls": [
            {"id": 1, "type": "SCREEN_TIME_LIMIT", "value": 60, "unit": "minutes"},
            {"id": 2, "type": "SMART_RULE", "rule": "Allow 15 min YouTube only on weekends"},
            {"id": 3, "type": "PER_APP_LIMIT", "app": "Games", "limit": 30, "unit": "minutes"},
            {"id": 4, "type": "LOCATION_TRACKING", "enabled": True},
        ],
        "access_level": "advanced"
    }


# ===============================
# PREMIUM FEATURES
# ===============================

@router.get("/ai/insights")
def get_ai_insights(user: User = Depends(require_feature("ai_insights"))):
    """Get AI-powered insights (Premium+ only)."""
    logger.info(f"AI insights requested by user {user.id}")
    return {
        "insights": [
            "Bedtime recommendations: Consider moving bedtime 30 minutes earlier (based on sleep goals)",
            "App suggestion: Try 'Khan Academy' - matches educational interests",
        ]
    }


@router.get("/downloads/offline")
def offline_downloads(user: User = Depends(require_feature("offline_downloads"))):
    """Download content for offline use (Premium+ only)."""
    logger.info(f"Offline download requested by user {user.id}")
    return {
        "status": "downloads enabled",
        "quota_mb": 500,
        "used_mb": 120
    }


# ===============================
# FAMILY PLUS ONLY
# ===============================

@router.get("/support/priority")
def get_priority_support(user: User = Depends(require_feature("priority_support"))):
    """Priority support ticket access (Family Plus only)."""
    logger.info(f"Priority support requested by user {user.id}")
    return {
        "support_level": "priority",
        "response_time_hours": 2,
        "support_channels": ["email", "chat", "phone"]
    }
