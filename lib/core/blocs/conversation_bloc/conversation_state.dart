import '../../models/conversation.dart';

abstract class ConversationState {}

class ConversationInitial extends ConversationState {}
class ConversationLoaded extends ConversationState {
  final List<Conversation> conversations;
  ConversationLoaded(this.conversations);
}
class ConversationError extends ConversationState {
  final String message;
  ConversationError(this.message);
} 