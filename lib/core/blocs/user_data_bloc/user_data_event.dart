part of 'user_data_bloc.dart';

@immutable
sealed class UserDataEvent {
  const UserDataEvent();
}

class UserDataFetch extends UserDataEvent {
  const UserDataFetch();
}

class UserDataUpdate extends UserDataEvent {
  const UserDataUpdate();
}

class UserDataSendImage extends UserDataEvent {
  final ImageSource imageSource;
  const UserDataSendImage({required this.imageSource});
}

class UserDataSendDescriptionAndPseudo extends UserDataEvent {
  final String? description;
  final String? pseudo;
  const UserDataSendDescriptionAndPseudo({this.description, this.pseudo});
}
