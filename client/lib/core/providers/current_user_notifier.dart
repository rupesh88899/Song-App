import 'package:client/core/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_notifier.g.dart';

@Riverpod(keepAlive: true)
class CurrentUserNotifier extends _$CurrentUserNotifier {
  @override
  UserModel? build() {
    return null; //here we are not sure that user id logged in or not
  }

  void addUser(UserModel user) {
    // this is going to update our state
    state = user;
  }
}
