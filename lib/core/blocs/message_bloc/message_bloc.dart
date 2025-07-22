import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/message.dart';
import '../../repositories/message/message_repository.dart';
import 'message_event.dart';
import 'dart:async';

part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository messageRepository;
  StreamSubscription<List<Message>>? _subscription;

  MessageBloc({required this.messageRepository}) : super(MessageState()) {
    on<ListenMessages>(_onListenMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<_MessagesUpdated>((event, emit) {
      emit(state.copyWith(status: MessageStatus.loaded, messages: event.messages));
    });
  }

  void _onListenMessages(ListenMessages event, Emitter<MessageState> emit) {
    _subscription?.cancel();
    _subscription = messageRepository.messagesStream(event.conversationId).listen((messages) {
      add(_MessagesUpdated(messages));
    });
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<MessageState> emit) async {
    try {
      await messageRepository.sendMessage(event.message);
    } catch (e) {
      emit(state.copyWith(status: MessageStatus.error, message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

class _MessagesUpdated extends MessageEvent {
  final List<Message> messages;
  _MessagesUpdated(this.messages);
} 