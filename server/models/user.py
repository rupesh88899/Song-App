from sqlalchemy import TEXT, VARCHAR, Column, LargeBinary 
from sqlalchemy.orm import relationship
from models.base import Base



#this class or table (model) will created if model is not created in databse
class User(Base):
    __tablename__ = 'user'     #this is table

#this are the columns of the table user
    id = Column(TEXT, primary_key=True)
    name = Column(VARCHAR(100))
    email = Column(VARCHAR(100))
    password = Column(LargeBinary)  # make pas hash data

    favorites = relationship('Favorite', back_populates="user")  #two way relationship