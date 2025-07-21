abstract class ConversationEvent {}

class ListenConversations extends ConversationEvent {
  final String userId;
  ListenConversations(this.userId);
} 