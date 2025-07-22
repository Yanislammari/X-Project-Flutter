part of 'conversation_bloc.dart';

enum ConversationStatus {
  initial,
  loaded,
  error,
}

class ConversationState {
  final ConversationStatus status;
  final String? message;
  final List<Conversation>? conversations;
  final Exception? error;

  ConversationState({
    this.status = ConversationStatus.initial,
    this.message,
    this.conversations,
    this.error,
  });

  ConversationState copyWith({
    ConversationStatus? status,
    String? message,
    List<Conversation>? conversations,
    Exception? error,
  }) {
    return ConversationState(
      status: status ?? this.status,
      message: message ?? this.message,
      conversations: conversations ?? this.conversations,
      error: error ?? this.error,
    );
  }
} 