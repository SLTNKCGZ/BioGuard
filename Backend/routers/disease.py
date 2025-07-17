

from pydantic import BaseModel
from sqlalchemy.orm import Session
from starlette import status

from database import SessionLocal
from models import Disease, UserDisease, User
from routers.auth import get_current_user
from typing import Annotated
from fastapi import Depends, APIRouter, HTTPException
from sqlalchemy.orm import Session


def get_db():
    db=SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session,Depends(get_db)]
user_dependency=Annotated[dict,Depends(get_current_user)]
class DiseaseRequest(BaseModel):
    title: str

router=APIRouter(
    prefix="/disease",
    tags=["Disease"]
)

@router.post("/create")
def create_disaster(input_disease: DiseaseRequest, db: db_dependency, user: user_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    disease = db.query(Disease).filter(Disease.title == input_disease.title).first()
    if disease is None:
        disease = Disease(title=input_disease.title)
        db.add(disease)
        db.commit()
        db.refresh(disease)

    user_disease = db.query(UserDisease).filter(
        UserDisease.disease_id == disease.id,
        UserDisease.user_id == user.get("id")
    ).first()
    if user_disease is not None:
        raise HTTPException(status_code=400, detail="User already has this disease")
    userDisease = UserDisease(disease_id=disease.id, user_id=user.get("id"))
    db.add(userDisease)
    db.commit()
    return {"message": "Disease added to user"}


@router.get("/diseases")
def get_diseases(user: user_dependency, db: db_dependency):
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    user_obj = db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    # Pydantic model ile serialize etmek daha iyi olur
    return [user_disease.disease.title for user_disease in user_obj.diseases]

@router.put("/update")
def update_disease(disease: DiseaseRequest, db: db_dependency, user: user_dependency):
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    

    user_disease = db.query(UserDisease).filter(UserDisease.user_id == user.get("id")).first()
    if not user_disease:
        raise HTTPException(status_code=404, detail="User doesn't have any disease to update")
    

    new_disease = db.query(Disease).filter(Disease.title == disease.title).first()
    if not new_disease:
        new_disease = Disease(title=disease.title)
        db.add(new_disease)
        db.commit()
        db.refresh(new_disease)
    

    old_disease_id = user_disease.disease_id
    user_disease.disease_id = new_disease.id
    db.commit()
    

    remaining_users = db.query(UserDisease).filter(UserDisease.disease_id == old_disease_id).count()
    if remaining_users == 0:
        old_disease = db.query(Disease).filter(Disease.id == old_disease_id).first()
        if old_disease:
            db.delete(old_disease)
            db.commit()
    
    return {"message": "Disease updated successfully"}

@router.delete("/delete/{disease_id}")
def delete_user_disease(user: user_dependency, db: db_dependency, disease_id: int):
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Kullanıcının bu hastalıkla ilişkisini bul
    user_disease = db.query(UserDisease).filter(
        UserDisease.disease_id == disease_id,
        UserDisease.user_id == user.get("id")
    ).first()
    
    if not user_disease:
        raise HTTPException(status_code=404, detail="User doesn't have this disease")
    
    # Kullanıcının bu hastalıkla ilişkisini sil
    db.delete(user_disease)
    db.commit()
    
    # Eğer bu hastalığa sahip başka kullanıcı yoksa, hastalığı da sil
    remaining_users = db.query(UserDisease).filter(UserDisease.disease_id == disease_id).count()
    if remaining_users == 0:
        disease = db.query(Disease).filter(Disease.id == disease_id).first()
        if disease:
            db.delete(disease)
            db.commit()
    
    return {"message": "Disease removed from user"}


@router.delete("/delete-by-title/{disease_title}")
def delete_user_disease_by_title(user: user_dependency, db: db_dependency, disease_title: str):
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Hastalığı bul
    disease = db.query(Disease).filter(Disease.title == disease_title).first()
    if not disease:
        raise HTTPException(status_code=404, detail="Disease not found")
    
    # Kullanıcının bu hastalıkla ilişkisini bul
    user_disease = db.query(UserDisease).filter(
        UserDisease.disease_id == disease.id,
        UserDisease.user_id == user.get("id")
    ).first()
    
    if not user_disease:
        raise HTTPException(status_code=404, detail="User doesn't have this disease")
    
    # İlişkiyi sil
    db.delete(user_disease)
    db.commit()
    
    # Eğer başka kullanıcı yoksa hastalığı da sil
    remaining_users = db.query(UserDisease).filter(UserDisease.disease_id == disease.id).count()
    if remaining_users == 0:
        db.delete(disease)
        db.commit()
    
    return {"message": f"Disease '{disease_title}' removed from user"}