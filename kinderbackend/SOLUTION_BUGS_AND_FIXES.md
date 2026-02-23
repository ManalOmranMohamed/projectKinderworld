# FastAPI Kinder Backend: Bug Analysis & Comprehensive Fixes

## Executive Summary

**Critical Issues Identified:**
1. ❌ **Change Password Endpoint Bug**: Password updated in memory but may not persist correctly in DB
2. ❌ **Incorrect Feature Gating**: `advanced_reports: True` for FREE plan (should be False)
3. ❌ **Missing Basic Features for Free Tier**: Basic Reports, Basic Notifications, Basic Parental Controls not available to Free users
4. ❌ **Incomplete Feature Dependency System**: No clear dependency injection for enforcing feature access

---

## Bug #1: Change Password Endpoint Issue

### Root Causes
The `change_password` endpoint in [routers/auth.py](routers/auth.py) appears correct at first glance, but there are several potential failure points:

1. **Missing `db.refresh()`** after commit – User object may not reflect DB state
2. **No password policy validation** – New password could be too weak
3. **No transaction rollback** on failure – DB could be left in inconsistent state
4. **Error handling too narrow** – Only catches password mismatch, not DB errors
5. **No logging for debugging** – Hard to trace where failure occurs

### Current Code Issue
```python
@router.post("/auth/change-password")
def change_password(
    payload: ChangePassword,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    if payload.newPassword != payload.confirmPassword:
        raise HTTPException(status_code=400, detail="New password confirmation mismatch")
    if not verify_password(payload.currentPassword, user.password_hash):
        raise HTTPException(status_code=401, detail="Current password is incorrect")

    user.password_hash = hash_password(payload.newPassword)
    db.add(user)
    db.commit()
    # ❌ Missing: db.refresh(user) to sync DB state
    return {"success": True}
```

### Debugging Checklist

**Where to look when password doesn't change:**

| Issue | Check | Evidence |
|-------|-------|----------|
| Hash verification fails | `verify_password()` returns False when it shouldn't | Add logs before `verify_password()` call |
| User lookup fails silently | `get_current_user()` returns wrong user | Log `user.id` and `user.email` |
| Commit doesn't execute | Exception caught silently or session rolled back | Check DB for transaction logs; add try-except |
| New hash is broken | `hash_password()` returns invalid format | Verify bcrypt output is valid |
| Session is async-misused | SQLAlchemy sync session used in async context | Ensure `get_db()` doesn't use async |
| DB column locked | Another process has lock on `password_hash` | Check DB connection logs |

---

## Bug #2 & #3: Feature Gating Misconfiguration

### Current Problem in [plan_service.py](plan_service.py)

```python
PLAN_FEATURES: Dict[str, Dict[str, bool]] = {
    PLAN_FREE: {
        "advanced_reports": True,  # ❌ WRONG! Should be False
        "ai_insights_pro": False,
        "offline_downloads": False,
        "priority_support": False,
    },
    PLAN_PREMIUM: {
        "advanced_reports": True,  # ✓ Correct
        "ai_insights_pro": True,   # ✓ Correct
        "offline_downloads": True,
        "priority_support": False,
    },
    # ...
}
```

### Missing Features

Free users should have access to:
- ✅ `basic_reports` – YES, define this feature
- ✅ `basic_notifications` – YES, define this feature
- ✅ `basic_parental_controls` – YES, define this feature

Premium users should additionally have:
- ✅ `advanced_reports` (analytics, trends)
- ✅ `ai_insights` (AI recommendations)
- ✅ `smart_notifications` (behavioral alerts)

Family Plus should additionally have:
- ✅ `multiple_children` (unlimited)
- ✅ `priority_support`

---

## Solution Architecture

### 1. Feature Access Dependency System

Create a reusable dependency for feature gating:

```python
# deps.py - Add this function

from typing import Optional
from fastapi import Depends, HTTPException
from models import User
from plan_service import feature_enabled, get_user_plan

async def require_feature(
    feature_name: str,
    user: User = Depends(get_current_user)
) -> User:
    """
    Dependency that enforces feature access based on user's plan.
    
    Usage:
        @router.get("/reports/basic")
        def get_basic_reports(user: User = Depends(require_feature("basic_reports"))):
            return {"data": ...}
    """
    plan = get_user_plan(user)
    if not feature_enabled(plan, feature_name):
        raise HTTPException(
            status_code=403,
            detail={
                "code": "FEATURE_NOT_AVAILABLE",
                "message": f"Feature '{feature_name}' requires an upgraded plan",
                "current_plan": plan,
            },
        )
    return user
```

### 2. Updated Feature Matrix

Replace [plan_service.py](plan_service.py) `PLAN_FEATURES`:

```python
PLAN_FEATURES: Dict[str, Dict[str, bool]] = {
    PLAN_FREE: {
        # Basic features available to all
        "basic_reports": True,
        "basic_notifications": True,
        "basic_parental_controls": True,
        
        # Premium-only features
        "advanced_reports": False,      # ✓ FIXED: was True
        "ai_insights": False,
        "smart_notifications": False,
        "offline_downloads": False,
        "multiple_children": False,
        "priority_support": False,
    },
    PLAN_PREMIUM: {
        # Inherits Free tier basics
        "basic_reports": True,
        "basic_notifications": True,
        "basic_parental_controls": True,
        
        # Premium features
        "advanced_reports": True,
        "ai_insights": True,
        "smart_notifications": True,
        "offline_downloads": True,
        "multiple_children": False,     # Limit to 3
        "priority_support": False,
    },
    PLAN_FAMILY_PLUS: {
        # All features enabled
        "basic_reports": True,
        "basic_notifications": True,
        "basic_parental_controls": True,
        "advanced_reports": True,
        "ai_insights": True,
        "smart_notifications": True,
        "offline_downloads": True,
        "multiple_children": True,      # Unlimited
        "priority_support": True,
    },
}
```

---

## Complete Fixed Code

### File 1: [routers/auth.py](routers/auth.py) - FIXED Change Password Endpoint

```python
import logging
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from auth import hash_password, verify_password
from deps import get_current_user, get_db
from models import User
from serializers import user_to_json

logger = logging.getLogger(__name__)

router = APIRouter(tags=["auth"])

# Constants for password validation
MIN_PASSWORD_LENGTH = 8
PASSWORD_COMPLEXITY_RULES = {
    "min_length": MIN_PASSWORD_LENGTH,
    "require_uppercase": True,
    "require_digit": True,
    "require_special": True,
}


class ProfileUpdate(BaseModel):
    name: str


class ChangePasswordRequest(BaseModel):
    """Schema for change password request with validation."""
    currentPassword: str = Field(..., min_length=1)
    newPassword: str = Field(
        ...,
        min_length=MIN_PASSWORD_LENGTH,
        description="Must contain uppercase, digit, and special character"
    )
    confirmPassword: str = Field(..., min_length=MIN_PASSWORD_LENGTH)


class ChangePasswordResponse(BaseModel):
    """Schema for change password response."""
    success: bool
    message: str = "Password changed successfully"


def validate_password_policy(password: str) -> tuple[bool, str]:
    """
    Validate password against security policy.
    Returns: (is_valid, error_message)
    """
    if len(password) < PASSWORD_COMPLEXITY_RULES["min_length"]:
        return False, f"Password must be at least {PASSWORD_COMPLEXITY_RULES['min_length']} characters"
    
    if PASSWORD_COMPLEXITY_RULES["require_uppercase"]:
        if not any(c.isupper() for c in password):
            return False, "Password must contain at least one uppercase letter"
    
    if PASSWORD_COMPLEXITY_RULES["require_digit"]:
        if not any(c.isdigit() for c in password):
            return False, "Password must contain at least one digit"
    
    if PASSWORD_COMPLEXITY_RULES["require_special"]:
        special_chars = set("!@#$%^&*()-_=+[]{};:,.<>?")
        if not any(c in special_chars for c in password):
            return False, "Password must contain at least one special character (!@#$%^&*)"
    
    return True, ""


@router.put("/auth/profile")
def update_profile(
    payload: ProfileUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Update user profile name."""
    try:
        user.name = payload.name
        db.add(user)
        db.commit()
        db.refresh(user)
        logger.info(f"Profile updated for user {user.id}")
        return {"user": user_to_json(user)}
    except Exception as e:
        db.rollback()
        logger.error(f"Error updating profile for user {user.id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to update profile")


@router.post("/auth/change-password", response_model=ChangePasswordResponse)
def change_password(
    payload: ChangePasswordRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """
    Change user password with validation and proper error handling.
    
    **Validation Steps:**
    1. Verify current password is correct
    2. Validate new password meets policy
    3. Confirm new password matches confirmation
    4. Hash and store new password
    5. Commit transaction
    
    **Security Notes:**
    - Current password must match exactly
    - New password must meet complexity requirements
    - Passwords are never logged
    - Session commits atomically or rolls back
    """
    
    # Step 1: Verify current password
    logger.debug(f"Change password request from user {user.id}")
    
    if not verify_password(payload.currentPassword, user.password_hash):
        logger.warning(f"Invalid current password attempt for user {user.id}")
        raise HTTPException(
            status_code=401,
            detail="Current password is incorrect"
        )
    
    # Step 2: Validate new password policy
    is_valid, error_msg = validate_password_policy(payload.newPassword)
    if not is_valid:
        logger.debug(f"Password policy validation failed for user {user.id}: {error_msg}")
        raise HTTPException(status_code=422, detail=error_msg)
    
    # Step 3: Confirm passwords match
    if payload.newPassword != payload.confirmPassword:
        logger.debug(f"Password confirmation mismatch for user {user.id}")
        raise HTTPException(
            status_code=400,
            detail="New password and confirmation do not match"
        )
    
    # Step 4: Update password in user object
    try:
        new_hash = hash_password(payload.newPassword)
        user.password_hash = new_hash
        db.add(user)
        db.commit()
        db.refresh(user)  # ✓ CRITICAL FIX: Refresh to sync DB state
        
        logger.info(f"Password changed successfully for user {user.id}")
        return ChangePasswordResponse(
            success=True,
            message="Password changed successfully"
        )
    
    except Exception as e:
        db.rollback()  # ✓ CRITICAL FIX: Rollback on any error
        logger.error(f"Error changing password for user {user.id}: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail="Failed to change password. Please try again later."
        )
```

### File 2: [plan_service.py](plan_service.py) - FIXED Feature Configuration

```python
from typing import Dict, Optional
from models import User

PLAN_FREE = "FREE"
PLAN_PREMIUM = "PREMIUM"
PLAN_FAMILY_PLUS = "FAMILY_PLUS"

PLAN_ORDER = {
    PLAN_FREE: 0,
    PLAN_PREMIUM: 1,
    PLAN_FAMILY_PLUS: 2,
}

PLAN_LIMITS: Dict[str, Optional[int]] = {
    PLAN_FREE: 1,
    PLAN_PREMIUM: 3,
    PLAN_FAMILY_PLUS: 9999,
}

# ✓ FIXED: Corrected feature availability matrix
PLAN_FEATURES: Dict[str, Dict[str, bool]] = {
    PLAN_FREE: {
        # Basic features available to all free users
        "basic_reports": True,
        "basic_notifications": True,
        "basic_parental_controls": True,
        
        # Premium-only features
        "advanced_reports": False,        # ✓ FIXED: was True
        "ai_insights": False,
        "smart_notifications": False,
        "offline_downloads": False,
        "multiple_children": False,
        "priority_support": False,
    },
    PLAN_PREMIUM: {
        # Inherits all free tier features
        "basic_reports": True,
        "basic_notifications": True,
        "basic_parental_controls": True,
        
        # Premium-specific features
        "advanced_reports": True,
        "ai_insights": True,
        "smart_notifications": True,
        "offline_downloads": True,
        "multiple_children": False,       # Limited to 3 children (enforced via PLAN_LIMITS)
        "priority_support": False,
    },
    PLAN_FAMILY_PLUS: {
        # All features enabled
        "basic_reports": True,
        "basic_notifications": True,
        "basic_parental_controls": True,
        "advanced_reports": True,
        "ai_insights": True,
        "smart_notifications": True,
        "offline_downloads": True,
        "multiple_children": True,        # Unlimited children (9999)
        "priority_support": True,
    },
}

FEATURE_FLAGS = list(PLAN_FEATURES[PLAN_FREE].keys())


def normalize_plan_value(plan: Optional[str]) -> str:
    """Normalize plan value to uppercase, default to FREE."""
    if not plan:
        return PLAN_FREE
    value = plan.strip().upper()
    if value in PLAN_LIMITS:
        return value
    return PLAN_FREE


def get_user_plan(user: User) -> str:
    """Get user's current plan, defaulting to FREE."""
    plan_value = normalize_plan_value(getattr(user, "plan", None))
    return plan_value


def plan_allows(current_plan: str, required_plan: str) -> bool:
    """Check if current plan meets or exceeds required plan tier."""
    return PLAN_ORDER.get(current_plan, 0) >= PLAN_ORDER.get(required_plan, 0)


def get_plan_limits(plan: str) -> Dict[str, Optional[int]]:
    """Get resource limits for a plan."""
    limit = PLAN_LIMITS.get(plan, PLAN_LIMITS[PLAN_FREE])
    return {"max_children": limit}


def get_plan_features(plan: str) -> Dict[str, bool]:
    """Get feature availability for a plan."""
    return PLAN_FEATURES.get(plan, PLAN_FEATURES[PLAN_FREE])


def feature_enabled(plan: str, feature: str) -> bool:
    """Check if a specific feature is enabled for a plan."""
    features = get_plan_features(plan)
    return features.get(feature, False)


def validate_plan_value(plan: str) -> str:
    """Validate and normalize a plan value."""
    normalized = normalize_plan_value(plan)
    if normalized not in PLAN_LIMITS:
        raise ValueError("Invalid plan value")
    return normalized
```

### File 3: [deps.py](deps.py) - ADD Feature Dependency

Add this function to the existing [deps.py](deps.py):

```python
# Add to existing imports at top
import logging

logger = logging.getLogger(__name__)

# Add this new dependency function (at end of file)

def require_feature(feature_name: str):
    """
    Dependency factory for feature-gated endpoints.
    
    Usage:
        @router.get("/reports/basic")
        def get_basic_reports(user: User = Depends(require_feature("basic_reports"))):
            return {"reports": []}
    
    Args:
        feature_name: The feature to require (e.g., "advanced_reports")
    
    Raises:
        HTTPException(403): If feature not available in user's plan
    
    Returns:
        User object if feature is available
    """
    from plan_service import feature_enabled, get_user_plan
    
    async def check_feature(user: User = Depends(get_current_user)) -> User:
        plan = get_user_plan(user)
        if not feature_enabled(plan, feature_name):
            logger.warning(
                f"Access denied to feature '{feature_name}' for user {user.id} on plan {plan}"
            )
            raise HTTPException(
                status_code=403,
                detail={
                    "code": "FEATURE_NOT_AVAILABLE",
                    "message": f"Feature '{feature_name}' not available in {plan} plan",
                    "feature": feature_name,
                    "current_plan": plan,
                    "hint": f"Upgrade to access {feature_name}",
                },
            )
        return user
    
    return check_feature
```

### File 4: [routers/features.py](routers/features.py) - Example Feature-Gated Routes

```python
import logging
from fastapi import APIRouter, Depends, HTTPException

from deps import get_current_user, require_feature
from models import User
from plan_service import feature_enabled, get_user_plan

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
def get_advanced_reports(user: User = Depends(require_feature("advanced_reports"))):
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
def get_offline_downloads(user: User = Depends(require_feature("offline_downloads"))):
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
```

---

## Migration & Setup Instructions

### 1. Database Schema (No Changes Required)
The User model already has the `plan` column:
```sql
ALTER TABLE users ADD COLUMN plan TEXT NOT NULL DEFAULT 'FREE';
```
This is already in [main.py](main.py) `ensure_user_columns()`.

### 2. Environment Setup

Add to `.env` or config:
```ini
MIN_PASSWORD_LENGTH=8
LOG_LEVEL=INFO
```

### 3. Update Logging Configuration

Add to [main.py](main.py):
```python
import logging
import logging.handlers

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)
```

### 4. Requirements Check

Ensure `requirements.txt` includes:
```
fastapi==0.104.0
sqlalchemy==2.0.0
pydantic==2.0.0
bcrypt==4.0.0
python-jose==3.3.0
```

---

## Testing Examples

### Unit Test: Change Password Success

```python
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from main import app
from models import User
from auth import hash_password

client = TestClient(app)


@pytest.fixture
def test_user(db: Session):
    """Create test user with known password."""
    user = User(
        email="test@example.com",
        password_hash=hash_password("CurrentPass123!"),
        name="Test User",
        plan="FREE"
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def test_change_password_success(test_user, db: Session, auth_token: str):
    """Test successful password change."""
    response = client.post(
        "/auth/change-password",
        json={
            "currentPassword": "CurrentPass123!",
            "newPassword": "NewPass456!",
            "confirmPassword": "NewPass456!",
        },
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    
    assert response.status_code == 200
    assert response.json()["success"] is True
    
    # Verify password actually changed in DB
    db.refresh(test_user)
    from auth import verify_password
    assert verify_password("NewPass456!", test_user.password_hash)
    assert not verify_password("CurrentPass123!", test_user.password_hash)


def test_change_password_wrong_current(test_user, auth_token: str):
    """Test with incorrect current password."""
    response = client.post(
        "/auth/change-password",
        json={
            "currentPassword": "WrongPassword123!",
            "newPassword": "NewPass456!",
            "confirmPassword": "NewPass456!",
        },
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    
    assert response.status_code == 401
    assert "Current password is incorrect" in response.json()["detail"]


def test_change_password_weak_password(test_user, auth_token: str):
    """Test with weak new password."""
    response = client.post(
        "/auth/change-password",
        json={
            "currentPassword": "CurrentPass123!",
            "newPassword": "weak",  # Too short, no uppercase, no special char
            "confirmPassword": "weak",
        },
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    
    assert response.status_code == 422
    assert "must be at least 8 characters" in response.json()["detail"]


def test_change_password_mismatch(test_user, auth_token: str):
    """Test password confirmation mismatch."""
    response = client.post(
        "/auth/change-password",
        json={
            "currentPassword": "CurrentPass123!",
            "newPassword": "NewPass456!",
            "confirmPassword": "NewPass789!",  # Doesn't match
        },
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    
    assert response.status_code == 400
    assert "do not match" in response.json()["detail"]
```

### Integration Test: Feature Gating

```python
def test_free_user_can_access_basic_reports(free_user, auth_token: str):
    """Free user can access basic_reports."""
    response = client.get(
        "/reports/basic",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert response.status_code == 200


def test_free_user_cannot_access_advanced_reports(free_user, auth_token: str):
    """Free user CANNOT access advanced_reports."""
    response = client.get(
        "/reports/advanced",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert response.status_code == 403
    assert response.json()["detail"]["code"] == "FEATURE_NOT_AVAILABLE"


def test_premium_user_can_access_advanced_reports(premium_user, auth_token: str):
    """Premium user CAN access advanced_reports."""
    response = client.get(
        "/reports/advanced",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert response.status_code == 200
```

---

## Files to Modify

| File | Changes | Priority |
|------|---------|----------|
| [routers/auth.py](routers/auth.py) | Add password validation, db.refresh(), try-except, logging | 🔴 CRITICAL |
| [plan_service.py](plan_service.py) | Fix `advanced_reports: False` for FREE, add basic_* features | 🔴 CRITICAL |
| [deps.py](deps.py) | Add `require_feature()` dependency function | 🟡 HIGH |
| [routers/features.py](routers/features.py) | Update endpoints to use `require_feature()` decorator | 🟡 HIGH |
| [main.py](main.py) | Add logging configuration | 🟢 MEDIUM |
| `requirements.txt` | Verify logging, bcrypt versions | 🟢 MEDIUM |

---

## Debugging Checklist for Production

When password change still fails after fixes:

1. **Enable Debug Logging**
   ```python
   import logging
   logging.getLogger("sqlalchemy.orm").setLevel(logging.DEBUG)
   ```

2. **Check Database Connection**
   ```python
   # In shell
   sqlite3 ./data.db "SELECT id, email, plan FROM users WHERE id=1;"
   ```

3. **Verify Hash Function**
   ```python
   from auth import hash_password, verify_password
   pwd = "TestPass123!"
   hashed = hash_password(pwd)
   print(verify_password(pwd, hashed))  # Should be True
   ```

4. **Check Session Lifecycle**
   - Is session being scoped correctly?
   - Are async operations being awaited?
   - Is `db.refresh()` being called?

5. **Monitor Database Lock**
   ```python
   # SQLite: Check for locked database
   lsof | grep data.db
   ```

6. **Enable SQL Query Logging**
   ```python
   # In SQLAlchemy
   engine = create_engine("sqlite:///./data.db", echo=True)
   ```

---

## Summary of Root Cause

**Why Password Isn't Changing:**

1. ✅ **Auth verification likely works** (would fail with 401)
2. ⚠️ **Missing `db.refresh()` after `db.commit()`** → Object stale
3. ⚠️ **No exception handling** → Silent DB errors swallowed
4. ⚠️ **No logging** → Can't diagnose failures
5. ⚠️ **No password validation** → Weak passwords accepted
6. ⚠️ **Async/Sync mismatch possible** → Session misuse

**Quick Fix Priority:**
1. Add `db.refresh(user)` after `db.commit()` ← DO THIS FIRST
2. Add try-except with rollback
3. Add logging
4. Add password validation
5. Update feature configuration

