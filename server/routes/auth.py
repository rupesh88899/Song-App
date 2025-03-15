from fastapi import APIRouter, Header  #this helps in routing

import uuid
import bcrypt
from fastapi import Depends, HTTPException
import jwt
from database import get_db
from middleware.auth_middleware import auth_middleware
from models.user import User
from pydantic_schemas.user_create import UserCreate
from sqlalchemy.orm import Session, joinedload
from pydantic_schemas.user_login import UserLogin


#this helps to get key frfom env file
import os
from dotenv import load_dotenv
load_dotenv()


router = APIRouter()  # using this we dnt have to use @app.post instead we can use @router.post at many places


#signup api route
@router.post('/signup', status_code=201)
def signup_user(user: UserCreate, db: Session=Depends(get_db)):

    #1 extract the data thats coming from request
 

    #2 setup db before doing this and connect framework with postGreSQl server using SQLAlchemy
    # we need database for this db(postGreSQL) setup db before doing this
    #check if user is already exist in db and give error if exist 
    user_db = db.query(User).filter(User.email == user.email).first()

    if user_db:
        raise HTTPException(400, 'User with the same email already exist!')

    # 3 we need database for this db(postGreSQL)
    # add user to db if new user
    hashed_pw = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())
    user_db = User(id=str(uuid.uuid4()),email=user.email, password=hashed_pw,name=user.name)
    db.add(user_db)  
    db.commit()  #since we make autocomit = false we have to commit manually
    db.refresh(user_db) #refreshed attributes at instance to reflect changes

    return user_db



@router.post('/login')
def login_user(user: UserLogin, db: Session=Depends(get_db)):
    #check if user with this email exist or not
    
    user_db = db.query(User).filter(User.email == user.email).first()

    if not user_db:
        raise HTTPException(400, 'User with this email does not exist!')
                
    #if user exist then check # matching password or not
    #since pasward in db is hashed we have to compare with hashed password
    is_match = bcrypt.checkpw(user.password.encode(), user_db.password)
   
   #if not match
    if not is_match:
        raise HTTPException(400, 'Incorrect Password!')
    
    #after pasward maching we create JWT- json web token for user persistance
    #jwt -> {1st ->payload=> content which we want to store in jwt like here we are storing id of the user},
    #       {2nd ->  pasward key which should be stored in .env file }
    token = jwt.encode({'id': user_db.id}, os.getenv('JWT_SECRET_KEY'))    # here we get paskey through .env


    #if matched => return token(jwt) and user db(user details)
    return {'token': token, 'user': user_db}



#route to get user details using token which is commig from frontend(client side)
#and if request retched here so we have user id and token 
@router.get('/')
def current_user_data(db: Session=Depends(get_db),
                       user_dict=Depends(auth_middleware)):
    user = db.query(User).filter(User.id == user_dict['uid']).options(joinedload(User.favorites)).first()

    if not user:
        raise HTTPException(404, 'User not found!')
    
    return user