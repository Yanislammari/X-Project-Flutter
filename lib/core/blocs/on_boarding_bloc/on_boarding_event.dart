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

final class OnBoardingSendImage extends OnBoardingEvent {
  final Image? image;
  const OnBoardingSendImage({this.image});
}



