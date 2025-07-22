import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/conversation.dart';
import '../../repositories/message/conversation_repository.dart';
import 'conversation_event.dart';
import 'dart:async';

part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository conversationRepository;
  StreamSubscription<List<Conversation>>? _subscription;

  ConversationBloc({required this.conversationRepository}) : super(ConversationState()) {
    on<ListenConversations>(_onListenConversations);
    on<_ConversationsUpdated>((event, emit) {
      emit(state.copyWith(status: ConversationStatus.loaded, conversations: event.conversations));
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