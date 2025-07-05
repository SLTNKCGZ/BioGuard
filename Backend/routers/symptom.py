from pydantic import BaseModel
from sqlalchemy.orm import Session
from starlette import status

from database import SessionLocal
from models import Symptom, UserSymptom, User
from routers.auth import db_dependency, get_current_user
from typing import Annotated
from fastapi import Depends, APIRouter, HTTPException


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


user_dependency = Annotated[dict, Depends(get_current_user)]


class SymptomRequest(BaseModel):
    title: str


router = APIRouter(
    prefix="/symptom",
    tags=["Symptom"]
)


@router.post("/create")
def create_symptom(input_symptom: SymptomRequest, db: db_dependency, user: user_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    # Semptom var mı kontrol et, yoksa oluştur
    symptom = db.query(Symptom).filter(Symptom.title == input_symptom.title).first()
    if symptom is None:
        symptom = Symptom(title=input_symptom.title)
        db.add(symptom)
        db.commit()
        db.refresh(symptom)
    
    # Kullanıcıya semptom ekle
    user_symptom = UserSymptom(symptom_id=symptom.id, user_id=user.get("id"))
    db.add(user_symptom)
    db.commit()
    
    return {"message": "Symptom added to user", "symptom": {"id": symptom.id, "title": symptom.title}}


@router.get("/symptoms")
def get_symptoms(user: user_dependency, db: db_dependency):
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    # Kullanıcının semptomlarını getir
    user_obj = db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    return [{"id": symptom.id, "title": symptom.title} for symptom in user_obj.symptoms]


@router.put("/update/{symptom_id}")
def update_symptom(symptom_id: int, symptom: SymptomRequest, db: db_dependency, user: user_dependency):
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    
    # Semptomu bul
    existing_symptom = db.query(Symptom).filter(Symptom.id == symptom_id).first()
    if not existing_symptom:
        raise HTTPException(status_code=404, detail="Symptom not found")
    
    # Semptom adını güncelle
    existing_symptom.title = symptom.title
    db.commit()
    
    return {"message": "Symptom updated successfully", "symptom": {"id": existing_symptom.id, "title": existing_symptom.title}}


@router.delete("/delete/{symptom_id}")
def delete_symptom(user: user_dependency, db: db_dependency, symptom_id: int):
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Kullanıcının bu semptomla ilişkisini bul
    user_symptom = db.query(UserSymptom).filter(
        UserSymptom.symptom_id == symptom_id,
        UserSymptom.user_id == user.get("id")
    ).first()
    
    if not user_symptom:
        raise HTTPException(status_code=404, detail="User doesn't have this symptom")
    
    # Kullanıcının bu semptomla ilişkisini sil
    db.delete(user_symptom)
    db.commit()
    
    # Eğer bu semptoma sahip başka kullanıcı yoksa, semptomu da sil
    remaining_users = db.query(UserSymptom).filter(UserSymptom.symptom_id == symptom_id).count()
    if remaining_users == 0:
        symptom = db.query(Symptom).filter(Symptom.id == symptom_id).first()
        if symptom:
            db.delete(symptom)
            db.commit()
    
    return {"message": "Symptom removed from user"}


@router.delete("/delete-by-title/{symptom_title}")
def delete_symptom_by_title(user: user_dependency, db: db_dependency, symptom_title: str):
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Semptomu bul
    symptom = db.query(Symptom).filter(Symptom.title == symptom_title).first()
    if not symptom:
        raise HTTPException(status_code=404, detail="Symptom not found")
    
    # Kullanıcının bu semptomla ilişkisini bul
    user_symptom = db.query(UserSymptom).filter(
        UserSymptom.symptom_id == symptom.id,
        UserSymptom.user_id == user.get("id")
    ).first()
    
    if not user_symptom:
        raise HTTPException(status_code=404, detail="User doesn't have this symptom")
    
    # Kullanıcının bu semptomla ilişkisini sil
    db.delete(user_symptom)
    db.commit()
    
    # Eğer başka kullanıcı yoksa semptomu da sil
    remaining_users = db.query(UserSymptom).filter(UserSymptom.symptom_id == symptom.id).count()
    if remaining_users == 0:
        db.delete(symptom)
        db.commit()
    
    return {"message": f"Symptom '{symptom_title}' removed from user"}

@router.delete("/user_symptom")
def delete_user_symptoms(db: db_dependency, user: user_dependency):
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Kullanıcının tüm semptomlarını bul
    user_symptoms = db.query(UserSymptom).filter(UserSymptom.user_id == user.get("id")).all()
    
    if not user_symptoms:
        raise HTTPException(status_code=404, detail="User has no symptoms")
    
    # Kullanıcının tüm semptomlarını sil
    for user_symptom in user_symptoms:
        db.delete(user_symptom)
    
    db.commit()
    
    return {"message": "All user symptoms deleted successfully"}