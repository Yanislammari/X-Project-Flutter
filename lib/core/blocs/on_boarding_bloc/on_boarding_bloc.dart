import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_project_flutter/core/extension/string_extensions.dart';
import 'package:x_project_flutter/core/models/user.dart';

import '../../repositories/onboarding/onboarding_repository.dart';

part 'on_boarding_event.dart';
part 'on_boarding_state.dart';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {

  final OnBoardingRepository onBoardingRepository;
  final ImagePicker _picker = ImagePicker();

  OnBoardingBloc({required this.onBoardingRepository}) : super(OnBoardingState()) {
    on<OnBoardingSendDescriptionAndPseudo>(_onBoardingSendDescriptionAndPseudo);
    on<OnBoardingChoseImage>(_choseImage);
    on<OnBoardingRegisterUser>(_onBoardingRegisterUser);
  }

  void _onBoardingSendDescriptionAndPseudo(OnBoardingSendDescriptionAndPseudo event, Emitter<OnBoardingState> emit) {
    emit(state.copyWith(status: OnBoardingStatus.initial));

    if (event.pseudo.isEmptyOrNull()) {
      emit(state.copyWith(status: OnBoardingStatus.pseudoDescInvalid, message: "Pseudo is required"));
    } else if (event.description.isEmptyOrNull()) {
      emit(state.copyWith(status: OnBoardingStatus.pseudoDescInvalid, message: "Description is required"));
    } else {
      emit(state.copyWith(status: OnBoardingStatus.pseudoDescValid, pseudo: event.pseudo, description: event.description));
    }
  }

  Future<void> _choseImage(OnBoardingChoseImage event, Emitter<OnBoardingState> emit) async {
    emit(state.copyWith(status: OnBoardingStatus.initial));

    try {
      final pickedFile = await _picker.pickImage(source: event.imageSource);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        emit(state.copyWith(status: OnBoardingStatus.imageValid, imageFile: imageFile));
      } else {
        emit(state.copyWith(status: OnBoardingStatus.imageInvalid, message: "No image selected"));
      }
    } catch(e){
      String errorMessage;

      if (e is PlatformException) {
        errorMessage = "Please allow access to your camera and/or gallery in your device settings.";
      } else {
        errorMessage = "An error occured, please try again";
      }

      emit(state.copyWith(status : OnBoardingStatus.imageInvalid, message: errorMessage));
    }
  }

  Future<void> _onBoardingRegisterUser(OnBoardingRegisterUser event, Emitter<OnBoardingState> emit) async {
    emit(state.copyWith(status: OnBoardingStatus.loading));

    try {
      UserFromBloc user = UserFromBloc(
        pseudo: state.pseudo!,
        bio: state.description!,
        imageFile: state.imageFile!,
      );
      await onBoardingRepository.registerUser(user);
      emit(state.copyWith(status: OnBoardingStatus.registerSuccess));
    } catch (e) {
      String errorMessage;

      if (e is Exception) {
        errorMessage = e.toString().deleteException();
      } else {
        errorMessage = "An error occured, please try again";
      }
      emit(state.copyWith(status: OnBoardingStatus.errorRegister, message: errorMessage));
    }
  }
}
