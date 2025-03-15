import 'dart:convert';
import 'dart:io';

import 'package:client/core/constants/server_constaant.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

//provider
@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepository();
}

class HomeRepository {
  Future<Either<AppFailure, String>> uploadSong({
    required File selectedAudio,
    required File selectedThumbnail,
    required String songName,
    required String artist,
    required String hexCode,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ServerConstaant.serverURL}/song/upload'),
      );

      request
        ..files.addAll(
          //since we have two files  which are not text so we have to use this metheod
          [
            await http.MultipartFile.fromPath('song', selectedAudio.path),
            await http.MultipartFile.fromPath(
                'thumbnail', selectedThumbnail.path),
          ],
        )
        ..fields.addAll(
          // this are three fields with text so this is the method
          {
            'artist': artist,
            'song_name': songName,
            'hex_code': hexCode,
          },
        )
        ..headers.addAll(
          // in header we add token of user to check user is authorised or not
          {
            'x-auth-token': token,
          },
        );
      final res = await request.send(); // this will send request

      if (res.statusCode != 201) {
        return Left(AppFailure(await res.stream.bytesToString()));
      }

      return Right(
        await res.stream.bytesToString(),
      );
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getAllSongs({
    required String token,
  }) async {
    try {
      final res = await http
          .get(Uri.parse('${ServerConstaant.serverURL}/song/list'), headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      });
      var resBodyMap = jsonDecode(res.body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }
      //if response is 200
      resBodyMap = resBodyMap as List;

      List<SongModel> song = [];

      //loop
      for (final map in resBodyMap) {
        song.add(SongModel.fromMap(map));
      }

      return Right(song);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  //this is for favorite songs
  Future<Either<AppFailure, bool>> favSong({
    required String token,
    required String songId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${ServerConstaant.serverURL}/song/favorite'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(
          {
            "song_id": songId,
          },
        ),
      );
      var resBodyMap = jsonDecode(res.body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }

      return Right(resBodyMap['message']);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

//this return all favorite songs
  Future<Either<AppFailure, List<SongModel>>> getFavSongs({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstaant.serverURL}/song/list/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      var resBodyMap = jsonDecode(res.body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }
      //if response is 200
      resBodyMap = resBodyMap as List;

      List<SongModel> song = [];

      //loop
      for (final map in resBodyMap) {
        song.add(SongModel.fromMap(map['song']));
      }

      return Right(song);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
