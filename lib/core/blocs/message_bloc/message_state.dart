part of 'message_bloc.dart';

enum MessageStatus {
  initial,
  loaded,
  error,
}

class MessageState {
  final MessageStatus status;
  final String? message;
  final List<Message>? messages;
  final Exception? error;

  MessageState({
    this.status = MessageStatus.initial,
    this.message,
    this.messages,
    this.error,
  });

  MessageState copyWith({
    MessageStatus? status,
    String? message,
    List<Message>? messages,
    Exception? error,
  }) {
    return MessageState(
      status: status ?? this.status,
      message: message ?? this.message,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
} 