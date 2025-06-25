part of 'on_boarding_bloc.dart';

enum OnBoardingStatus {
  initial,
  loading,
  pseudoDescValid,
  pseudoDescInvalid,
  imageValid,
  imageInvalid,
  registerSuccess,
  errorRegister,
}

class OnBoardingState {
  final OnBoardingStatus status;
  final String? message;
  final Exception? error;
  final String? pseudo;
  final String? description;
  final File? imageFile;

  OnBoardingState({
    this.status = OnBoardingStatus.initial,
    this.message,
    this.error,
    this.pseudo,
    this.description,
    this.imageFile,
  });

  OnBoardingState copyWith({
    OnBoardingStatus? status,
    Exception? error,
    String? message,
    String? pseudo,
    String? description,
    File? imageFile,
  }) {
    return OnBoardingState(
      status: status ?? this.status,
      error: error ?? this.error,
      message: message ?? this.message,
      pseudo: pseudo ?? this.pseudo,
      description: description ?? this.description,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
