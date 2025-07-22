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

  Future<void> _fetchUserData(UserDataFetch event, Emitter<UserDataState> emit) async {
    emit(state.copyWith(status: UserDataStatus.loading));
    try {
      final user = await userRepository.getUserData(state.user);
      if (user != null) {
        emit(state.copyWith(
          status: UserDataStatus.hasData,
          user: user,
        ));
      } else {
        emit(state.copyWith(
          status: UserDataStatus.error,
          message: "Aucune donnée utilisateur trouvée"
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: UserDataStatus.error,
        message: "Erreur lors du chargement des données utilisateur"
      ));
    }
  }

  Future<void> _choseImage(UserDataSendImage event, Emitter<UserDataState> emit) async {
    emit(state.copyWith(status: UserDataStatus.loading));

    try {
      final pickedFile = await _picker.pickImage(source: event.imageSource);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        emit(state.copyWith(status: UserDataStatus.imageValid, imageFile: imageFile));
      } else {
        emit(state.copyWith(
          status: UserDataStatus.imageInvalid, 
          message: "Aucune image sélectionnée"
        ));
      }
    } catch (e) {
      String errorMessage;
      if (e is PlatformException) {
        errorMessage = "Veuillez autoriser l'accès à votre caméra et/ou galerie dans les paramètres de votre appareil.";
      } else {
        errorMessage = "Une erreur s'est produite, veuillez réessayer";
      }
      emit(state.copyWith(status: UserDataStatus.imageInvalid, message: errorMessage));
    }
  }

  Future<void> _updateImage(UserDataUpdateImage event, Emitter<UserDataState> emit) async {
    emit(state.copyWith(status: UserDataStatus.loading));

    try {
      if (state.imageFile == null) {
        emit(state.copyWith(
          status: UserDataStatus.imageInvalid, 
          message: "Aucune image sélectionnée"
        ));
        return;
      }

      final updatedUser = await userRepository.updateUserImage(state.user, state.imageFile!);
      emit(state.copyWith(
        status: UserDataStatus.updateImageSuccess, 
        user: updatedUser
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserDataStatus.error, 
        message: "Erreur lors de la mise à jour de l'image"
      ));
    }
  }

  Future<void> _updateProfile(UserDataUpdateProfile event, Emitter<UserDataState> emit) async {
    emit(state.copyWith(status: UserDataStatus.loading));
    
    // Validation des champs
    if (_isFieldEmpty(event.bio) || _isFieldEmpty(event.pseudo)) {
      emit(state.copyWith(
        status: UserDataStatus.descBioInvalid, 
        message: "Tous les champs doivent être remplis"
      ));
      return;
    }
    
    // Vérification si les données ont changé
    if (_hasNoChanges(event.bio, event.pseudo)) {
      emit(state.copyWith(
        status: UserDataStatus.descBioInvalid,
        message: "Aucun changement détecté"
      ));
      return;
    }
    
    try {
      if (state.user == null) {
        emit(state.copyWith(
          status: UserDataStatus.error, 
          message: "Données utilisateur non disponibles"
        ));
        return;
      }

      final updatedUser = await userRepository.updateUserBio(
        event.pseudo, 
        event.bio, 
        state.user
      );
      
      emit(state.copyWith(
        status: UserDataStatus.updateBioSuccess, 
        user: updatedUser
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserDataStatus.error, 
        message: "Erreur lors de la mise à jour du profil"
      ));
    }
  }

  // Méthodes utilitaires privées
  bool _isFieldEmpty(String? field) {
    return field.isEmptyOrNull();
  }

  bool _hasNoChanges(String? newBio, String? newPseudo) {
    return newBio == state.user?.bio && newPseudo == state.user?.pseudo;
  }
}
