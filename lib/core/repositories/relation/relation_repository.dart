import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/asking_relation.dart';

class RelationRepository {
  final _relationCollection = FirebaseFirestore.instance.collection('asking_relations');

  Future<void> sendRelationRequest(AskingRelation relation) async {
    await _relationCollection.add(relation.toJson());
  }

  Future<bool> hasPendingRequest(String fromUserId, String toUserId) async {
    final query = await _relationCollection
        .where('fromUserId', isEqualTo: fromUserId)
        .where('toUserId', isEqualTo: toUserId)
        .get();
    print('[DEBUG][hasPendingRequest] fromUserId=$fromUserId, toUserId=$toUserId, docs=${query.docs.map((d) => d.data())}');
    return query.docs.isNotEmpty;
  }

  // Ajout pour la gestion des relations
  final _relationsCollection = FirebaseFirestore.instance.collection('relations');

  Future<void> createRelation(String userA, String userB) async {
    await _relationsCollection.add({
      'firstUserId': userA,
      'secondUserId': userB,
    });
  }

  Future<void> deleteRelation(String userA, String userB) async {
    final query = await _relationsCollection
      .where('firstUserId', isEqualTo: userA)
      .where('secondUserId', isEqualTo: userB)
      .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
    final query2 = await _relationsCollection
      .where('firstUserId', isEqualTo: userB)
      .where('secondUserId', isEqualTo: userA)
      .get();
    for (var doc in query2.docs) {
      await doc.reference.delete();
    }
  }

  Future<bool> relationExists(String userA, String userB) async {
    final query = await _relationsCollection
      .where('firstUserId', isEqualTo: userA)
      .where('secondUserId', isEqualTo: userB)
      .get();
    if (query.docs.isNotEmpty) return true;
    final query2 = await _relationsCollection
      .where('firstUserId', isEqualTo: userB)
      .where('secondUserId', isEqualTo: userA)
      .get();
    return query2.docs.isNotEmpty;
  }

  Future<void> deleteRelationRequest(String fromUserId, String toUserId) async {
    final query = await _relationCollection
      .where('fromUserId', isEqualTo: fromUserId)
      .where('toUserId', isEqualTo: toUserId)
      .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }

  // Retourne la liste des userId que l'utilisateur suit (fromUserId = currentUserId)
  Future<List<String>> getFollowedUserIds(String currentUserId) async {
    final query = await _relationCollection
        .where('fromUserId', isEqualTo: currentUserId)
        .get();
    return query.docs.map((doc) => doc['toUserId'] as String).toList();
  }
} 