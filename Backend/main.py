from dotenv import load_dotenv
from fastapi import FastAPI, APIRouter
import os
from database import Base, engine
from routers import auth, disease, allergy, symptom, medicine, complaint, lab_result

app = FastAPI()

app.include_router(auth.router)
app.include_router(disease.router)
app.include_router(allergy.router)
app.include_router(symptom.router)
app.include_router(medicine.router)
app.include_router(complaint.router)
app.include_router(lab_result.router)


load_dotenv()

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

# API anahtarını global olarak erişilebilir hale getir
app.state.GOOGLE_API_KEY = GOOGLE_API_KEY

Base.metadata.create_all(bind=engine)


