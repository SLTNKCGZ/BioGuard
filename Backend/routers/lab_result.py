from fastapi import APIRouter, Depends, HTTPException, Path, Body, status
from sqlalchemy.orm import Session
from database import get_db
from routers.auth import get_current_user
from models import LabResult, User
from pydantic import BaseModel, field_validator
from typing import Optional, List, Union
from datetime import date

router = APIRouter(
    prefix="/lab_results",
    tags=["Lab Results"])


class LabResultCreate(BaseModel):
    test: str  # Frontend'den gelen alan adı
    result: float
    unit: str
    date: str  # String olarak al


class LabResultUpdate(BaseModel):
    test: Optional[str] = None  # Frontend'den gelen alan adı
    result: Optional[float] = None
    unit: Optional[str] = None
    date: Optional[str] = None  # String olarak al


class LabResultOut(BaseModel):
    id: int
    test: str  # Frontend'e gönderilen alan adı
    result: float
    unit: str
    date: date

    class Config:
        from_attributes = True


@router.post("/create", response_model=LabResultOut)
def add_lab_result(
    lab_result: LabResultCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    try:
        print("=== CREATE LAB RESULT DEBUG ===")
        print(f"Create lab result request received: {lab_result}")
        print(f"Create lab result type: {type(lab_result)}")
        print(f"Create lab result test: {lab_result.test}")
        print(f"Create lab result result: {lab_result.result}")
        print(f"Create lab result unit: {lab_result.unit}")
        print(f"Create lab result date: {lab_result.date}")
        print(f"Current user: {current_user}")
        print(f"Date type: {type(lab_result.date)}, value: {lab_result.date}")
        print(f"Date string value: {lab_result.date}")
        print("=== END CREATE DEBUG ===")
        
        if current_user is None:
            raise HTTPException(status_code=403, detail="Not authenticated")

        # Tarihi manuel olarak dönüştür
        from datetime import datetime
        try:
            parsed_date = datetime.strptime(lab_result.date, '%Y-%m-%d').date()
        except ValueError:
            raise HTTPException(status_code=422, detail=f"Geçersiz tarih formatı: {lab_result.date}. YYYY-MM-DD formatında olmalıdır.")
        
        new_result = LabResult(
            test_name=lab_result.test,  # Frontend'den gelen 'test' alanını 'test_name' olarak kaydet
            user_id=current_user["id"],
            result=lab_result.result, 
            unit=lab_result.unit, 
            date=parsed_date
        )
        print(f"Creating new lab result: {new_result.test_name}, {new_result.result}, {new_result.unit}, {new_result.date}")
        
        db.add(new_result)
        db.commit()
        db.refresh(new_result)
        print(f"Lab result created with ID: {new_result.id}")
        
        return LabResultOut(
            id=new_result.id,
            test=new_result.test_name,  # Veritabanındaki 'test_name' alanını 'test' olarak gönder
            result=new_result.result,
            unit=new_result.unit,
            date=new_result.date
        )
    except Exception as e:
        print(f"Create lab result error: {e}")
        print(f"Error type: {type(e)}")
        raise HTTPException(status_code=422, detail=f"Oluşturma hatası: {str(e)}")


@router.get("/lab_results", response_model=List[LabResultOut])
def get_user_lab_results(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    lab_results = (
        db.query(LabResult)
        .filter(LabResult.user_id == current_user["id"])
        .order_by(LabResult.date.desc())
        .all()
    )
    
    return [
        LabResultOut(
            id=result.id,
            test=result.test_name,  # Veritabanındaki 'test_name' alanını 'test' olarak gönder
            result=result.result,
            unit=result.unit,
            date=result.date
        )
        for result in lab_results
    ]


@router.put("/{lab_result_id}", response_model=LabResultOut)
def update_lab_result(
    lab_result_id: int = Path(..., gt=0),
    updated_data: LabResultUpdate = Body(...),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    try:
        # Debug için request data'sını yazdır
        print("=== UPDATE LAB RESULT DEBUG ===")
        print(f"Update Request Data: {updated_data}")
        print(f"Update Request Data type: {type(updated_data)}")
        print(f"Update Request Data test: {updated_data.test}")
        print(f"Update Request Data result: {updated_data.result}")
        print(f"Update Request Data unit: {updated_data.unit}")
        print(f"Update Request Data date: {updated_data.date}")
        print(f"Update Request Data date type: {type(updated_data.date) if updated_data.date else 'None'}")
        print(f"Update Request Data date string value: {updated_data.date}")
        print("=== END UPDATE DEBUG ===")
        
        lab_result = db.query(LabResult).filter(
            LabResult.id == lab_result_id,
            LabResult.user_id == current_user["id"]
        ).first()

        if not lab_result:
            raise HTTPException(status_code=404, detail="Tahlil bulunamadı.")

        if updated_data.test is not None:
            lab_result.test_name = updated_data.test  # Frontend'den gelen 'test' alanını 'test_name' olarak güncelle
        if updated_data.result is not None:
            lab_result.result = updated_data.result
        if updated_data.unit is not None:
            lab_result.unit = updated_data.unit
        if updated_data.date is not None:
            # Tarihi manuel olarak dönüştür
            from datetime import datetime
            try:
                parsed_date = datetime.strptime(updated_data.date, '%Y-%m-%d').date()
                lab_result.date = parsed_date
            except ValueError:
                raise HTTPException(status_code=422, detail=f"Geçersiz tarih formatı: {updated_data.date}. YYYY-MM-DD formatında olmalıdır.")

        print(f"Updated lab result: {lab_result.test_name}, {lab_result.result}, {lab_result.unit}, {lab_result.date}")

        db.commit()
        db.refresh(lab_result)
        
        return LabResultOut(
            id=lab_result.id,
            test=lab_result.test_name,  # Veritabanındaki 'test_name' alanını 'test' olarak gönder
            result=lab_result.result,
            unit=lab_result.unit,
            date=lab_result.date
        )
    except Exception as e:
        print(f"Update lab result error: {e}")
        print(f"Error type: {type(e)}")
        raise HTTPException(status_code=422, detail=f"Güncelleme hatası: {str(e)}")


@router.delete("/{lab_result_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_lab_result(
    lab_result_id: int = Path(..., gt=0),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    lab_result = db.query(LabResult).filter(
        LabResult.id == lab_result_id,
        LabResult.user_id == current_user["id"]
    ).first()

    if not lab_result:
        raise HTTPException(status_code=404, detail="Tahlil bulunamadı.")

    db.delete(lab_result)
    db.commit()
    return 