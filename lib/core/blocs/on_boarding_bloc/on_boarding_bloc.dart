import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/extension/string_extensions.dart';

part 'on_boarding_event.dart';
part 'on_boarding_state.dart';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  OnBoardingBloc() : super(OnBoardingState()) {
    on<OnBoardingSendDescriptionAndPseudo>(_onBoardingSendDescriptionAndPseudo);
    on<OnBoardingSendImage>(_onBoardingSendImage);
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

  void _onBoardingSendImage(OnBoardingSendImage event, Emitter<OnBoardingState> emit) {
    emit(state.copyWith(status: OnBoardingStatus.initial));
    if (event.image == null) {
      emit(state.copyWith(status: OnBoardingStatus.imageInvalid, message: "Image is required"));
    } else {
      emit(state.copyWith(status: OnBoardingStatus.imageValid, image: event.image));
    }
  }
}
