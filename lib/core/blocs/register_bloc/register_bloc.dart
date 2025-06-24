import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/extension/string_extensions.dart';
import 'package:x_project_flutter/core/repositories/register/register_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {

  final RegisterRepository registerRepository;

  RegisterBloc({required this.registerRepository}) : super(RegisterState()) {
    on<SendEmailToBloc>(_sendEmailToBloc);
    on<RegisterTry>(_registerTry);
  }

  void _sendEmailToBloc(SendEmailToBloc event,Emitter<RegisterState> emit){
    emit(state.copyWith(status: RegisterStatus.initial));
    if(event.email.isEmptyOrNull()){
      emit(state.copyWith(status : RegisterStatus.emailInvalid,message: "Email is required"));
    }
    else if(!event.email!.isEmail()){
      emit(state.copyWith(status : RegisterStatus.emailInvalid, email: event.email,message: "Email is of wrong format"));
    }
    else{
      emit(state.copyWith(status : RegisterStatus.emailValid, email: event.email));
    }
  }

  Future<void> _registerTry(RegisterTry event,Emitter<RegisterState> emit)async{
    emit(state.copyWith(status: RegisterStatus.initial));
    if(event.password.isEmptyOrNull() || event.confirmPassword.isEmptyOrNull()){
      emit(state.copyWith(status : RegisterStatus.passwordInvalid, message: "Both field are required"));
    }
    else if(event.password != event.confirmPassword){
      emit(state.copyWith(status : RegisterStatus.passwordInvalid, password: event.password,confirmPassword : event.confirmPassword,message: "Password doesnt match"));
    }
    else{
      try{
        final credential = await registerRepository.signUp(state.email!, event.password!);
        if(credential != null){
          emit(state.copyWith(status : RegisterStatus.passwordValid));
        }
        else{
          emit(state.copyWith(status : RegisterStatus.passwordInvalid, password: event.password,confirmPassword : event.confirmPassword,message: "An error occured, please try again"));
        }
      }
      catch(e){
        String errorMessage;

        if (e is Exception) {
          errorMessage = e.toString().deleteException();
        } else {
          errorMessage = "An error occured, please try again";
        }

        emit(state.copyWith(status : RegisterStatus.passwordInvalid, password: event.password,confirmPassword : event.confirmPassword,message: errorMessage));
      }
    }
  }
}
