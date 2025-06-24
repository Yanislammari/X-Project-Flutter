part of 'register_bloc.dart';

enum RegisterStatus {
  initial,
  emailValid,
  emailInvalid,
  passwordValid,
  passwordInvalid,
  errorRegister,
}

class RegisterState {
  final RegisterStatus status;
  final String? message;
  final Exception? error;
  final String? email;
  final String? password;
  final String? confirmPassword;

  RegisterState({
    this.status = RegisterStatus.initial,
    this.message,
    this.error,
    this.email,
    this.password,
    this.confirmPassword,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    Exception? error,
    String? message,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return RegisterState(
      status: status ?? this.status,
      error: error ?? this.error,
      message: message ?? this.message,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}
