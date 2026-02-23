# Quick Reference: Change Password API

## API Endpoint

```
POST /auth/change-password
Authorization: Bearer {jwt_token}
Content-Type: application/json
```

## Swagger Authorization (JWT)

1. Open `/docs`
2. Click **Authorize**
3. Paste: `Bearer <access_token>`
4. Click **Authorize** then close the dialog
5. Call any protected endpoint (e.g. `/auth/change-password`)

## Subscription Activation Endpoint

- Primary: `POST /subscription/select`
- Alias (frontend compatibility): `POST /subscription/activate`

## Request Format (Both Work!)

**Web Client (camelCase):**
```json
{
  "currentPassword": "OldPass123!",
  "newPassword": "NewPass456!",
  "confirmPassword": "NewPass456!"
}
```

**Mobile Client (snake_case):**
```json
{
  "current_password": "OldPass123!",
  "new_password": "NewPass456!",
  "confirm_password": "NewPass456!"
}
```

## Password Requirements

- ✅ Minimum 8 characters
- ✅ At least 1 uppercase letter (A-Z)
- ✅ At least 1 digit (0-9)
- ✅ At least 1 special character (!@#$%^&*())

## HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Password changed ✓ |
| 400 | Passwords don't match | Check `newPassword` == `confirmPassword` |
| 401 | Unauthorized | Wrong current password OR invalid JWT |
| 422 | Validation error | Password doesn't meet policy OR Pydantic validation |
| 500 | Server error | Database/unexpected error, contact support |

## Error Response Examples

**Wrong Current Password (401):**
```json
{
  "detail": "Current password is incorrect"
}
```

**Passwords Don't Match (400):**
```json
{
  "detail": "New password and confirmation do not match"
}
```

**Weak Password (422):**
```json
{
  "detail": "Password must contain at least one uppercase letter"
}
```

**Feature Not Available (403):**
```json
{
  "detail": {
    "code": "FEATURE_NOT_AVAILABLE",
    "message": "Feature 'advanced_reports' not available in FREE plan",
    "feature": "advanced_reports",
    "current_plan": "FREE",
    "hint": "Upgrade to access advanced_reports"
  }
}
```

## Plan Features Matrix

### FREE Tier ✓
- `basic_reports` ✓
- `basic_notifications` ✓
- `basic_parental_controls` ✓
- `advanced_reports` ✗
- `ai_insights` ✗

### PREMIUM Tier ✓
- All FREE features ✓
- `advanced_reports` ✓
- `ai_insights` ✓
- `smart_notifications` ✓
- `offline_downloads` ✓

### FAMILY_PLUS Tier ✓
- All PREMIUM features ✓
- `multiple_children` ✓
- `priority_support` ✓

## Testing Commands

```bash
# Run all tests
venv\Scripts\python -m pytest test_change_password_compat.py -v

# Run specific test class
venv\Scripts\python -m pytest test_change_password_compat.py::TestChangePasswordCamelCase -v

# Run with coverage
venv\Scripts\python -m pytest test_change_password_compat.py --cov=routers.auth
```

## curl Examples

**Change Password (camelCase):**
```bash
curl -X POST http://localhost:8000/auth/change-password \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "currentPassword": "OldPass123!",
    "newPassword": "NewPass456!",
    "confirmPassword": "NewPass456!"
  }'
```

**Change Password (snake_case):**
```bash
curl -X POST http://localhost:8000/auth/change-password \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "current_password": "OldPass123!",
    "new_password": "NewPass456!",
    "confirm_password": "NewPass456!"
  }'
```

**Access Basic Feature (FREE user):**
```bash
curl http://localhost:8000/reports/basic \
  -H "Authorization: Bearer FREE_USER_TOKEN"
# ✅ 200 OK
```

**Access Advanced Feature (FREE user):**
```bash
curl http://localhost:8000/reports/advanced \
  -H "Authorization: Bearer FREE_USER_TOKEN"
# ❌ 403 Forbidden
```

## Files Modified

| File | Purpose |
|------|---------|
| [routers/auth.py](routers/auth.py) | Main implementation: schema + handler |
| [plan_service.py](plan_service.py) | Feature matrix definition |
| [deps.py](deps.py) | Feature gating dependency |
| [test_change_password_compat.py](test_change_password_compat.py) | 13 comprehensive tests |

## Key Code Snippets

**Accept Both Formats:**
```python
from pydantic import BaseModel, Field, ConfigDict

class ChangePasswordRequest(BaseModel):
    currentPassword: str = Field(..., alias="current_password")
    newPassword: str = Field(..., alias="new_password")
    confirmPassword: str = Field(..., alias="confirm_password")
    
    model_config = ConfigDict(populate_by_name=True)  # ← Magic!
```

**Feature Gating:**
```python
from deps import require_feature

@router.get("/reports/basic")
def basic_reports(user: User = Depends(require_feature("basic_reports"))):
    return {"data": [...]}  # FREE users can access this
```

**Password Validation:**
```python
is_valid, error_msg = validate_password_policy(password)
if not is_valid:
    raise HTTPException(status_code=422, detail=error_msg)
```

## Logging Examples

**Change Password Request:**
```
DEBUG [auth.py:105] Change password request from user 123
```

**Wrong Password Attempt:**
```
WARNING [auth.py:112] Invalid current password attempt for user 123
```

**Success:**
```
INFO [auth.py:140] Password changed successfully for user 123
```

**Feature Blocked:**
```
WARNING [deps.py:87] Access denied to feature 'advanced_reports' for user 123 on plan FREE
```

## Common Issues & Solutions

**Issue:** 422 validation error even with valid password  
**Solution:** Check min_length constraint in Field definition

**Issue:** Password changes but old password still works  
**Solution:** Verify `db.commit()` and `db.refresh(user)` are called

**Issue:** FREE user blocked from basic features  
**Solution:** Check PLAN_FEATURES[PLAN_FREE] has feature set to True

**Issue:** Tests fail with "UNIQUE constraint failed"  
**Solution:** Cleanup fixture now handles this automatically

## Support

For issues or questions:
1. Check [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) for detailed docs
2. Review test file for usage examples
3. Check app.log for error details

---

**Last Updated:** January 18, 2026  
**Status:** ✅ Production Ready  
**Test Coverage:** 13/13 tests passing (100%)
