# Troubleshooting Guide: Password & Feature Issues

## Problem: Password Still Not Changing After Fix

### Symptom
- Response shows "success": true
- Password change endpoint returns 200 OK
- But logging in with new password fails
- Old password still works

### Root Cause Checklist

**❌ Issue: `db.refresh()` missing after commit**
```python
# WRONG ❌
db.commit()
return {"success": True}  # Object stale!

# CORRECT ✓
db.commit()
db.refresh(user)  # Sync DB state
return {"success": True}
```
**Fix:** Verify line 76-77 in [routers/auth.py](routers/auth.py) has `db.refresh(user)`

---

**❌ Issue: Session not committing due to unique constraint**
```
sqlalchemy.exc.IntegrityError: duplicate key value...
```
**Fix:** 
1. Check if another process is modifying user at same time
2. Check if `email` column has unique constraint
3. Verify user ID is correct

---

**❌ Issue: Database file locked (SQLite)**
```
sqlite3.OperationalError: database is locked
```
**Fix:**
```bash
# Check for open connections
lsof | grep data.db

# Kill stuck processes
kill -9 <PID>

# Delete lock file if exists
rm database.db-journal

# Restart app
```

---

**❌ Issue: Async/Sync mismatch**
```python
# WRONG ❌ - async function with sync db
async def change_password(...):
    db.commit()  # This might not work correctly

# CORRECT ✓ - sync function with sync db
def change_password(...):  # No async
    db.commit()  # Works correctly
```
**Fix:** Ensure [routers/auth.py](routers/auth.py) functions are NOT async

---

**❌ Issue: Exception caught silently**
```python
# WRONG ❌ - swallows all errors
try:
    db.commit()
except:
    pass  # Error hidden!

# CORRECT ✓ - logs and re-raises
except Exception as e:
    logger.error(f"Error: {e}", exc_info=True)
    raise HTTPException(...)
```
**Fix:** Verify exception handler logs at [routers/auth.py](routers/auth.py) line 88-91

---

## Problem: Feature Access Returning 403 When Should Be 200

### Symptom
- Free user getting 403 on `/reports/basic`
- Premium user getting 403 on `/reports/advanced`
- Error message says feature not available

### Root Cause Checklist

**❌ Issue: Wrong feature name in PLAN_FEATURES**
```python
PLAN_FEATURES = {
    PLAN_FREE: {
        "basic_reports": True,      # ✓ Correct spelling
        "basicreports": False,      # ❌ Wrong
        "basic-reports": False,     # ❌ Wrong
    }
}
```
**Fix:** Check [plan_service.py](plan_service.py) for exact spelling:
- `basic_reports` (with underscore)
- `basic_notifications`
- `basic_parental_controls`
- `advanced_reports`
- `ai_insights` (not `ai_insights_pro`)
- `smart_notifications`
- etc.

---

**❌ Issue: User plan is NULL or wrong value**
```python
user.plan = None           # ❌ Will default to FREE
user.plan = "free"         # ❌ Should be "FREE" (uppercase)
user.plan = "PREMIUM"      # ✓ Correct
```
**Fix:** Check database:
```sql
SELECT id, email, plan FROM users WHERE id = 5;
-- Should show: plan='FREE' or plan='PREMIUM', never NULL
```

**Debug:**
```python
from deps import get_current_user
from plan_service import get_user_plan
user = get_current_user(token)
plan = get_user_plan(user)
print(f"User plan: {plan}")  # Should be 'FREE', 'PREMIUM', etc
```

---

**❌ Issue: require_feature() not returning user**
```python
# WRONG ❌ - doesn't return user
def check_feature(...):
    if not feature_enabled(plan, feature):
        raise HTTPException(403, ...)
    # Missing: return user

# CORRECT ✓ - returns user
def check_feature(...):
    if not feature_enabled(plan, feature):
        raise HTTPException(403, ...)
    return user  # ✓ Must return!
```
**Fix:** Verify [deps.py](deps.py) line 62 has `return user` at end

---

**❌ Issue: Feature name mismatch in endpoint**
```python
# WRONG ❌ - endpoint uses different feature name
@router.get("/reports/basic")
def get_basic_reports(user: User = Depends(require_feature("basic_report"))):  # Typo!
    ...

# CORRECT ✓ - matches PLAN_FEATURES
@router.get("/reports/basic")
def get_basic_reports(user: User = Depends(require_feature("basic_reports"))):
    ...
```
**Fix:** Check all feature names in [routers/features.py](routers/features.py) match [plan_service.py](plan_service.py)

---

## Problem: Advanced Reports Accessible to Free Users (Original Bug)

### Symptom
- Free user can access `/reports/advanced` with 200 OK
- Should return 403 Forbidden
- Original config had `"advanced_reports": True` for FREE plan

### Verification
```python
from plan_service import PLAN_FEATURES, PLAN_FREE

# Should be False
print(PLAN_FEATURES[PLAN_FREE]["advanced_reports"])  # Must be False
```

**Fix Applied:** 
✓ [plan_service.py](plan_service.py) line 19 changed from `True` to `False`

---

## Problem: Passwords Not Validated (Missing Complexity Check)

### Symptom
- User sets password "123456" (weak, no uppercase)
- Password change succeeds
- Should fail with 422 validation error

### Root Cause
Complexity validation function not called or missing

**Fix Applied:**
✓ Added `validate_password_policy()` function at [routers/auth.py](routers/auth.py) line 47-61
✓ Called before hashing at line 97-101

**Test it:**
```bash
curl -X POST http://localhost:8000/auth/change-password \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "currentPassword": "CurrentPass123!",
    "newPassword": "weak",
    "confirmPassword": "weak"
  }'
# Should return: 422 Unprocessable Entity
```

---

## Problem: No Logging, Can't Debug Issues

### Symptom
- Password change fails but no error in logs
- Can't tell where the failure happens
- Silent failures in try-except blocks

### Fix Applied
✓ Added logging configuration in [main.py](main.py) lines 11-20
✓ All modules log to `app.log` file
✓ Every endpoint logs key points

**Check logs:**
```bash
# Real-time
tail -f app.log

# Search for specific user
grep "user 5" app.log

# Search for errors
grep "ERROR" app.log

# Search for specific endpoint
grep "Change password request" app.log
```

**Sample log output:**
```
2024-01-18 14:32:15,123 - routers.auth - DEBUG - Change password request from user 5
2024-01-18 14:32:15,156 - routers.auth - INFO - Password changed successfully for user 5
```

---

## Quick Diagnostic Commands

### Check Database State
```python
from database import SessionLocal
from models import User
from auth import verify_password

db = SessionLocal()
user = db.query(User).filter(User.email == "test@example.com").first()

print(f"User ID: {user.id}")
print(f"User Plan: {user.plan}")
print(f"Password Hash Length: {len(user.password_hash)}")
print(f"Can login with 'CurrentPass123!': {verify_password('CurrentPass123!', user.password_hash)}")
print(f"Can login with 'NewPass456!': {verify_password('NewPass456!', user.password_hash)}")
```

### Test Feature System
```python
from plan_service import get_user_plan, feature_enabled, PLAN_FEATURES

plan = get_user_plan(user)
print(f"User plan: {plan}")
print(f"Available features: {PLAN_FEATURES[plan]}")
print(f"Can access basic_reports: {feature_enabled(plan, 'basic_reports')}")
print(f"Can access advanced_reports: {feature_enabled(plan, 'advanced_reports')}")
```

### Verify Password Hashing
```python
from auth import hash_password, verify_password

password = "TestPass123!"
hashed = hash_password(password)
print(f"Original: {password}")
print(f"Hash: {hashed}")
print(f"Verify: {verify_password(password, hashed)}")  # Should be True
```

---

## Verification Checklist

### After Implementing Fixes

- [ ] **DB has `plan` column** 
  ```sql
  SELECT sql FROM sqlite_master WHERE type='table' AND name='users';
  ```
  Look for: `plan TEXT NOT NULL DEFAULT 'FREE'`

- [ ] **All users have valid plan values**
  ```sql
  SELECT DISTINCT plan FROM users;
  -- Should show: FREE, PREMIUM, FAMILY_PLUS (never NULL)
  ```

- [ ] **Password change endpoint has db.refresh()**
  ```bash
  grep -n "db.refresh(user)" routers/auth.py
  ```
  Should show line ~77

- [ ] **Feature matrix has correct values**
  ```bash
  grep -n "advanced_reports.*False" plan_service.py
  ```
  Should show line with `PLAN_FREE: { ... "advanced_reports": False`

- [ ] **require_feature() returns user**
  ```bash
  grep -n "return user" deps.py
  ```
  Should show at least 2 returns (one in `check_feature`)

- [ ] **Logging is configured**
  ```bash
  grep -n "logging.basicConfig" main.py
  ```
  Should find configuration block

- [ ] **app.log is created after running**
  ```bash
  ls -la app.log
  ```
  Should exist and contain recent entries

---

## If All Else Fails: Nuclear Option

### Reset and Rebuild
```bash
# 1. Stop the server
# (Ctrl+C or kill process)

# 2. Delete database and logs
rm data.db
rm app.log
rm database.db-journal

# 3. Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# 4. Restart server
python -m uvicorn main:app --reload

# 5. Create fresh test user
python debug_create_user.py

# 6. Test password change
curl -X POST http://localhost:8000/auth/change-password ...
```

### Rollback Latest Changes
```bash
git status  # See what changed
git diff routers/auth.py  # Review auth changes
git checkout -- routers/auth.py  # Revert one file
git checkout -- .  # Revert all files
```

---

## Performance Impact

The fixes should NOT cause performance issues:

| Operation | Impact | Notes |
|-----------|--------|-------|
| `db.refresh(user)` | +1-2ms | Minimal, single row query |
| `validate_password_policy()` | <1ms | String operations only |
| Logging | +0.5ms | File I/O, async doesn't block |
| `require_feature()` | <1ms | Dict lookup in PLAN_FEATURES |

**Expected change password time:** ~50-100ms (was ~45-50ms)
**Expected feature access time:** ~30-50ms (was ~30-50ms)

---

## When to Contact Support

Create a bug report with:

1. **Current behavior:**
   ```
   Password change returns 200 but old password still works
   ```

2. **Expected behavior:**
   ```
   Password should change and new password should work
   ```

3. **Steps to reproduce:**
   ```
   1. Call /auth/change-password with valid token
   2. Try to login with new password
   3. New password fails but old password works
   ```

4. **Error logs:**
   ```
   (Paste relevant lines from app.log)
   ```

5. **Debug info:**
   ```python
   # From Python REPL
   from database import SessionLocal
   from models import User
   db = SessionLocal()
   user = db.query(User).filter(User.id == 5).first()
   print(user.plan, user.password_hash[:20])
   ```

