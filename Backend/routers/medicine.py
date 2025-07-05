
from pydantic import BaseModel
from sqlalchemy.orm import Session
from starlette import status

from database import SessionLocal
from models import Medicine, UserMedicine, User
from routers.auth import get_current_user
from typing import Annotated
from fastapi import Depends, APIRouter, HTTPException
from sqlalchemy.orm import Session


def get_db():
    db =SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session ,Depends(get_db)]
user_dependency =Annotated[dict ,Depends(get_current_user)]
class MedicineRequest(BaseModel):
    title: str

router =APIRouter(
    prefix="/medicine",
    tags=["Medicine"]
)

@router.post("/create")
def create_medicine(input_medicine: MedicineRequest, db: db_dependency, user: user_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    medicine = db.query(Medicine).filter(Medicine.title == input_medicine.title).first()
    if medicine is None:
        medicine = Medicine(title=input_medicine.title)
        db.add(medicine)
        db.commit()
        db.refresh(medicine)

    user_medicine = db.query(UserMedicine).filter(
        UserMedicine.medicine_id == medicine.id,
        UserMedicine.user_id == user.get("id")
    ).first()
    if user_medicine is not None:
        raise HTTPException(status_code=400, detail="User already has this medicine")
    userMedicine = UserMedicine(medicine_id=medicine.id, user_id=user.get("id"))
    db.add(userMedicine)
    db.commit()
    return {"message": "medicine added to user"}


@router.get("/medicines")
def get_medicines(user: user_dependency, db: db_dependency):
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    user_obj = db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    # Pydantic model ile serialize etmek daha iyi olur
    return [medicine.title for medicine in user_obj.medicines]

@router.put("/update")
def update_medicine(medicine: MedicineRequest, db: db_dependency, user: user_dependency):
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")


    user_medicine = db.query(UserMedicine).filter(UserMedicine.user_id == user.get("id")).first()
    if not user_medicine:
        raise HTTPException(status_code=404, detail="User doesn't have any medicine to update")


    new_medicine = db.query(Medicine).filter(Medicine.title == medicine.title).first()
    if not new_medicine:
        new_medicine = Medicine(title=medicine.title)
        db.add(new_medicine)
        db.commit()
        db.refresh(new_medicine)


    old_medicine_id = user_medicine.medicine_id
    user_medicine.medicine_id = new_medicine.id
    db.commit()


    remaining_users = db.query(UserMedicine).filter(UserMedicine.medicine_id == old_medicine_id).count()
    if remaining_users == 0:
        old_medicine = db.query(Medicine).filter(Medicine.id == old_medicine_id).first()
        if old_medicine:
            db.delete(old_medicine)
            db.commit()

    return {"message": "medicine updated successfully"}

@router.delete("/delete/{medicine_id}")
def delete_user_medicine(user: user_dependency, db: db_dependency, medicine_id: int):
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")

    # Kullanıcının bu hastalıkla ilişkisini bul
    user_medicine = db.query(UserMedicine).filter(
        UserMedicine.medicine_id == medicine_id,
        UserMedicine.user_id == user.get("id")
    ).first()

    if not user_medicine:
        raise HTTPException(status_code=404, detail="User doesn't have this medicine")

    # Kullanıcının bu hastalıkla ilişkisini sil
    db.delete(user_medicine)
    db.commit()

    # Eğer bu hastalığa sahip başka kullanıcı yoksa, hastalığı da sil
    remaining_users = db.query(UserMedicine).filter(UserMedicine.medicine_id == medicine_id).count()
    if remaining_users == 0:
        medicine = db.query(Medicine).filter(Medicine.id == medicine_id).first()
        if medicine:
            db.delete(medicine)
            db.commit()

    return {"message": "medicine removed from user"}


@router.delete("/delete-by-title/{medicine_title}")
def delete_user_medicine_by_title(user: user_dependency, db: db_dependency, medicine_title: str):
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")

    # Hastalığı bul
    medicine = db.query(Medicine).filter(Medicine.title == medicine_title).first()
    if not medicine:
        raise HTTPException(status_code=404, detail="medicine not found")

    # Kullanıcının bu hastalıkla ilişkisini bul
    user_medicine = db.query(UserMedicine).filter(
        UserMedicine.medicine_id == medicine.id,
        UserMedicine.user_id == user.get("id")
    ).first()

    if not user_medicine:
        raise HTTPException(status_code=404, detail="User doesn't have this medicine")

    # İlişkiyi sil
    db.delete(user_medicine)
    db.commit()

    # Eğer başka kullanıcı yoksa hastalığı da sil
    remaining_users = db.query(UserMedicine).filter(UserMedicine.medicine_id == medicine.id).count()
    if remaining_users == 0:
        db.delete(medicine)
        db.commit()

    return {"message": f"medicine '{medicine_title}' removed from user"}