import 'package:client/features/home/models/song_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_local_repository.g.dart';

@riverpod
HomeLocalRepository homeLocalRepository(Ref ref) {
  return HomeLocalRepository();
}

class HomeLocalRepository {
  //this is a box in hive
  final Box box = Hive.box();

  //this is a function to upload song to local storage or hive
  void uploadLocalSong(SongModel song) {
    box.put(song.id, song.toJson()); //this will upload data to hive storage
  }

  //this helps to load songs from local storage or hive
  List<SongModel> loadSongs() {
    List<SongModel> songs = [];

    //loop to get all the song from hive storage
    for (final key in box.keys) {
      songs.add(SongModel.fromJson(box.get(key)));
    }
    return songs; //here we get all the data form hive
  }
}
