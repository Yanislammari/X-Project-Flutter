part of 'login_bloc.dart';

enum LoginStatus {
  initial,
  successfulLoginNoOnBoarding,
  successfulLoginOnBoarding,
  errorLogin,
}

class LoginState {
  final LoginStatus status;
  final String? message;
  final Exception? error;

  LoginState({
    this.status = LoginStatus.initial,
    this.message,
    this.error,
  });

  LoginState copyWith({
    LoginStatus? status,
    Exception? error,
    String? message,
  }) {
    return LoginState(
      status: status ?? this.status,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }
}
