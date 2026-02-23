from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from deps import get_db, get_current_user
from models import ParentalControl, User

router = APIRouter(prefix="/parental-controls", tags=["parental-controls"])


class ParentalControlsPayload(BaseModel):
    daily_limit_enabled: bool
    hours_per_day: int
    break_reminders_enabled: bool
    age_appropriate_only: bool
    block_educational: bool
    require_approval: bool
    sleep_mode: bool
    bedtime: str | None = None
    wake_time: str | None = None
    emergency_lock: bool = False


def _default_controls(user_id: int) -> ParentalControl:
    return ParentalControl(
        user_id=user_id,
        daily_limit_enabled=True,
        hours_per_day=2,
        break_reminders_enabled=True,
        age_appropriate_only=True,
        block_educational=False,
        require_approval=False,
        sleep_mode=True,
        bedtime="8:00 PM",
        wake_time="7:00 AM",
        emergency_lock=False,
    )


@router.get("/settings")
def get_controls(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    controls = db.query(ParentalControl).filter(ParentalControl.user_id == user.id).first()
    if not controls:
        controls = _default_controls(user.id)
        db.add(controls)
        db.commit()
        db.refresh(controls)
    return {
        "settings": {
            "daily_limit_enabled": controls.daily_limit_enabled,
            "hours_per_day": controls.hours_per_day,
            "break_reminders_enabled": controls.break_reminders_enabled,
            "age_appropriate_only": controls.age_appropriate_only,
            "block_educational": controls.block_educational,
            "require_approval": controls.require_approval,
            "sleep_mode": controls.sleep_mode,
            "bedtime": controls.bedtime,
            "wake_time": controls.wake_time,
            "emergency_lock": controls.emergency_lock,
        }
    }


@router.put("/settings")
def update_controls(
    payload: ParentalControlsPayload,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    controls = db.query(ParentalControl).filter(ParentalControl.user_id == user.id).first()
    if not controls:
        controls = _default_controls(user.id)
        db.add(controls)

    controls.daily_limit_enabled = payload.daily_limit_enabled
    controls.hours_per_day = payload.hours_per_day
    controls.break_reminders_enabled = payload.break_reminders_enabled
    controls.age_appropriate_only = payload.age_appropriate_only
    controls.block_educational = payload.block_educational
    controls.require_approval = payload.require_approval
    controls.sleep_mode = payload.sleep_mode
    controls.bedtime = payload.bedtime
    controls.wake_time = payload.wake_time
    controls.emergency_lock = payload.emergency_lock

    db.commit()
    db.refresh(controls)
    return {
        "settings": {
            "daily_limit_enabled": controls.daily_limit_enabled,
            "hours_per_day": controls.hours_per_day,
            "break_reminders_enabled": controls.break_reminders_enabled,
            "age_appropriate_only": controls.age_appropriate_only,
            "block_educational": controls.block_educational,
            "require_approval": controls.require_approval,
            "sleep_mode": controls.sleep_mode,
            "bedtime": controls.bedtime,
            "wake_time": controls.wake_time,
            "emergency_lock": controls.emergency_lock,
        }
    }
