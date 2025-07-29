import datetime

from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Date
from sqlalchemy.orm import relationship

from database import Base


class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True,index=True)
    username=Column(String,unique=True)
    email = Column(String,unique=True)
    first_name = Column(String)
    last_name = Column(String)
    hashed_password = Column(String)
    gender = Column(String)
    birthdate= Column(Date)
    allergies = relationship("UserAllergy", back_populates="user",cascade="all, delete-orphan")
    diseases = relationship("UserDisease", back_populates="user",cascade="all, delete-orphan")
    symptoms = relationship("UserSymptom", back_populates="user",cascade="all, delete-orphan")
    medicines=relationship("UserMedicine", back_populates="user",cascade="all, delete-orphan")
    complaints=relationship("UserComplaint", back_populates="user",cascade="all, delete-orphan")

    
class Disease(Base):
    __tablename__ = "diseases"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)


class Allergy(Base):
    __tablename__ = "allergies"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)

class Symptom(Base):
    __tablename__ = "symptoms"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)

class Medicine(Base):
    __tablename__ = "medicines"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)

class Complaint(Base):
    __tablename__ = "complaints"
    id = Column(Integer, primary_key=True, index=True)
    text= Column(String)
    response= Column(String)
    date= Column(DateTime)

class UserDisease(Base):
    __tablename__ = "user_diseases"
    id = Column(Integer, primary_key=True, index=True)
    disease_id = Column(Integer, ForeignKey("diseases.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="diseases")
    disease = relationship("Disease")


class UserAllergy(Base):
    __tablename__ = "user_allergies"
    id = Column(Integer, primary_key=True, index=True)
    allergy_id = Column(Integer, ForeignKey("allergies.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="allergies")
    allergy = relationship("Allergy")

class UserSymptom(Base):
    __tablename__ = "user_symptoms"
    id = Column(Integer, primary_key=True, index=True)
    symptom_id = Column(Integer, ForeignKey("symptoms.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="symptoms")
    symptom = relationship("Symptom")

class UserMedicine(Base):
    __tablename__ = "user_medicines"
    id = Column(Integer, primary_key=True, index=True)
    medicine_id = Column(Integer, ForeignKey("medicines.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="medicines")
    medicine = relationship("Medicine")

class UserComplaint(Base):
    __tablename__ = "user_complaints"
    id = Column(Integer, primary_key=True, index=True)
    user_id=Column(Integer, ForeignKey("users.id"))
    complaint_id = Column(Integer, ForeignKey("complaints.id"))
    complaint = relationship("Complaint")
    user = relationship("User", back_populates="complaints")

