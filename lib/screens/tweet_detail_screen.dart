import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/models/tweet.dart';
import '../core/models/user.dart';
import '../core/repositories/tweet/tweet_repository.dart';
import '../core/repositories/tweet/like_repository.dart';
import '../core/repositories/user_data/user_repository.dart';
import '../widget/tweet_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/blocs/tweet_bloc/tweet_bloc.dart';
import '../core/blocs/tweet_bloc/tweet_event.dart';

class TweetDetailScreen extends StatefulWidget {
  final Tweet tweet;
  final UserFromBloc author;
  const TweetDetailScreen({super.key, required this.tweet, required this.author});

  @override
  State<TweetDetailScreen> createState() => _TweetDetailScreenState();
}

class _TweetDetailScreenState extends State<TweetDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  final user = FirebaseAuth.instance.currentUser;
  final likeRepository = LikeRepository();
  bool mainTweetIsLiked = false;
  int mainTweetLikesCount = 0;

  @override
  void initState() {
    super.initState();
    _initMainTweetLike();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _submitComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty || user == null) return;
    setState(() => _isLoading = true);
    
    context.read<TweetBloc>().add(
      AddTweet(
        userId: user!.uid,
        content: content,
        imageFile: _imageFile,
        isComment: true,
        replyToTweetId: widget.tweet.id,
      ),
    );
    
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _controller.clear();
      _imageFile = null;
      _isLoading = false;
    });
  }

  Future<void> _initMainTweetLike() async {
    if (user != null) {
      final liked = await likeRepository.isLiked(userId: user!.uid, tweetId: widget.tweet.id);
      setState(() {
        mainTweetIsLiked = liked;
        mainTweetLikesCount = widget.tweet.likes;
      });
    } else {
      setState(() {
        mainTweetIsLiked = false;
        mainTweetLikesCount = widget.tweet.likes;
      });
    }
  }

  void _handleMainTweetLike() async {
    if (user == null) return;
    setState(() {
      mainTweetIsLiked = !mainTweetIsLiked;
      mainTweetLikesCount += mainTweetIsLiked ? 1 : -1;
    });
    final tweetBloc = context.read<TweetBloc>();
    if (mainTweetIsLiked) {
      tweetBloc.add(LikeTweet(userId: user!.uid, tweetId: widget.tweet.id));
    } else {
      tweetBloc.add(UnlikeTweet(userId: user!.uid, tweetId: widget.tweet.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TweetBloc, TweetState>(
      listener: (context, state) {
        if (state.status == TweetStatus.loaded && state.tweets != null) {
          // Vérifier si le tweet principal a été supprimé
          final mainTweetExists = state.tweets!.any((t) => t.id == widget.tweet.id);
          if (!mainTweetExists) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
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
          title: const Text(
            'Tweet',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.share_outlined, color: Color(0xFF1D9BF0), size: 20),
                onPressed: () {
                  // Action de partage
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
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Main Tweet
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF2F3336),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: TweetWidget(
                          tweet: widget.tweet.copyWith(likes: mainTweetLikesCount),
                          author: widget.author,
                          isLiked: mainTweetIsLiked,
                          onLike: _handleMainTweetLike,
                          currentUserId: user?.uid,
                          onDeleteTweet: (tweetId) {
                            context.read<TweetBloc>().add(DeleteTweet(tweetId: tweetId));
                          },
                        ),
                      ),
                    ),
                    // Comments Header and List
                    BlocBuilder<TweetBloc, TweetState>(
                      builder: (context, state) {
                        if (state.status == TweetStatus.loaded && state.tweets != null) {
                                                      final comments = state.tweets!.where((t) => t.isComment == true && t.replyToTweetId == widget.tweet.id).toList();
                          
                          return SliverMainAxisGroup(
                            slivers: [
                              // Comments Header
                              SliverToBoxAdapter(
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
                                      const Icon(
                                        Icons.chat_bubble_outline,
                                        color: Color(0xFF1D9BF0),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Réponses (${comments.length})',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Comments List
                              if (comments.isEmpty)
                                SliverToBoxAdapter(
                                  child: Container(
                                    padding: const EdgeInsets.all(64),
                                    child: const Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline,
                                            color: Color(0xFF71767B),
                                            size: 64,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Aucune réponse',
                                            style: TextStyle(
                                              color: Color(0xFF71767B),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Soyez le premier à répondre à ce Tweet',
                                            style: TextStyle(
                                              color: Color(0xFF71767B),
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return CommentItem(
                                        comment: comments[index],
                                        userId: user?.uid,
                                      );
                                    },
                                    childCount: comments.length,
                                  ),
                                ),
                            ],
                          );
                        } else if (state.status == TweetStatus.loading) {
                          return SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.all(64),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF1D9BF0),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        } else if (state.status == TweetStatus.error) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Color(0xFFF4212E),
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      state.message ?? 'Une erreur est survenue',
                                      style: const TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.all(64),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF1D9BF0),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    // Padding supplémentaire pour éviter que le dernier élément soit caché
                    SliverToBoxAdapter(
                      child: SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 16),
                    ),
                  ],
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
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
                                    hintText: "Tweete ta réponse...",
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
                                color: const Color(0xFF16181C),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF2F3336),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.image_outlined,
                                  color: Color(0xFF1D9BF0),
                                  size: 20,
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                            const SizedBox(width: 8),
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
                              child: _isLoading
                                  ? Container(
                                      width: 40,
                                      height: 40,
                                      padding: const EdgeInsets.all(8),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _submitComment,
                                    ),
                            ),
                          ],
                        ),
                        if (_imageFile != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2F3336),
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _imageFile!,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _imageFile = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentItem extends StatefulWidget {
  final Tweet comment;
  final String? userId;
  const CommentItem({super.key, required this.comment, required this.userId});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  late bool isLiked;
  late int likesCount;
  final likeRepository = LikeRepository();
  bool loading = false;
  UserFromBloc? author;

  @override
  void initState() {
    super.initState();
    isLiked = false;
    likesCount = widget.comment.likes;
    _initLikeAndAuthor();
  }

  Future<void> _initLikeAndAuthor() async {
    if (widget.userId != null) {
      final liked = await likeRepository.isLiked(userId: widget.userId!, tweetId: widget.comment.id);
      if (mounted) setState(() => isLiked = liked);
    }
    final userRepo = RepositoryProvider.of<UserRepository>(context, listen: false);
    final user = await userRepo.getUserById(widget.comment.userId);
    if (mounted && user != null) setState(() => author = user.toUserFromBloc());
  }

  void _handleLike() async {
    if (widget.userId == null || loading) return;
    setState(() {
      loading = true;
      isLiked = !isLiked;
      likesCount += isLiked ? 1 : -1;
    });
    final tweetBloc = context.read<TweetBloc>();
    if (isLiked) {
      tweetBloc.add(LikeTweet(userId: widget.userId!, tweetId: widget.comment.id));
    } else {
      tweetBloc.add(UnlikeTweet(userId: widget.userId!, tweetId: widget.comment.id));
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (author == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TweetWidget(
        tweet: widget.comment.copyWith(likes: likesCount),
        author: author!,
        isLiked: isLiked,
        onLike: _handleLike,
        currentUserId: widget.userId,
        onDeleteTweet: (tweetId) {
          context.read<TweetBloc>().add(DeleteTweet(tweetId: tweetId));
        },
      ),
    );
  }
} 