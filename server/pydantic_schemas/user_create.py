from pydantic import BaseModel


#structure of data which user write on signin page to sign up
class UserCreate(BaseModel):
    name: str
    email: str
    password: str