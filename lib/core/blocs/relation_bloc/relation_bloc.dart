import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/asking_relation.dart';
import '../../models/notification.dart';
import '../../repositories/relation/relation_repository.dart';
import '../../repositories/notification/notification_repository.dart';
import 'relation_event.dart';
import 'relation_state.dart';

class RelationBloc extends Bloc<RelationEvent, RelationState> {
  final RelationRepository relationRepository;
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
      final notif = AppNotification(
        id: '',
        type: NotificationType.AskingRelationReceived,
        likeId: null,
        askingRelationId: '',
        userId: event.relation.fromUserId,
        toUserId: event.relation.toUserId,
        timestamp: DateTime.now(),
      );
      await NotificationRepository().addNotification(notif);
      emit(RelationSuccess());
      _refreshStatusAfterAction(event.relation.fromUserId, event.relation.toUserId, emit);
    } catch (e) {
      emit(RelationError(e.toString()));
    }
  }

  Future<void> _onCheckRelationRequest(CheckRelationRequest event, Emitter<RelationState> emit) async {
    emit(RelationLoading());
    final exists = await relationRepository.hasPendingRequest(event.fromUserId, event.toUserId);
    if (exists) {
      emit(RelationAlreadySent());
    } else {
      emit(RelationInitial());
    }
  }

  Future<void> _onAcceptRelationRequest(AcceptRelationRequest event, Emitter<RelationState> emit) async {
    emit(RelationLoading());
    try {
      await relationRepository.createRelation(event.fromUserId, event.toUserId);
      await relationRepository.deleteRelationRequest(event.fromUserId, event.toUserId);
      emit(RelationActionSuccess());
      _refreshStatusAfterAction(event.toUserId, event.fromUserId, emit);
    } catch (e) {
      emit(RelationActionError(e.toString()));
    }
  }

  Future<void> _onRefuseRelationRequest(RefuseRelationRequest event, Emitter<RelationState> emit) async {
    emit(RelationLoading());
    try {
      await relationRepository.deleteRelationRequest(event.fromUserId, event.toUserId);
      emit(RelationActionSuccess());
      _refreshStatusAfterAction(event.toUserId, event.fromUserId, emit);
    } catch (e) {
      emit(RelationActionError(e.toString()));
    }
  }

  Future<void> _onDeleteRelation(DeleteRelation event, Emitter<RelationState> emit) async {
    emit(RelationLoading());
    try {
      await relationRepository.deleteRelation(event.userA, event.userB);
      emit(RelationActionSuccess());
      _refreshStatusAfterAction(event.userA, event.userB, emit);
    } catch (e) {
      emit(RelationActionError(e.toString()));
    }
  }

  Future<void> _onCheckIfRelationExists(CheckIfRelationExists event, Emitter<RelationState> emit) async {
    emit(RelationLoading());
    final exists = await relationRepository.relationExists(event.userA, event.userB);
    if (exists) {
      emit(RelationExists());
    } else {
      emit(RelationNotExists());
    }
  }

  Future<void> _onCheckFullRelationStatus(CheckFullRelationStatus event, Emitter<RelationState> emit) async {
    emit(RelationStatusState(isRelated: false, hasSentRequest: false, hasReceivedRequest: false, loading: true));
    final isRelated = await relationRepository.relationExists(event.currentUserId, event.profileUserId);
    final hasSentRequest = await relationRepository.hasPendingRequest(event.currentUserId, event.profileUserId);
    final hasReceivedRequest = await relationRepository.hasPendingRequest(event.profileUserId, event.currentUserId);
    emit(RelationStatusState(
      isRelated: isRelated,
      hasSentRequest: hasSentRequest,
      hasReceivedRequest: hasReceivedRequest,
      loading: false,
    ));
  }

  // Après chaque action qui modifie l'état, relancer le check complet
  Future<void> _refreshStatusAfterAction(String currentUserId, String profileUserId, Emitter<RelationState> emit) async {
    add(CheckFullRelationStatus(currentUserId: currentUserId, profileUserId: profileUserId));
  }

  @override
  void onTransition(Transition<RelationEvent, RelationState> transition) {
    super.onTransition(transition);
  }
} 