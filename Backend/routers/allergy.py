from pydantic import BaseModel
from sqlalchemy.orm import Session
from starlette import status

from database import SessionLocal
from models import Allergy, UserAllergy, User
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


class AllergyRequest(BaseModel):
    title: str


router = APIRouter(
    prefix="/allergy",
    tags=["Allergy"]
)


@router.post("/create")
def create_allergy(input_allergy: AllergyRequest, db: db_dependency, user: user_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    allergy = db.query(Allergy).filter(Allergy.title == input_allergy.title).first()
    if allergy is None:
        allergy = Allergy(title=input_allergy.title)
        db.add(allergy)
        db.commit()
        db.refresh(allergy)
    
    # Aynı ilişki var mı kontrolü
    user_allergy = db.query(UserAllergy).filter(
        UserAllergy.allergy_id == allergy.id,
        UserAllergy.user_id == user.get("id")
    ).first()
    if user_allergy is not None:
        raise HTTPException(status_code=400, detail="User already has this allergy")
    
    userAllergy = UserAllergy(allergy_id=allergy.id, user_id=user.get("id"))
    db.add(userAllergy)
    db.commit()
    return {"message": "Allergy added to user"}


@router.get("/allergies")
def get_allergies(user: user_dependency, db: db_dependency):
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    user_obj = db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    # Pydantic model ile serialize etmek daha iyi olur
    return [allergy.title for allergy in user_obj.allergies]


@router.put("/update")
def update_allergy(allergy: AllergyRequest, db: db_dependency, user: user_dependency):
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    
    # Kullanıcının mevcut alerji ilişkisini bul
    user_allergy = db.query(UserAllergy).filter(UserAllergy.user_id == user.get("id")).first()
    if not user_allergy:
        raise HTTPException(status_code=404, detail="User doesn't have any allergy to update")
    
    # Yeni alerji var mı kontrol et
    new_allergy = db.query(Allergy).filter(Allergy.title == allergy.title).first()
    if not new_allergy:
        new_allergy = Allergy(title=allergy.title)
        db.add(new_allergy)
        db.commit()
        db.refresh(new_allergy)
    
    # Eski alerji ilişkisini güncelle
    old_allergy_id = user_allergy.allergy_id
    user_allergy.allergy_id = new_allergy.id
    db.commit()
    
    # Eski alerjiye sahip başka kullanıcı yoksa sil
    remaining_users = db.query(UserAllergy).filter(UserAllergy.allergy_id == old_allergy_id).count()
    if remaining_users == 0:
        old_allergy = db.query(Allergy).filter(Allergy.id == old_allergy_id).first()
        if old_allergy:
            db.delete(old_allergy)
            db.commit()
    
    return {"message": "Allergy updated successfully"}


@router.delete("/delete/{allergy_id}")
def delete_user_allergy(user: user_dependency, db: db_dependency, allergy_id: int):
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Kullanıcının bu alerjiyle ilişkisini bul
    user_allergy = db.query(UserAllergy).filter(
        UserAllergy.allergy_id == allergy_id,
        UserAllergy.user_id == user.get("id")
    ).first()
    
    if not user_allergy:
        raise HTTPException(status_code=404, detail="User doesn't have this allergy")
    
    # Kullanıcının bu alerjiyle ilişkisini sil
    db.delete(user_allergy)
    db.commit()
    
    # Eğer bu alerjiye sahip başka kullanıcı yoksa, alerjiyi de sil
    remaining_users = db.query(UserAllergy).filter(UserAllergy.allergy_id == allergy_id).count()
    if remaining_users == 0:
        allergy = db.query(Allergy).filter(Allergy.id == allergy_id).first()
        if allergy:
            db.delete(allergy)
            db.commit()
    
    return {"message": "Allergy removed from user"}


@router.delete("/delete-by-title/{allergy_title}")
def delete_user_allergy_by_title(user: user_dependency, db: db_dependency, allergy_title: str):
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Alerjiyi bul
    allergy = db.query(Allergy).filter(Allergy.title == allergy_title).first()
    if not allergy:
        raise HTTPException(status_code=404, detail="Allergy not found")
    
    # Kullanıcının bu alerjiyle ilişkisini bul
    user_allergy = db.query(UserAllergy).filter(
        UserAllergy.allergy_id == allergy.id,
        UserAllergy.user_id == user.get("id")
    ).first()
    
    if not user_allergy:
        raise HTTPException(status_code=404, detail="User doesn't have this allergy")
    
    # İlişkiyi sil
    db.delete(user_allergy)
    db.commit()
    
    # Eğer başka kullanıcı yoksa alerjiyi de sil
    remaining_users = db.query(UserAllergy).filter(UserAllergy.allergy_id == allergy.id).count()
    if remaining_users == 0:
        db.delete(allergy)
        db.commit()
    
    return {"message": f"Allergy '{allergy_title}' removed from user"}
