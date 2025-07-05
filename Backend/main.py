from fastapi import FastAPI, APIRouter

from database import Base, engine
from routers import auth, disease, allergy, symptom, medicine
from routers.auth import authenticate, db_dependency

app = FastAPI()

app.include_router(auth.router)
app.include_router(disease.router)
app.include_router(allergy.router)
app.include_router(symptom.router)
app.include_router(medicine.router)
Base.metadata.create_all(bind=engine)

