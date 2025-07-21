import '../../models/message.dart';

abstract class MessageEvent {}

class ListenMessages extends MessageEvent {
  final String conversationId;
  ListenMessages(this.conversationId);
}

class SendMessageEvent extends MessageEvent {
  final Message message;
  SendMessageEvent(this.message);
} 