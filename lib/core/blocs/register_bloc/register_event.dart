part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {
  const RegisterEvent();
}

final class SendEmailToBloc extends RegisterEvent {
  final String? email;
  const SendEmailToBloc({this.email});
}

final class RegisterTry extends RegisterEvent {
  final String? password;
  final String? confirmPassword;
  const RegisterTry({this.password,this.confirmPassword});
}
