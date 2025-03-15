from pydantic import BaseModel


#structure of data which user write on login page to login
class UserLogin(BaseModel):
    email: str
    password: str