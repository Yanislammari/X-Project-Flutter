import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/blocs/message_bloc/message_bloc.dart';
import '../core/blocs/message_bloc/message_event.dart';
import '../core/blocs/message_bloc/message_state.dart';
import '../core/repositories/message/message_repository.dart';
import '../core/models/message.dart';
import '../core/models/user.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;
  final FirebaseUser otherUser;
  const ConversationScreen({super.key, required this.conversationId, required this.otherUser});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return BlocProvider(
      create: (_) => MessageBloc(messageRepository: MessageRepository())
        ..add(ListenMessages(widget.conversationId)),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.8),
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1D9BF0), Color(0xFF0F5F8F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: (widget.otherUser.imagePath != null && widget.otherUser.imagePath!.isNotEmpty)
                        ? NetworkImage(widget.otherUser.imagePath!)
                        : null,
                    radius: 16,
                    backgroundColor: const Color(0xFF536471),
                    child: (widget.otherUser.imagePath == null || widget.otherUser.imagePath!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.otherUser.pseudo ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.info_outline, color: Color(0xFF1D9BF0), size: 20),
                  onPressed: () {
                    // Action pour les infos de la conversation
                  },
                ),
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () {
              // Fermer le clavier quand on tape ailleurs
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<MessageBloc, MessageState>(
                    builder: (context, state) {
                      if (state is MessageInitial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1D9BF0),
                            strokeWidth: 2,
                          ),
                        );
                      } else if (state is MessageLoaded) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                        if (state.messages.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.waving_hand_outlined,
                                  color: Color(0xFF71767B),
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Dites bonjour !',
                                  style: TextStyle(
                                    color: Color(0xFF71767B),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Commencez votre conversation',
                                  style: TextStyle(
                                    color: Color(0xFF71767B),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(
                            top: 16,
                            bottom: 16 + (MediaQuery.of(context).viewInsets.bottom > 0 ? 80 : 0),
                            left: 16,
                            right: 16,
                          ),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isMe = message.senderId == user?.uid;
                            final isFirstInGroup = index == 0 ||
                                state.messages[index - 1].senderId != message.senderId;
                            final isLastInGroup = index == state.messages.length - 1 ||
                                state.messages[index + 1].senderId != message.senderId;
                            final showAvatar = !isMe && isLastInGroup;

                            return MessageBubble(
                              message: message,
                              isMe: isMe,
                              showAvatar: showAvatar,
                              isFirstInGroup: isFirstInGroup,
                              isLastInGroup: isLastInGroup,
                              otherUser: widget.otherUser,
                            );
                          },
                        );
                      } else if (state is MessageError) {
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
                            ],
                          ),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1D9BF0),
                            strokeWidth: 2,
                          ),
                        );
                      }
                    },
                  ),
                ),
                // Zone de saisie fixe en bas
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFF2F3336),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: 40,
                                maxHeight: 100,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16181C),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF2F3336),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                maxLines: null,
                                textCapitalization: TextCapitalization.sentences,
                                decoration: const InputDecoration(
                                  hintText: 'Écrire un message...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF71767B),
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1D9BF0), Color(0xFF0F5F8F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1D9BF0).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                final content = _controller.text.trim();
                                if (content.isNotEmpty && user != null) {
                                  final msg = Message(
                                    id: '',
                                    conversationId: widget.conversationId,
                                    receiverId: widget.otherUser.uid!,
                                    content: content,
                                    sentAt: DateTime.now(),
                                    senderId: user.uid,
                                  );
                                  context.read<MessageBloc>().add(SendMessageEvent(msg));
                                  _controller.clear();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final FirebaseUser otherUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: isFirstInGroup ? 8 : 2,
        bottom: isLastInGroup ? 8 : 2,
        left: isMe ? 48 : 0,
        right: isMe ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
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
                radius: 12,
                backgroundColor: const Color(0xFF536471),
                child: (otherUser.imagePath == null || otherUser.imagePath!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white, size: 14)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
          ] else if (!isMe) ...[
            const SizedBox(width: 32),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF1D9BF0) : const Color(0xFF16181C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 18 : (isFirstInGroup ? 18 : 8)),
                  topRight: Radius.circular(isMe ? (isFirstInGroup ? 18 : 8) : 18),
                  bottomLeft: Radius.circular(isMe ? 18 : (isLastInGroup ? 18 : 8)),
                  bottomRight: Radius.circular(isMe ? (isLastInGroup ? 18 : 8) : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.white,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                  if (isLastInGroup) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.sentAt),
                          style: TextStyle(
                            color: isMe ? Colors.white.withOpacity(0.7) : const Color(0xFF71767B),
                            fontSize: 11,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.done,
                            color: Colors.white.withOpacity(0.7),
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
} 