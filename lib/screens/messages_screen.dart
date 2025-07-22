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
import '../core/blocs/relation_bloc/relation_bloc.dart';
import '../core/blocs/relation_bloc/relation_event.dart';
import '../core/blocs/relation_bloc/relation_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                color: Color(0xFF71767B),
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Utilisateur non connecté',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConversationBloc(conversationRepository: ConversationRepository())
            ..add(ListenConversations(user.uid)),
        ),
        BlocProvider(
          create: (_) => RelationBloc(relationRepository: RelationRepository()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF2F3336),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D9BF0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF1D9BF0).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.mail_outlined,
                        color: Color(0xFF1D9BF0),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D9BF0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF1D9BF0).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Color(0xFF1D9BF0),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: BlocBuilder<ConversationBloc, ConversationState>(
                  builder: (context, state) {
                    if (state is ConversationInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1D9BF0),
                          strokeWidth: 2,
                        ),
                      );
                    } else if (state is ConversationLoaded) {
                      if (state.conversations.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Color(0xFF71767B),
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune conversation',
                                style: TextStyle(
                                  color: Color(0xFF71767B),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Commencez une conversation avec vos amis',
                                style: TextStyle(
                                  color: Color(0xFF71767B),
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.conversations.length,
                        itemBuilder: (context, index) {
                          final conv = state.conversations[index];
                          final otherId = conv.participants.firstWhere((id) => id != user.uid);
                          return FutureBuilder<FirebaseUser?>(
                            future: UserRepository(userDataSource: FirebaseUserDataSource()).getUserById(otherId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF16181C),
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 120,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF16181C),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              width: 200,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF16181C),
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final otherUser = snapshot.data!;
                              return ConversationItem(
                                conversation: conv,
                                otherUser: otherUser,
                                currentUserId: user.uid,
                              );
                            },
                          );
                        },
                      );
                    } else if (state is ConversationError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFF4212E),
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ConversationBloc>().add(
                                  ListenConversations(user.uid),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D9BF0),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Réessayer',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D9BF0), Color(0xFF0F5F8F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D9BF0).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _showStartConversationModal(context, user.uid),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  void _showStartConversationModal(BuildContext context, String currentUserId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _StartConversationModal(currentUserId: currentUserId),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'maintenant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return "${dateTime.day}/${dateTime.month}";
    }
  }
}

class ConversationItem extends StatelessWidget {
  final Conversation conversation;
  final FirebaseUser otherUser;
  final String currentUserId;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.otherUser,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ConversationScreen(
                conversationId: conversation.id,
                otherUser: otherUser,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF2F3336),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D9BF0), Color(0xFF0F5F8F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: (otherUser.imagePath != null && otherUser.imagePath!.isNotEmpty)
                      ? NetworkImage(otherUser.imagePath!)
                      : null,
                  radius: 22,
                  backgroundColor: const Color(0xFF536471),
                  child: (otherUser.imagePath == null || otherUser.imagePath!.isEmpty)
                      ? const Icon(Icons.person, size: 24, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            otherUser.pseudo ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (conversation.lastMessage != null) ...[
                          Text(
                            _formatTime(conversation.lastMessage!.sentAt),
                            style: const TextStyle(
                              color: Color(0xFF71767B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.lastMessage?.content ?? 'Nouvelle conversation',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF71767B),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'maintenant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return "${dateTime.day}/${dateTime.month}";
    }
  }
}

class _StartConversationModal extends StatefulWidget {
  final String currentUserId;
  const _StartConversationModal({required this.currentUserId});

  @override
  State<_StartConversationModal> createState() => _StartConversationModalState();
}

class _StartConversationModalState extends State<_StartConversationModal> {
  List<FirebaseUser> relatedUsers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRelatedUsers();
  }

  Future<void> _loadRelatedUsers() async {
    setState(() => isLoading = true);
    try {
      final repo = RelationRepository();
      final relatedIds = await repo.getRelatedUserIds(widget.currentUserId);
      final userRepo = UserRepository(userDataSource: FirebaseUserDataSource());
      final users = <FirebaseUser>[];
      for (final id in relatedIds) {
        final u = await userRepo.getUserById(id);
        if (u != null) users.add(u);
      }
      setState(() {
        relatedUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Erreur lors du chargement des relations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF71767B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF2F3336),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.edit,
                  color: Color(0xFF1D9BF0),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Nouvelle conversation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF71767B),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1D9BF0),
                      strokeWidth: 2,
                    ),
                  )
                : relatedUsers.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: Color(0xFF71767B),
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Aucune relation établie',
                              style: TextStyle(
                                color: Color(0xFF71767B),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Établissez des relations pour commencer des conversations',
                              style: TextStyle(
                                color: Color(0xFF71767B),
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: relatedUsers.length,
                        itemBuilder: (context, index) {
                          final user = relatedUsers[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final convId = await _getOrCreateConversation(widget.currentUserId, user.uid!);
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ConversationScreen(
                                      conversationId: convId,
                                      otherUser: user,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF1D9BF0), Color(0xFF0F5F8F)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage: (user.imagePath != null && user.imagePath!.isNotEmpty)
                                            ? NetworkImage(user.imagePath!)
                                            : null,
                                        radius: 20,
                                        backgroundColor: const Color(0xFF536471),
                                        child: (user.imagePath == null || user.imagePath!.isEmpty)
                                            ? const Icon(Icons.person, size: 20, color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.pseudo ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (user.bio != null && user.bio!.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              user.bio!,
                                              style: const TextStyle(
                                                color: Color(0xFF71767B),
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1D9BF0).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFF1D9BF0).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_outline,
                                        color: Color(0xFF1D9BF0),
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
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