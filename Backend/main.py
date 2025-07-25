from fastapi import FastAPI, APIRouter

from database import Base, engine
from routers import auth, disease, allergy, symptom, medicine, complaint


app = FastAPI()

app.include_router(auth.router)
app.include_router(disease.router)
app.include_router(allergy.router)
app.include_router(symptom.router)
app.include_router(medicine.router)
app.include_router(complaint.router)
Base.metadata.create_all(bind=engine)

