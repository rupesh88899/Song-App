

from fastapi import HTTPException, Header
import jwt

#this helps to get key frfom env file
import os
from dotenv import load_dotenv
load_dotenv()


def auth_middleware(x_auth_token = Header()):
    try:
        #get user token from headers and check it should not be empty
        if not x_auth_token:
            raise HTTPException(401, 'No auth token, access denied!')  

        # decode that token and check its valid or not also check not empty
        verified_token =  jwt.decode(x_auth_token, os.getenv('JWT_SECRET_KEY'), ['HS256'])

        if not verified_token:
            raise HTTPException(401, 'Token varification failed , authorization denied!')
        
        # get user id from token ans that id is payload
        uid = verified_token.get('id')
        return  {'uid':uid, 'token':x_auth_token}   

        #using that id contact to postegresql server and get user info and return to client side

    except jwt.PyJWTError:
        raise HTTPException(401, 'Token is not valid , authorization denied!')
