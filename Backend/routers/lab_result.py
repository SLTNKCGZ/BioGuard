from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from auth import get_current_user
from models.lab_result import LabResult
from schemas.lab_result import LabResultCreate, LabResultOut

router = APIRouter(prefix="/lab_results", tags=["Lab Results"])

# 🧪 Tahlil ekleme
@router.post("/", response_model=LabResultOut)
def add_lab_result(
    lab_result: LabResultCreate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    new_result = LabResult(**lab_result.dict(), user_id=user.id)
    db.add(new_result)
    db.commit()
    db.refresh(new_result)
    return new_result

# 📋 Tahlilleri listeleme
@router.get("/", response_model=list[LabResultOut])
def get_user_lab_results(
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    return db.query(LabResult).filter(LabResult.user_id == user.id).order_by(LabResult.date.desc()).all()
