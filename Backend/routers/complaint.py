from datetime import datetime
from typing import Annotated

from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel

from sqlalchemy.orm import Session
from starlette import status

from database import SessionLocal
from models import User, Complaint, UserComplaint
from routers.auth import get_current_user



def get_db():
    db=SessionLocal()
    try:
        yield db
        db.commit()
    finally:
        db.close()


db_dependency= Annotated[Session, Depends(get_db)]
user_dependency= Annotated[dict, Depends(get_current_user)]

router = APIRouter(
    prefix="/complaint",
    tags=["complaint"]
)

@router.get("/complaints")
def get_complaint(db: db_dependency,user: user_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    user_obj=db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    return [{"text":user_complaint.complaint.text,"dateTime":user_complaint.complaint.date,"id":user_complaint.complaint.id} for user_complaint in user_obj.complaints]


class ComplaintRequest(BaseModel):
    text:str
    response:str
    date: datetime

@router.post("/create")
def create_complaint(complaint_request: ComplaintRequest, db: db_dependency,user:user_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not authenticated")
    user_obj=db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    complaint=Complaint(text=complaint_request.text, response=complaint_request.response,date=complaint_request.date)
    db.add(complaint)
    db.commit()
    db.refresh(complaint)

    userComplaint=UserComplaint(user_id=user.get("id"),complaint_id=complaint.id)
    db.add(userComplaint)
    db.commit()
    db.refresh(userComplaint)
    return {"message":"Complaint created successfully"}

@router.get("/complaints/{complaint_id}")
def get_complaint(complaint_id: int, db: db_dependency,user:user_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not authenticated")
    user_obj = db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    user_complaint = db.query(UserComplaint).filter(UserComplaint.id == complaint_id , user_obj.id == UserComplaint.user_id).first()
    if user_complaint is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")
    return [user_complaint.complaint.text, user_complaint.complaint.response,user_complaint.complaint.date]

@router.delete("/complaints/{complaint_id}")
def delete_complaint(complaint_id: int, db: db_dependency,user:user_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not authenticated")

    user_obj = db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    user_complaint = db.query(UserComplaint).filter(UserComplaint.id == complaint_id , user_obj.id == UserComplaint.user_id).first()
    if user_complaint is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")
    db.delete(user_complaint)
    db.commit()
    db.refresh(user_complaint)
    return {"message":"Complaint deleted successfully"}




