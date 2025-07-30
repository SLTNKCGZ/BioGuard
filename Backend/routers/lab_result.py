from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session
from database import get_db
from auth import get_current_user
from models.lab_result import LabResult
from schemas.lab_result import LabResultCreate, LabResultOut, LabResultUpdate

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
    
@router.put("/{lab_result_id}", response_model=LabResultOut)
def update_lab_result(
    lab_result_id: int = Path(..., gt=0),
    updated_data: LabResultUpdate = Depends(),
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    lab_result = db.query(LabResult).filter(
        LabResult.id == lab_result_id,
        LabResult.user_id == user.id
    ).first()

    if not lab_result:
        raise HTTPException(status_code=404, detail="Tahlil bulunamadı.")

    for key, value in updated_data.dict(exclude_unset=True).items():
        setattr(lab_result, key, value)

    db.commit()
    db.refresh(lab_result)
    return lab_result

@router.delete("/{lab_result_id}")
def delete_lab_result(
    lab_result_id: int = Path(..., gt=0),
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    lab_result = db.query(LabResult).filter(
        LabResult.id == lab_result_id,
        LabResult.user_id == user.id
    ).first()

    if not lab_result:
        raise HTTPException(status_code=404, detail="Tahlil bulunamadı.")

    db.delete(lab_result)
    db.commit()
    return {"detail": "Tahlil başarıyla silindi."}
