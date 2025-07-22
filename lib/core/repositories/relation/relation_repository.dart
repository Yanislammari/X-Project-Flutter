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

  Future<List<String>> getFollowedUserIds(String currentUserId) async {
    final query = await _relationCollection
        .where('fromUserId', isEqualTo: currentUserId)
        .get();
    return query.docs.map((doc) => doc['toUserId'] as String).toList();
  }

  Future<List<String>> getRelatedUserIds(String currentUserId) async {
    // Récupère toutes les relations établies où l'utilisateur actuel est impliqué
    final query1 = await _relationsCollection
        .where('firstUserId', isEqualTo: currentUserId)
        .get();
    final query2 = await _relationsCollection
        .where('secondUserId', isEqualTo: currentUserId)
        .get();
    
    final relatedIds = <String>{};
    
    // Ajoute les secondUserId des relations où currentUserId est firstUserId
    for (final doc in query1.docs) {
      relatedIds.add(doc['secondUserId'] as String);
    }
    
    // Ajoute les firstUserId des relations où currentUserId est secondUserId
    for (final doc in query2.docs) {
      relatedIds.add(doc['firstUserId'] as String);
    }
    
    return relatedIds.toList();
  }
} 