part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {
  const LoginEvent();
}

final class ConnexionWithGoogle extends LoginEvent {
  const ConnexionWithGoogle();
}

final class ConnexionWithEmailPassword extends LoginEvent {
  final String? email;
  final String? password;
  const ConnexionWithEmailPassword({this.email,this.password});
}
