//this file dealse logic related to local storage of mobile  not to server

//contain two functions get_token and set_token

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

//this help to create buildrunner file
part 'auth_local_repository.g.dart';

//provider
@Riverpod(keepAlive: true)
AuthLocalRepository authLocalRepository(Ref ref) {
  return AuthLocalRepository();
}

class AuthLocalRepository {
  late SharedPreferences _sharedPreferences;

//initlise this before call get and set token otherwise it give Exceptionerror
  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  } //after this we can create set and get token

//setToken
  void setToken(String? token) {
    if (token != null) {
      _sharedPreferences.setString('x-auth-token', token);
    }
  }

//getToken
  String? getToken() {
    return _sharedPreferences.getString('x-auth-token');
  }
}
