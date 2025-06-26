part of 'user_data_bloc.dart';

@immutable
sealed class UserDataEvent {
  const UserDataEvent();
}

class UserDataFetch extends UserDataEvent {
  const UserDataFetch();
}

class UserDataUpdateProfile extends UserDataEvent {
  final String? bio;
  final String? pseudo;
  const UserDataUpdateProfile({
    this.bio,
    this.pseudo,
  });
}

class UserDataSendImage extends UserDataEvent {
  final ImageSource imageSource;
  const UserDataSendImage({required this.imageSource});
}

class UserDataUpdateImage extends UserDataEvent {
  const UserDataUpdateImage();
}

class UserDataSendDescriptionAndPseudo extends UserDataEvent {
  final String? description;
  final String? pseudo;
  const UserDataSendDescriptionAndPseudo({this.description, this.pseudo});
}
