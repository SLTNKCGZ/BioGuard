from datetime import datetime
from typing import Annotated, List, Optional
import json
import requests
import os

from fastapi import Depends, APIRouter, HTTPException, Request
from pydantic import BaseModel

from sqlalchemy.orm import Session
from starlette import status

from database import SessionLocal
from models import User, Complaint, UserComplaint, UserDisease, UserAllergy, UserMedicine, UserSymptom, Symptom
from routers.auth import get_current_user



def get_db():
    db=SessionLocal()
    try:
        yield db
        db.commit()
    finally:
        db.close()


db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict, Depends(get_current_user)]

router = APIRouter(
    prefix="/complaint",
    tags=["complaint"]
)

def get_user_medical_data(user_id: int, db: Session) -> dict:
    """Kullanıcının tıbbi verilerini getir"""
    # Hastalıklar
    diseases = db.query(UserDisease).filter(UserDisease.user_id == user_id).all()
    disease_names = [disease.disease.title for disease in diseases]
    
    # Alerjiler
    allergies = db.query(UserAllergy).filter(UserAllergy.user_id == user_id).all()
    allergy_names = [allergy.allergy.title for allergy in allergies]
    
    # İlaçlar
    medicines = db.query(UserMedicine).filter(UserMedicine.user_id == user_id).all()
    medicine_names = [medicine.medicine.title for medicine in medicines]
    
    return {
        "diseases": disease_names,
        "allergies": allergy_names,
        "medicines": medicine_names
    }

def analyze_complaint_with_ai(complaint_text: str, medical_data: dict, request: Request) -> dict:
   
    
    # AI prompt'u hazırla
    prompt = f"""
    Sen bir tıbbi analiz uzmanısın. Aşağıdaki hastalık şikayetimi analiz et:
    ŞİKAYETİM: {complaint_text}

    TIBBİ GEÇMİŞİM:
    - Mevcut Hastalıklarım: {', '.join(medical_data['diseases']) if medical_data['diseases'] else 'Yok'}
    - Alerjilerim: {', '.join(medical_data['allergies']) if medical_data['allergies'] else 'Yok'}
    - Kullandığım İlaçlarım: {', '.join(medical_data['medicines']) if medical_data['medicines'] else 'Yok'}
    
    Benim tıbbi geçmişimi dikkate alarak yanıt ver lütfen.
    Lütfen şu sırayla analiz et ve JSON formatında yanıt ver:

    1. Önce şikayetten çıkarılan semptomları sıralı liste olarak ver
    2. Sonra olası hastalıkları, nedenleri ve tedavi yöntemlerini anlatım şeklinde açıkla
    3. Genel bir tıbbi değerlendirme yap

    Yanıt formatı:
    {{
        "symptoms": ["semptom1", "semptom2", "semptom3"],
        "ai_response": "Hasta şikayeti analiz edildi. 
        Olası hastalıklar:
        1.Hastalık 
        [hastalık açıklaması],
        2.Hastalık
        [Hastalık Açıklaması]...
        Olası nedenler: 
        [neden açıklaması]. 
        Önerilen tedavi yöntemleri: 
        1.Hastalık için tedavi
        [tedavi açıklaması].
        2.Hastalık için tedavi... 
        Bu analiz sadece bilgilendirme amaçlıdır, kesin teşhis için mutlaka doktora başvurunuz."
    }}
    """
    
    # Google AI API anahtarını al
    google_api_key = request.app.state.GOOGLE_API_KEY
    
    # Google AI API çağrısı
    if google_api_key:
        try:
            # Google AI API endpoint'i
            url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
            
            headers = {
                "Content-Type": "application/json"
            }
            
            data = {
                "contents": [
                    {
                        "parts": [
                            {
                                "text": f"Sen bir tıbbi analiz uzmanısın. Sadece JSON formatında yanıt ver. {prompt}"
                            }
                        ]
                    }
                ]
            }
            
            response = requests.post(
                f"{url}?key={google_api_key}",
                headers=headers,
                json=data,
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                if "candidates" in result and len(result["candidates"]) > 0:
                    ai_response_text = result["candidates"][0]["content"]["parts"][0]["text"]
                    
                    # JSON yanıtını parse et
                    try:
                        # AI yanıtından JSON kısmını çıkar
                        import re
                        json_match = re.search(r'\{.*\}', ai_response_text, re.DOTALL)
                        if json_match:
                            json_str = json_match.group()
                            ai_result = json.loads(json_str)
                            
                            # Gerekli alanları kontrol et
                            if all(key in ai_result for key in ["symptoms", "ai_response"]):
                                return {
                                    "symptoms": ai_result["symptoms"],
                                    "ai_response": ai_result["ai_response"]
                                }
                    except json.JSONDecodeError as e:
                        print(f"JSON parse error: {e}")
                        print(f"AI response: {ai_response_text}")
            
        except Exception as e:
            print(f"Google AI API Error: {e}")
    
    # Fallback: Simüle edilmiş AI yanıtı (API çalışmazsa)
    print("Using fallback analysis...")
    complaint_lower = complaint_text.lower()
    
   
   
    
    # AI yanıt metni - hastalık, neden ve tedavi açıklaması
    ai_response = f"""
    Hasta şikayeti analiz edildi.
    
    Olası hastalıklar:
    - Genel sağlık durumu değerlendirmesi gereklidir
    
    Olası nedenler:
    - Çeşitli faktörler bu şikayete neden olabilir
    
    Önerilen tedavi yöntemleri:
    - Mutlaka bir doktora başvurmanız önerilir
    - Bu analiz sadece bilgilendirme amaçlıdır, kesin teşhis için mutlaka doktora başvurunuz.
    """
    
    return {
        "symptoms": [],
        "ai_response": ai_response.strip()
    }

def save_symptoms_to_database(symptoms: List[str], user_id: int, db: Session):
    """Semptomları veritabanına kaydet"""
    for symptom_name in symptoms:
        # Önce semptomun var olup olmadığını kontrol et
        symptom = db.query(Symptom).filter(Symptom.title == symptom_name).first()
        if not symptom:
            # Yeni semptom oluştur
            symptom = Symptom(title=symptom_name)
            db.add(symptom)
            db.commit()
            db.refresh(symptom)
        
        # Kullanıcının bu semptomu zaten var mı kontrol et
        existing_user_symptom = db.query(UserSymptom).filter(
            UserSymptom.user_id == user_id,
            UserSymptom.symptom_id == symptom.id
        ).first()
        
        if not existing_user_symptom:
            # Kullanıcıya semptom ekle
            user_symptom = UserSymptom(
                user_id=user_id,
                symptom_id=symptom.id
            )
            db.add(user_symptom)
    
    db.commit()

@router.get("/complaints")
def get_complaint(db: db_dependency,user: user_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    user_obj=db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    return [{"text":user_complaint.complaint.text,"dateTime":user_complaint.complaint.date,"id":user_complaint.complaint.id} for user_complaint in user_obj.complaints]


class ComplaintRequest(BaseModel):
    text: str
    date: datetime


class ComplaintAnalysisResponse(BaseModel):
    complaint_id: int
    original_text: str
    ai_response: str

@router.post("/create", response_model=ComplaintAnalysisResponse)
def create_complaint(complaint_request: ComplaintRequest, request: Request, db: db_dependency, user: user_dependency):
    
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    
    user_obj = db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    # Kullanıcının tıbbi verilerini al
    medical_data = get_user_medical_data(user.get("id"), db)
    
    # AI analizi yap
    ai_analysis = analyze_complaint_with_ai(complaint_request.text, medical_data, request)
    
    # Şikayeti oluştur
    complaint = Complaint(
        text=complaint_request.text, 
        response=ai_analysis["ai_response"], 
        date=complaint_request.date
    )
    
    db.add(complaint)
    db.commit()
    db.refresh(complaint)

    # Kullanıcı-şikayet ilişkisini oluştur
    userComplaint = UserComplaint(user_id=user.get("id"), complaint_id=complaint.id)
    db.add(userComplaint)
    db.commit()
    
    # Semptomları veritabanına kaydet
    if ai_analysis["symptoms"]:
        save_symptoms_to_database(ai_analysis["symptoms"], user.get("id"), db)
    
    return ComplaintAnalysisResponse(
        complaint_id=complaint.id,
        original_text=complaint_request.text,
        ai_response=ai_analysis["ai_response"]
    )

@router.get("/complaints/{complaint_id}")
def get_complaint(complaint_id: int, db: db_dependency,user:user_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not authenticated")
    user_obj = db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    user_complaint = db.query(UserComplaint).filter(UserComplaint.complaint_id == complaint_id , UserComplaint.user_id == user_obj.id).first()
    if user_complaint is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")
    return {"text":user_complaint.complaint.text,"response": user_complaint.complaint.response,"date":user_complaint.complaint.date}


@router.delete("/complaints/{complaint_id}")
def delete_complaint(complaint_id: int, db: db_dependency, user: user_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")

    user_obj = db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    # UserComplaint'i getirme
    user_complaint = db.query(UserComplaint).filter(
        UserComplaint.complaint_id == complaint_id,
        UserComplaint.user_id == user_obj.id
    ).first()

    if user_complaint is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")

    # Complaint objesini al
    complaint = db.query(Complaint).filter(Complaint.id == complaint_id).first()
    if complaint is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Complaint not found")

    # Nesneleri sil
    db.delete(user_complaint)
    db.flush()  # <== özellikle burada flush, ilişki hatalarını önler
    db.delete(complaint)
    db.commit()

    return {"message": "Complaint deleted successfully"}





