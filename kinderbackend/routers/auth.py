import logging
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field, ConfigDict
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
    """
    Schema for change password request with validation.
    
    Accepts BOTH camelCase (currentPassword) and snake_case (current_password) formats
    for client compatibility (e.g., camelCase from web, snake_case from mobile).
    """
    currentPassword: str = Field(..., min_length=1, alias="current_password")
    newPassword: str = Field(
        ...,
        alias="new_password",
        description="Must contain uppercase, digit, and special character"
    )
    confirmPassword: str = Field(..., alias="confirm_password")
    
    model_config = ConfigDict(populate_by_name=True)  # Accept both field name and alias


class ChangePasswordResponse(BaseModel):
    """Schema for change password response."""
    success: bool
    message: str = "Password changed successfully"


# Keep old class name for backward compatibility
ChangePassword = ChangePasswordRequest


def validate_password_policy(password: str) -> tuple:
    """
    Validate password against security policy.
    Returns: (is_valid: bool, error_message: str)
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
        logger.error(f"Error updating profile for user {user.id}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to update profile")


@router.post("/auth/change-password", response_model=ChangePasswordResponse)
def change_password(
    payload: ChangePasswordRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """
    Change user password with validation and proper error handling.
    
    **Accepts both camelCase and snake_case:**
    - currentPassword / current_password
    - newPassword / new_password
    - confirmPassword / confirm_password
    
    **Validation Steps:**
    1. Verify current password is correct
    2. Validate new password meets policy
    3. Confirm new password matches confirmation
    4. Hash and store new password
    5. Commit transaction
    
    **Returns:**
    - 200: Success
    - 400: Password mismatch
    - 401: Wrong current password
    - 422: Weak password policy
    - 500: Database error
    """
    
    user_id = user.id
    logger.debug(f"Change password request from user {user_id}")
    
    try:
        # Step 1: Verify current password
        if not verify_password(payload.currentPassword, user.password_hash):
            logger.warning(f"Invalid current password attempt for user {user_id}")
            raise HTTPException(
                status_code=401,
                detail="Current password is incorrect"
            )
        
        # Step 2: Validate new password policy
        is_valid, error_msg = validate_password_policy(payload.newPassword)
        if not is_valid:
            logger.debug(f"Password policy validation failed for user {user_id}: {error_msg}")
            raise HTTPException(status_code=422, detail=error_msg)
        
        # Step 3: Confirm passwords match
        if payload.newPassword != payload.confirmPassword:
            logger.debug(f"Password confirmation mismatch for user {user_id}")
            raise HTTPException(
                status_code=400,
                detail="New password and confirmation do not match"
            )
        
        # Step 4: Hash and update password
        new_hash = hash_password(payload.newPassword)
        user.password_hash = new_hash
        user.token_version = (user.token_version or 0) + 1
        db.add(user)
        db.commit()
        db.refresh(user)  # CRITICAL: Sync DB state with in-memory object
        
        logger.info(f"Password changed successfully for user {user_id}")
        return ChangePasswordResponse(
            success=True,
            message="Password changed successfully"
        )
    
    except HTTPException:
        db.rollback()
        raise  # Re-raise HTTP exceptions as-is
    
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error changing password for user {user_id}: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail="Failed to change password. Please try again later."
        )


@router.post("/auth/logout")
def logout(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Invalidate refresh tokens by bumping token version."""
    try:
        user.token_version = (user.token_version or 0) + 1
        db.add(user)
        db.commit()
        db.refresh(user)
        return {"success": True}
    except Exception as e:
        db.rollback()
        logger.error(f"Error during logout for user {user.id}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to logout")
