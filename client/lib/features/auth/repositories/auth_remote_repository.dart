//this file deals logic related to server and does not deal logic related to local storage of mobile
//all call from this will contact with our server using http

import 'dart:convert';

import 'package:client/core/constants/server_constaant.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/core/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_repository.g.dart';

@riverpod
AuthRemoteRepository authRemoteRepository(Ref ref) {
  return AuthRemoteRepository();
}

class AuthRemoteRepository {
  Future<Either<AppFailure, UserModel>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      //here we send a post to server
      final response = await http.post(
        Uri.parse(
          '${ServerConstaant.serverURL}/auth/signup', // this is for android emulator if not then we can use 'http://127.0.0.1:8000/auth/signup'
        ),
        headers: {
          //this header says that what type of data we are sending using body like here we use json
          'Content-Type': 'application/json',
        },
        //sending this data to server
        body: jsonEncode(
          {
            'name': name,
            'email': email,
            'password': password,
          },
        ),
      );
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 201) {
        //handled the error
        return Left(AppFailure(resBodyMap['detail']));
      }

      return Right(UserModel.fromMap(resBodyMap));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      //here we send post to server
      final response = await http.post(
        Uri.parse(
          '${ServerConstaant.serverURL}/auth/login',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'email': email,
            'password': password,
          },
        ),
      );
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        return Left(AppFailure(resBodyMap['detail']));
      }

      return Right(
        //structure is {user: {"name": "name", "email": "email","id": "id "}, token: "token val"}  so first we extract user normaly and then we extract token  using copy with token
        UserModel.fromMap(resBodyMap['user']).copyWith(
          token: resBodyMap['token'],
        ),
      );
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> getCurrentUserData(String token) async {
    try {
      //here we send post to server
      final response = await http.get(
        Uri.parse(
          '${ServerConstaant.serverURL}/auth/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        return Left(AppFailure(resBodyMap['detail']));
      }

      return Right(
        //structure is {user: {"name": "name", "email": "email","id": "id "}, token: "token val"}  so first we extract user normaly and then we extract token  using copy with token
        UserModel.fromMap(resBodyMap).copyWith(
          token:token,
        ),
      );
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
