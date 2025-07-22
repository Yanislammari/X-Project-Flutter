import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/asking_relation.dart';
import '../../models/notification.dart';
import '../../repositories/relation/relation_repository.dart';
import '../../repositories/notification/notification_repository.dart';
import 'relation_event.dart';
import 'relation_state.dart';

class RelationBloc extends Bloc<RelationEvent, RelationState> {
  final RelationRepository relationRepository;
  final NotificationRepository _notificationRepository = NotificationRepository();
  
  RelationBloc({required this.relationRepository}) : super(RelationInitial()) {
    on<SendRelationRequest>(_onSendRelationRequest);
    on<CheckRelationRequest>(_onCheckRelationRequest);
    on<AcceptRelationRequest>(_onAcceptRelationRequest);
    on<RefuseRelationRequest>(_onRefuseRelationRequest);
    on<DeleteRelation>(_onDeleteRelation);
    on<CheckIfRelationExists>(_onCheckIfRelationExists);
    on<CheckFullRelationStatus>(_onCheckFullRelationStatus);
  }

  Future<void> _onSendRelationRequest(SendRelationRequest event, Emitter<RelationState> emit) async {
    emit(RelationLoading());
    try {
      await relationRepository.sendRelationRequest(event.relation);
      
      // Créer une notification
      final notif = AppNotification(
        id: '',
        type: NotificationType.AskingRelationReceived,
        likeId: null,
        askingRelationId: '',
        userId: event.relation.fromUserId,
        toUserId: event.relation.toUserId,
        timestamp: DateTime.now(),
      );
      await _notificationRepository.addNotification(notif);
      
      emit(RelationActionSuccess());
      
      // Rafraîchir le statut directement
      await _emitUpdatedStatus(event.relation.fromUserId, event.relation.toUserId, emit);
    } catch (e) {
      emit(RelationActionError(e.toString()));
    }
  }

  Future<void> _onCheckRelationRequest(CheckRelationRequest event, Emitter<RelationState> emit) async {
    emit(RelationLoading());
    try {
      final exists = await relationRepository.hasPendingRequest(event.fromUserId, event.toUserId);
      if (exists) {
        emit(RelationAlreadySent());
      } else {
        emit(RelationInitial());
      }
    } catch (e) {
      emit(RelationActionError(e.toString()));
    }
  }

  Future<void> _onAcceptRelationRequest(AcceptRelationRequest event, Emitter<RelationState> emit) async {
    emit(RelationLoading());
    try {
      await relationRepository.createRelation(event.fromUserId, event.toUserId);
      await relationRepository.deleteRelationRequest(event.fromUserId, event.toUserId);
      
      emit(RelationActionSuccess());
      
      // Rafraîchir le statut directement
      await _emitUpdatedStatus(event.toUserId, event.fromUserId, emit);
    } catch (e) {
      emit(RelationActionError(e.toString()));
    }
  }

  Future<void> _onRefuseRelationRequest(RefuseRelationRequest event, Emitter<RelationState> emit) async {
    emit(RelationLoading());
    try {
      await relationRepository.deleteRelationRequest(event.fromUserId, event.toUserId);
      
      emit(RelationActionSuccess());
      
      // Rafraîchir le statut directement
      await _emitUpdatedStatus(event.toUserId, event.fromUserId, emit);
    } catch (e) {
      emit(RelationActionError(e.toString()));
    }
  }

  Future<void> _onDeleteRelation(DeleteRelation event, Emitter<RelationState> emit) async {
    emit(RelationLoading());
    try {
      await relationRepository.deleteRelation(event.userA, event.userB);
      
      emit(RelationActionSuccess());
      
      // Rafraîchir le statut directement
      await _emitUpdatedStatus(event.userA, event.userB, emit);
    } catch (e) {
      emit(RelationActionError(e.toString()));
    }
  }

  Future<void> _onCheckIfRelationExists(CheckIfRelationExists event, Emitter<RelationState> emit) async {
    emit(RelationLoading());
    try {
      final exists = await relationRepository.relationExists(event.userA, event.userB);
      if (exists) {
        emit(RelationExists());
      } else {
        emit(RelationNotExists());
      }
    } catch (e) {
      emit(RelationActionError(e.toString()));
    }
  }

  Future<void> _onCheckFullRelationStatus(CheckFullRelationStatus event, Emitter<RelationState> emit) async {
    emit(RelationStatusState(
      isRelated: false, 
      hasSentRequest: false, 
      hasReceivedRequest: false, 
      loading: true
    ));
    
    await _emitUpdatedStatus(event.currentUserId, event.profileUserId, emit);
  }

  // Méthode centralisée pour émettre le statut mis à jour
  Future<void> _emitUpdatedStatus(String currentUserId, String profileUserId, Emitter<RelationState> emit) async {
    try {
      final futures = await Future.wait([
        relationRepository.relationExists(currentUserId, profileUserId),
        relationRepository.hasPendingRequest(currentUserId, profileUserId),
        relationRepository.hasPendingRequest(profileUserId, currentUserId),
      ]);
      
      emit(RelationStatusState(
        isRelated: futures[0],
        hasSentRequest: futures[1],
        hasReceivedRequest: futures[2],
        loading: false,
      ));
    } catch (e) {
      emit(RelationActionError('Erreur lors de la vérification du statut'));
    }
  }
} 