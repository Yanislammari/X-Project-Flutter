import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/conversation.dart';
import '../../repositories/message/conversation_repository.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';
import 'dart:async';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository conversationRepository;
  StreamSubscription<List<Conversation>>? _subscription;

  ConversationBloc({required this.conversationRepository}) : super(ConversationInitial()) {
    on<ListenConversations>(_onListenConversations);
    on<_ConversationsUpdated>((event, emit) {
      emit(ConversationLoaded(event.conversations));
    });
  }

  void _onListenConversations(ListenConversations event, Emitter<ConversationState> emit) {
    _subscription?.cancel();
    _subscription = conversationRepository.conversationsStream(event.userId).listen((conversations) {
      add(_ConversationsUpdated(conversations));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _ConversationsUpdated extends ConversationEvent {
  final List<Conversation> conversations;
  _ConversationsUpdated(this.conversations);
} 