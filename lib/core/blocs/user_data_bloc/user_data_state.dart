part of 'user_data_bloc.dart';

enum UserDataStatus {
  initial,
  loading,
  hasData,
  dataInvalid,
}

class UserDataState {
  final UserDataStatus status;
  final String? message;
  final FirebaseUser? user;

  UserDataState({
    this.status = UserDataStatus.initial,
    this.message,
    this.user,
  });

  UserDataState copyWith({
    UserDataStatus? status,
    String? message,
    FirebaseUser? user,
  }) {
    return UserDataState(
      status: status ?? this.status,
      message: message ?? this.message,
      user: user ?? this.user,
    );
  }
}
