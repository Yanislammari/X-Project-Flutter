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
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: (widget.otherUser.imagePath != null && widget.otherUser.imagePath!.isNotEmpty)
                      ? NetworkImage(widget.otherUser.imagePath!)
                      : null,
                  backgroundColor: Colors.grey[900],
                  child: (widget.otherUser.imagePath == null || widget.otherUser.imagePath!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(widget.otherUser.pseudo ?? '', style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          backgroundColor: Colors.black,
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<MessageBloc, MessageState>(
                  builder: (context, state) {
                    if (state is MessageInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MessageLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                        }
                      });
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          final isMe = msg.senderId == user?.uid;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blueAccent : Colors.grey[850],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(isMe ? 18 : 0),
                                  bottomRight: Radius.circular(isMe ? 0 : 18),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.content,
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    _formatTime(msg.sentAt),
                                    style: TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is MessageError) {
                      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              Container(
                color: Colors.grey[900],
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Écrire un message...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey[850],
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blueAccent),
                      onPressed: () {
                        final content = _controller.text.trim();
                        if (content.isNotEmpty && user != null) {
                          final msg = Message(
                            id: '',
                            conversationId: widget.conversationId,
                            senderId: user.uid,
                            receiverId: widget.otherUser.uid!,
                            content: content,
                            sentAt: DateTime.now(),
                          );
                          context.read<MessageBloc>().add(SendMessageEvent(msg));
                          _controller.clear();
                        }
                      },
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
    if (now.difference(dateTime).inDays == 0) {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dateTime.day}/${dateTime.month}";
    }
  }
} 