part of 'on_boarding_bloc.dart';

enum OnBoardingStatus {
  initial,
  pseudoDescValid,
  pseudoDescInvalid,
  imageValid,
  imageInvalid,
  errorRegister,
}

class OnBoardingState {
  final OnBoardingStatus status;
  final String? message;
  final Exception? error;
  final String? pseudo;
  final String? description;
  final Image? image;

  OnBoardingState({
    this.status = OnBoardingStatus.initial,
    this.message,
    this.error,
    this.pseudo,
    this.description,
    this.image,
  });

  OnBoardingState copyWith({
    OnBoardingStatus? status,
    Exception? error,
    String? message,
    String? pseudo,
    String? description,
    Image? image,
  }) {
    return OnBoardingState(
      status: status ?? this.status,
      error: error ?? this.error,
      message: message ?? this.message,
      pseudo: pseudo ?? this.pseudo,
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }
}
