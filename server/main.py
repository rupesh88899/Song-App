from fastapi import FastAPI
from models.base import Base
from database import engine
from routes import auth, song




#this is our main thing using whcih we are usig FastAPI
app = FastAPI()


#here we are calling or initlising router so we can use it at every place we want 
app.include_router(auth.router, prefix='/auth')  #prefix='/auth' will add /auth to every single route we have

#here we are calling or initlising song router
app.include_router(song.router, prefix='/song')

#using rhis SQLalchemy make tables based on the info present in class
Base.metadata.create_all(engine)
























































#from fastapi import FastAPI, HTTPException
#from pydantic import BaseModel
#from sqlalchemy import TEXT, VARCHAR, LargeBinary, create_engine, Column
#from sqlalchemy.orm import sessionmaker
#from sqlalchemy.ext.declarative import declarative_base
#import uuid
#import bcrypt

#app = FastAPI()

#this will connect databse(postgreSQl) to server(FastAPI)
#DATABASE_URl = 'postgresql://postgres:#rkt12345@localhost:5432/musicapp'
#engine = create_engine(DATABASE_URl)

#this will make session
#SessionLocal = sessionmaker(autocommit = False, autoflush=False, bind=engine)

#get access to database
#db = SessionLocal()

#structure of data which is recieve or send
#class UserCreate(BaseModel):
#    name: str
#    email: str
#    password: str

#creating a type of db schema or model
#Base = declarative_base()    

#this class or table (model) will created if model is not created in databse
#class User(Base):
 #   __tablename__ = 'user'     #this is table

#this are the columns of the table user
#    id = Column(TEXT, primary_key=True)
#    name = Column(VARCHAR(100))
#    email = Column(VARCHAR(100))
#    password = Column(LargeBinary)  # make pas hash data

#signup api route
#@app.post('/signup')
#def signup_user(user: UserCreate):

    #1 extract the data thats coming from request
 


    #2 setup db before doing this and connect framework with postGreSQl server using SQLAlchemy
    # we need database for this db(postGreSQL) setup db before doing this
    #check if user is already exist in db and give error if exist 
#    user_db = db.query(User).filter(User.email == user.email).first()

  #  if user_db:
  #      raise HTTPException(400, 'User with the same email already exist!')

    # 3 we need database for this db(postGreSQL)
    # add user to db if new user
 #   hashed_pw = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())
 #   user_db = User(id=str(uuid.uuid4()),email=user.email, password=hashed_pw,name=user.name)
 #   db.add(user_db)  
 #   db.commit()  #since we make autocomit = false we have to commit manually
  #  db.refrest(user_db) #refreshed attributes at instance to reflect changes

 #   return user_db


#using rhis SQLalchemy make tables based on the info present in class
#Base.metadata.create_all(engine)

#pass














#------- this is basics for getting body and using query in fast api

#from fastapi import FastAPI
#from pydantic import BaseModel

#app = FastAPI()

#class Test(BaseModel):
#    name: str
#    age: int

#@app.post('/')
#def test(t:Test, q: str):    # (t:Test) => body , (q: str) => query
#    print(t)
#    return 'hello'