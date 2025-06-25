part of 'on_boarding_bloc.dart';

@immutable
sealed class OnBoardingEvent {
  const OnBoardingEvent();
}

final class OnBoardingSendDescriptionAndPseudo extends OnBoardingEvent {
  final String? description;
  final String? pseudo;
  const OnBoardingSendDescriptionAndPseudo({this.description, this.pseudo});
}

final class OnBoardingChoseImage extends OnBoardingEvent {
  final ImageSource imageSource;
  const OnBoardingChoseImage({required this.imageSource});
}

final class OnBoardingRegisterUser extends OnBoardingEvent {
  const OnBoardingRegisterUser();
}



