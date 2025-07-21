import '../../models/message.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}
class MessageLoaded extends MessageState {
  final List<Message> messages;
  MessageLoaded(this.messages);
}
class MessageError extends MessageState {
  final String message;
  MessageError(this.message);
} 