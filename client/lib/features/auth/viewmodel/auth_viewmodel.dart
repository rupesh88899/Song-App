//mainly statemanagement will be done here
//view model is mainly for what to show on screen or what not

// ignore_for_file: avoid_print

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/models/user_model.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/auth/repositories/auth_remote_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  //instance of auth_remote_repository
  late AuthRemoteRepository _authRemoteRepository;
  //instance of auth_local_repository
  late AuthLocalRepository _authLocalRepository;
  //instance of current_user_notifier
  late CurrentUserNotifier _currentUserNotifier;

  @override
  AsyncValue<UserModel>? build() {
    // async Value is because it has 3 states loading data and data states
    //initelising auth_remote_repository provider
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    //initelising auth_local_repository provider
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    //initelising current_user_notifier provider
    _currentUserNotifier = ref.watch(currentUserNotifierProvider.notifier);

    return null;
  }

//this function is to init shared preferences which is very imp without it we get error
  Future<void> initSharedPreferences() async {
    await _authLocalRepository.init();
  }

  //sign up function
  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final res = await _authRemoteRepository.signup(
      name: name,
      email: email,
      password: password,
    );
    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(
          l.message,
          StackTrace.current,
        ),
      Right(value: final r) => state = AsyncValue.data(r),
    };
    print(val);
  }

  //login function
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final res = await _authRemoteRepository.login(
      email: email,
      password: password,
    );
    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(
          l.message,
          StackTrace.current,
        ),
      Right(value: final r) => _loginSuccess(r),
    };
    print(val);
  }

  //login success function
  AsyncValue<UserModel>? _loginSuccess(UserModel user) {
    _authLocalRepository.setToken(user.token);
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }

  //this function gets user data based on token whcih we send from this function and in server seide we use this token to get user id using which server send user data
  Future<UserModel?> getData() async {
    state = const AsyncValue.loading(); //waiting to get token
    final token = _authLocalRepository.getToken(); //getting token
    if (token != null) {
      final res = await _authRemoteRepository.getCurrentUserData(token);
      final val = switch (res) {
        Left(value: final l) => state = AsyncValue.error(
            l.message,
            StackTrace.current,
          ),
        Right(value: final r) => _getDataSuccess(r),
      };
      return val.value;
    }
    return null; //if token is null it means user is loggin in first time
  }

  AsyncValue<UserModel> _getDataSuccess(UserModel user) {
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }
}
