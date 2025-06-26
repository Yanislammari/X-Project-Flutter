part of 'user_data_bloc.dart';

enum UserDataStatus {
  initial,
  loading,
  hasData,
  imageValid,
  imageInvalid,
  changeFirebaseImageFailed,
  error,
}

class UserDataState {
  final UserDataStatus status;
  final String? message;
  final FirebaseUser? user;
  final File? imageFile;

  UserDataState({
    this.status = UserDataStatus.initial,
    this.message,
    this.user,
    this.imageFile,
  });

  UserDataState copyWith({
    UserDataStatus? status,
    String? message,
    FirebaseUser? user,
    File? imageFile,
  }) {
    return UserDataState(
      status: status ?? this.status,
      message: message ?? this.message,
      user: user ?? this.user,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
