import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/extension/string_extensions.dart';
import 'package:x_project_flutter/core/repositories/login/login_repository.dart';
import 'package:x_project_flutter/main_screen.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  final LoginRepository loginRepository;

  LoginBloc({required this.loginRepository}) : super(LoginState()) {
    on<ConnexionWithGoogle>(_buildConnexionHandler(loginRepository.googleAuth));
    on<ConnexionWithEmailPassword>((event, emit) async {
      final handler = _buildConnexionHandler(() {
        return loginRepository.emailAndPasswordAuth(event.email, event.password);
      });
      await handler(event, emit);
    });
  }

  EventHandler<LoginEvent, LoginState> _buildConnexionHandler(
      Future<UserCredential?> Function() signInMethod,
      ) {
    return (event, emit) async {
      emit(state.copyWith(status: LoginStatus.initial));
      try{
        final userCredential = await signInMethod();
        if (userCredential != null) {
          final exists = await loginRepository.checkUidUserExist(userCredential.user?.uid);

          if (exists) {
            emit(state.copyWith(status: LoginStatus.successfulLoginNoOnBoarding));
          } else {
            emit(state.copyWith(status: LoginStatus.successfulLoginOnBoarding));
          }
        }
        else {
          emit(state.copyWith(status: LoginStatus.errorLogin, message: "An error occured, please try again"));
        }
      }
      catch (e) {
        String errorMessage;

        if (e is Exception) {
          errorMessage = e.toString().deleteException();
        } else {
          errorMessage = "An error occured, please try again";
        }

        emit(state.copyWith(status: LoginStatus.errorLogin, message: errorMessage));
      }
    };
  }
}
