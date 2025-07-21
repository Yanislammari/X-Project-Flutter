import '../../models/asking_relation.dart';

abstract class RelationEvent {}

class SendRelationRequest extends RelationEvent {
  final AskingRelation relation;
  SendRelationRequest(this.relation);
}

class CheckRelationRequest extends RelationEvent {
  final String fromUserId;
  final String toUserId;
  CheckRelationRequest({required this.fromUserId, required this.toUserId});
}

class AcceptRelationRequest extends RelationEvent {
  final String fromUserId;
  final String toUserId;
  AcceptRelationRequest({required this.fromUserId, required this.toUserId});
}

class RefuseRelationRequest extends RelationEvent {
  final String fromUserId;
  final String toUserId;
  RefuseRelationRequest({required this.fromUserId, required this.toUserId});
}

class DeleteRelation extends RelationEvent {
  final String userA;
  final String userB;
  DeleteRelation({required this.userA, required this.userB});
}

class CheckIfRelationExists extends RelationEvent {
  final String userA;
  final String userB;
  CheckIfRelationExists({required this.userA, required this.userB});
}

class CheckFullRelationStatus extends RelationEvent {
  final String currentUserId;
  final String profileUserId;
  CheckFullRelationStatus({required this.currentUserId, required this.profileUserId});
} 