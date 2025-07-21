abstract class RelationState {}

class RelationInitial extends RelationState {}
class RelationLoading extends RelationState {}
class RelationSuccess extends RelationState {}
class RelationError extends RelationState {
  final String message;
  RelationError(this.message);
}
class RelationAlreadySent extends RelationState {}
class RelationExists extends RelationState {}
class RelationNotExists extends RelationState {}
class RelationActionSuccess extends RelationState {}
class RelationActionError extends RelationState {
  final String message;
  RelationActionError(this.message);
}
class RelationStatusState extends RelationState {
  final bool isRelated;
  final bool hasSentRequest;
  final bool hasReceivedRequest;
  final bool loading;
  RelationStatusState({
    required this.isRelated,
    required this.hasSentRequest,
    required this.hasReceivedRequest,
    this.loading = false,
  });
} 