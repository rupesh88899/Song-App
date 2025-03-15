from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker


#this will connect databse(postgreSQl) to server(FastAPI)
DATABASE_URl = 'postgresql://postgres:#rkt12345@localhost:5432/musicapp'
engine = create_engine(DATABASE_URl)

#this will make session
SessionLocal = sessionmaker(autocommit = False, autoflush=False, bind=engine)


#dependency injuction for db
def get_db():
    #get access to database
    db = SessionLocal()    # ✅ Create a session
    try:
        yield db           # ✅ Provide session to route
    finally:
        db.close()         # ✅ Automatically close after request
