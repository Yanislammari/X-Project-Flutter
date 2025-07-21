import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/blocs/conversation_bloc/conversation_bloc.dart';
import '../core/blocs/conversation_bloc/conversation_event.dart';
import '../core/blocs/conversation_bloc/conversation_state.dart';
import '../core/repositories/message/conversation_repository.dart';
import '../core/models/conversation.dart';
import '../core/models/user.dart';
import '../core/repositories/user_data/user_repository.dart';
import '../core/repositories/user_data/firebase_user_data_source.dart';
import 'conversation_screen.dart';
import '../core/repositories/relation/relation_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Utilisateur non connecté', style: TextStyle(color: Colors.white))),
      );
    }
    return BlocProvider(
      create: (_) => ConversationBloc(conversationRepository: ConversationRepository())
        ..add(ListenConversations(user.uid)),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<ConversationBloc, ConversationState>(
          builder: (context, state) {
            if (state is ConversationInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ConversationLoaded) {
              if (state.conversations.isEmpty) {
                return const Center(child: Text('Aucune conversation', style: TextStyle(color: Colors.white70)));
              }
              return ListView.builder(
                itemCount: state.conversations.length,
                itemBuilder: (context, index) {
                  final conv = state.conversations[index];
                  final otherId = conv.participants.firstWhere((id) => id != user.uid);
                  return FutureBuilder<FirebaseUser?>(
                    future: UserRepository(userDataSource: FirebaseUserDataSource()).getUserById(otherId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const ListTile(title: Text('Chargement...', style: TextStyle(color: Colors.white)));
                      }
                      final otherUser = snapshot.data!;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (otherUser.imagePath != null && otherUser.imagePath!.isNotEmpty)
                              ? NetworkImage(otherUser.imagePath!)
                              : null,
                          backgroundColor: Colors.grey[900],
                          child: (otherUser.imagePath == null || otherUser.imagePath!.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(otherUser.pseudo ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          conv.lastMessage?.content ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: conv.lastMessage != null
                            ? Text(
                                _formatTime(conv.lastMessage!.sentAt),
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              )
                            : null,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ConversationScreen(
                                conversationId: conv.id,
                                otherUser: otherUser,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            } else if (state is ConversationError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: _StartConversationButton(currentUserId: user.uid),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    if (now.difference(dateTime).inDays == 0) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dateTime.day}/${dateTime.month}";
    }
  }
}

class _StartConversationButton extends StatelessWidget {
  final String currentUserId;
  const _StartConversationButton({required this.currentUserId});

  Future<List<FirebaseUser>> _fetchFollowedUsers() async {
    final repo = RelationRepository();
    final followedIds = await repo.getFollowedUserIds(currentUserId);
    final userRepo = UserRepository(userDataSource: FirebaseUserDataSource());
    final users = <FirebaseUser>[];
    for (final id in followedIds) {
      final u = await userRepo.getUserById(id);
      if (u != null) users.add(u);
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.blueAccent,
      child: const Icon(Icons.message, color: Colors.white),
      onPressed: () async {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.grey[900],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          builder: (context) {
            return FutureBuilder<List<FirebaseUser>>(
              future: _fetchFollowedUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final users = snapshot.data!;
                if (users.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Vous ne suivez personne', style: TextStyle(color: Colors.white70))),
                  );
                }
                return ListView(
                  children: users.map((u) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (u.imagePath != null && u.imagePath!.isNotEmpty)
                          ? NetworkImage(u.imagePath!)
                          : null,
                      backgroundColor: Colors.grey[900],
                      child: (u.imagePath == null || u.imagePath!.isEmpty)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(u.pseudo ?? '', style: const TextStyle(color: Colors.white)),
                    onTap: () async {
                      final convId = await _getOrCreateConversation(currentUserId, u.uid!);
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConversationScreen(
                            conversationId: convId,
                            otherUser: u,
                          ),
                        ),
                      );
                    },
                  )).toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<String> _getOrCreateConversation(String userA, String userB) async {
    final firestore = FirebaseFirestore.instance;
    final convs = await firestore
        .collection('conversations')
        .where('participants', arrayContains: userA)
        .get();
    for (final doc in convs.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants']);
      if (participants.contains(userB)) {
        return doc.id;
      }
    }
    final doc = await firestore.collection('conversations').add({
      'participants': [userA, userB],
      'updatedAt': DateTime.now(),
    });
    return doc.id;
  }
} 