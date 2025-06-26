import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_project_flutter/core/models/user.dart';
import 'package:x_project_flutter/core/repositories/user_data/user_repository.dart';

part 'user_data_event.dart';
part 'user_data_state.dart';

class UserDataBloc extends Bloc<UserDataEvent, UserDataState> {

  final UserRepository userRepository;

  UserDataBloc({required this.userRepository}) : super(UserDataState()) {
    on<UserDataFetch>(_fetchUserData);
  }


  void _fetchUserData(UserDataFetch event, Emitter<UserDataState> emit)async {
    emit(state.copyWith(status: UserDataStatus.loading));
    try{
      final user = await userRepository.getUserData();
      if (user != null) {
        emit(state.copyWith(
          status: UserDataStatus.hasData,
          user: user,
        ));
      } else {
        emit(state.copyWith(status: UserDataStatus.dataInvalid));
      }
    }
    catch(e){
      emit(state.copyWith(status: UserDataStatus.dataInvalid));
    }
  }
}
