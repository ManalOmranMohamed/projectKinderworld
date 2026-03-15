from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from deps import get_db, get_current_user
from models import PaymentMethod, User

router = APIRouter(prefix="/billing", tags=["billing"])


class PaymentMethodIn(BaseModel):
    label: str = Field(..., min_length=2, max_length=100)


@router.get("/methods")
def list_methods(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    methods = (
        db.query(PaymentMethod)
        .filter(PaymentMethod.user_id == user.id, PaymentMethod.deleted_at.is_(None))
        .order_by(PaymentMethod.created_at.desc())
        .all()
    )
    return {
        "methods": [
            {"id": m.id, "label": m.label, "created_at": m.created_at.isoformat()}
            for m in methods
        ]
    }


@router.post("/methods")
def add_method(
    payload: PaymentMethodIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    method = PaymentMethod(user_id=user.id, label=payload.label.strip())
    db.add(method)
    db.commit()
    db.refresh(method)
    return {"method": {"id": method.id, "label": method.label}}


@router.delete("/methods/{method_id}")
def delete_method(
    method_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    method = (
        db.query(PaymentMethod)
        .filter(
            PaymentMethod.id == method_id,
            PaymentMethod.user_id == user.id,
            PaymentMethod.deleted_at.is_(None),
        )
        .first()
    )
    if not method:
        raise HTTPException(status_code=404, detail="Payment method not found")
    method.deleted_at = datetime.utcnow()
    db.add(method)
    db.commit()
    return {"success": True}
