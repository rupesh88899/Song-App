import uuid
import env


#to setup env file --TODO - env not woked here showing api key error
#from dotenv import load_dotenv
#import os
#load_dotenv()


#this belong to cloudineary
import cloudinary
import cloudinary.uploader

from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.orm import Session, joinedload
from database import get_db
from middleware.auth_middleware import auth_middleware

from models.favorite import Favorite
from models.song import Song
from pydantic_schemas.favorite_song import FavoriteSong

#this is my music file router   
router = APIRouter()


# Configuration of cloudineary for thumbnail and music file storage -- this is not working i don't know why 
#cloudinary.config( 
    #all credentials are stored in .env file
#    cloud_name=os.getenv('CLOUD_NAME'), 
#    api_key=os.getenv('API_KEY'), 
#    api_secret=os.getenv('API_SECRET'), 
#    secure=True
#)


# Configuration of cloudineary for thumbnail and music file storage
# cloudinary.config( 
#     cloud_name=env.cloud_name, 
#     api_key=env.api_key, 
#     api_secret=env.api_secret,
#     secure=True
# )


cloudinary.config( 
    cloud_name = "dhu2di00o", 
    api_key = "518818559768898", 
    api_secret = "TtSImjBypfpKl289RaSVfyJYC8o",
    secure=True
)



@router.post("/upload", status_code=201)
def upload_song(song: UploadFile = File(...),
                thumbnail: UploadFile = File(...),
                artist: str = Form(...), 
                song_name: str = Form(...), 
                hex_code: str = Form(...),
                db: Session = Depends(get_db), 
                auth_dict = Depends(auth_middleware)):     #this line to see the user is authenticated or not 
    

    # Strip the '#' symbol from the hex_code
    hex_code = hex_code.lstrip('#')

    #since all the songs are in song folder so we create an unique ides for all songs
    song_id = str(uuid.uuid4())

    #upload song and thumbnails in cloudinary
    song_res =  cloudinary.uploader.upload(song.file, resource_type='auto', folder=f'songs/{song_id}')   # now our song store in song folder with unique ides of therer own
    thumbnail_res =  cloudinary.uploader.upload(thumbnail.file, resource_type='image', folder=f'songs/{song_id}')   # now our song store in song folder with unique ides of therer own
 

    new_song = Song(
        id=song_id,
        song_name=song_name,
        artist=artist,
        hex_code=hex_code,
        song_url=song_res['url'],
        thumbnail_url=thumbnail_res['url']
    )


    db.add(new_song)
    db.commit()
    db.refresh(new_song)
    
    return new_song 



#get all songs to home screen 
@router.get('/list')
def list_songs(db: Session=Depends(get_db), 
               auth_details=Depends(auth_middleware)):
    songs = db.query(Song).all()
    return songs


#this will add or remove song from favorites 
@router.post('/favorite')
def favorite_song(song: FavoriteSong,
                  db: Session=Depends(get_db),
                  auth_details=Depends(auth_middleware)):
    
    #song is already favoreated by user
    user_id = auth_details['uid']

    fav_song = db.query(Favorite).filter(Favorite.song_id == song.song_id, Favorite.user_id == user_id).first()
    
    #if favorite remove from favorites
    if fav_song:
        db.delete(fav_song)
        db.commit()
        return {'message': False}
    else:    #not favorited then favoreated the song
        new_fav = Favorite(id=str(uuid.uuid4()), song_id=song.song_id, user_id=user_id)
        db.add(new_fav)
        db.commit()
        return {'message': True}




#get all favorite songs to favorites screen 
@router.get('/list/favorites')
def list_fev_songs(db: Session=Depends(get_db), 
               auth_details=Depends(auth_middleware)):
    user_id = auth_details['uid']
    fav_songs =db.query(Favorite).filter(Favorite.user_id == user_id).options(joinedload(Favorite.song)).all()

    return fav_songs