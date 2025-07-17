from datetime import timedelta, datetime, timezone
from typing import Annotated
from jose import JWTError,jwt
from fastapi import APIRouter, Depends , HTTPException
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from passlib.context import CryptContext
from pydantic import BaseModel
from sqlalchemy.orm import Session
from starlette import status
from database import SessionLocal
from models import User

router = APIRouter(
    prefix="/auth",
    tags=["Auth"]
)
class CreateUserRequest(BaseModel):
    username: str
    email: str
    firstName: str
    lastName: str
    password: str
    gender: str
    birthdate: datetime

class Token(BaseModel):
    token: str
    type: str


def get_db():
    db=SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency=Annotated[Session,Depends(get_db)]
bcrypt_context=CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_bearer=OAuth2PasswordBearer(tokenUrl="/auth/login")

@router.post("/")
def create_user(createUser:CreateUserRequest,db:db_dependency):
    user=User(
        username=createUser.username,
        email=createUser.email,
        first_name=createUser.firstName,
        last_name=createUser.lastName,
        hashed_password=bcrypt_context.hash(createUser.password),
        gender=createUser.gender,
        birthdate=createUser.birthdate
    )
    db.add(user)
    db.commit()


SECRET_KEY="dv1hyoGQsV09jMF1htLibVWGG4sSPLGZTEgeaVRZCZG26OikBUyQLEHxi9gY6CTV"
ALGORITHM="HS256"

def create_access_token(username:str, user_id:int, expires_delta:timedelta):
    to_encode={"sub":username,"id":user_id}
    expire= datetime.now(timezone.utc) + expires_delta
    to_encode.update({"exp":expire})
    encoded_jwt=jwt.encode(to_encode,SECRET_KEY,algorithm=ALGORITHM)
    return encoded_jwt


@router.post("/login")
def login(form_data: Annotated[OAuth2PasswordRequestForm, Depends()], db: db_dependency):
    print(f"Login attempt for username: {form_data.username}")  # Debug
    user = authenticate(form_data.username, form_data.password, db)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect username or password")
    token = create_access_token(user.username, user.id, timedelta(minutes=30))
    print(f"Generated token: {token[:20]}...")  # Debug
    return {"access_token": token, "token_type": "bearer"}




def authenticate(username, password,db):
    user=db.query(User).filter(User.username==username).first()
    if not user:
        print("User not found")
        return False
    if not bcrypt_context.verify(password,user.hashed_password):
        print("Incorrect password")
        return False
    return user


async def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]):
    print(f"Received token: {token}")  # Debug için
    
    if not token or token == "undefined":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token is missing or invalid")
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get('sub')
        user_id = payload.get('id')
        print(f"Decoded payload: username={username}, user_id={user_id}")  # Debug için
        
        if username is None or user_id is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token payload")
        return {"username": username, "id": user_id}
    except JWTError as e:
        print(f"JWT Error: {e}")  # Debug için
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

@router.put("/update")
def update_user(
    user: Annotated[dict, Depends(get_current_user)],
    updateUser: CreateUserRequest,
    db: db_dependency
):
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    update = db.query(User).filter(User.username == user.get("username")).first()
    if update is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    update.first_name = updateUser.firstName
    update.last_name = updateUser.lastName
    update.hashed_password = bcrypt_context.hash(updateUser.password)
    update.email = updateUser.email

    if update.username != updateUser.username:
        if db.query(User).filter(User.username == updateUser.username).first():
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already exists")
        update.username = updateUser.username
    db.commit()
    return {"message": "User updated successfully"}

@router.delete("/delete")
def delete_user(user: Annotated[dict, Depends(get_current_user)], db: db_dependency):
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    user_obj = db.query(User).filter(User.username == user.get("username")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    db.delete(user_obj)
    db.commit()
    return {"message": "User deleted successfully"}

@router.get("/me")
def get_me(db: db_dependency, user: Annotated[dict, Depends(get_current_user)]):
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    user_obj = db.query(User).filter(User.id == user.get("id")).first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return {
        "username": user_obj.username,
        "email": user_obj.email,
        "firstName": user_obj.first_name,
        "lastName": user_obj.last_name,
        "gender": user_obj.gender,
        "birthdate": user_obj.birthdate.isoformat() if user_obj.birthdate else "",
    }



