import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_project_flutter/core/extension/string_extensions.dart';
import 'package:x_project_flutter/core/models/user.dart';
import 'package:x_project_flutter/core/repositories/user_data/user_repository.dart';

part 'user_data_event.dart';
part 'user_data_state.dart';

class UserDataBloc extends Bloc<UserDataEvent, UserDataState> {

  final UserRepository userRepository;
  final ImagePicker _picker = ImagePicker();

  UserDataBloc({required this.userRepository}) : super(UserDataState()) {
    on<UserDataFetch>(_fetchUserData);
    on<UserDataSendImage>(_choseImage);
    on<UserDataUpdateImage>(_updateImage);
    on<UserDataUpdateProfile>(_updateProfile);
  }


  void _fetchUserData(UserDataFetch event, Emitter<UserDataState> emit)async {
    emit(state.copyWith(status: UserDataStatus.loading));
    try{
      final user = await userRepository.getUserData(state.user);
      if (user != null) {
        emit(state.copyWith(
          status: UserDataStatus.hasData,
          user: user,
        ));
      } else {
        emit(state.copyWith(status: UserDataStatus.error));
      }
    }
    catch(e){
      emit(state.copyWith(status: UserDataStatus.error));
    }
  }

  Future<void> _choseImage(UserDataSendImage event, Emitter<UserDataState> emit) async {
    emit(state.copyWith(status: UserDataStatus.loading));

    try {
      final pickedFile = await _picker.pickImage(source: event.imageSource);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        emit(state.copyWith(status : UserDataStatus.imageValid,imageFile: imageFile));
      } else {
        emit(state.copyWith(status: UserDataStatus.imageInvalid, message: "No image selected"));
      }
    } catch(e){
      String errorMessage;

      if (e is PlatformException) {
        errorMessage = "Please allow access to your camera and/or gallery in your device settings.";
      } else {
        errorMessage = "An error occured, please try again";
      }

      emit(state.copyWith(status : UserDataStatus.imageInvalid, message: errorMessage));
    }
  }

  Future<void> _updateImage(UserDataUpdateImage event, Emitter<UserDataState> emit) async {
    emit(state.copyWith(status: UserDataStatus.loading));

    try {
      if (state.imageFile != null) {
        final updatedUser = await userRepository.updateUserImage(state.user, state.imageFile!);
        emit(state.copyWith(status: UserDataStatus.updateImageSuccess, user: updatedUser));
      } else {
        emit(state.copyWith(status: UserDataStatus.imageInvalid, message: "No image selected"));
      }
    } catch (e) {
      emit(state.copyWith(status: UserDataStatus.error, message: "An error occurred while updating the image."));
    }
  }

  Future<void> _updateProfile(UserDataUpdateProfile event, Emitter<UserDataState> emit) async {
    emit(state.copyWith(status: UserDataStatus.loading));
    if(event.bio.isEmptyOrNull() || event.pseudo.isEmptyOrNull()) {
      emit(state.copyWith(status: UserDataStatus.descBioInvalid, message: "Both fields cannot be empty"));
      return;
    }
    else if(event.bio == state.user?.bio && event.pseudo == state.user?.pseudo) {
      emit(state.copyWith(status: UserDataStatus.descBioInvalid));
      return;
    }
    try {
      if (state.user != null) {
        final updatedUser = await userRepository.updateUserBio(event.pseudo, event.bio, state.user);
        emit(state.copyWith(status: UserDataStatus.updateBioSuccess, user: updatedUser));
      } else {
        emit(state.copyWith(status: UserDataStatus.error, message: "User data is not available"));
      }
    } catch (e) {
      emit(state.copyWith(status: UserDataStatus.error, message: "An error occurred while updating the profile."));
    }
  }
}
