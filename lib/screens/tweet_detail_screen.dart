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
import '../core/blocs/tweet_bloc/tweet_state.dart';

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
  List<Tweet> comments = [];
  bool loadingComments = true;
  String? error;
  late final TweetBloc tweetBloc;
  final user = FirebaseAuth.instance.currentUser;
  Map<String, bool> commentIsLiked = {};
  Map<String, int> commentLikesCount = {};
  final likeRepository = LikeRepository();
  bool mainTweetIsLiked = false;
  int mainTweetLikesCount = 0;

  @override
  void initState() {
    super.initState();
    final tweetRepo = RepositoryProvider.of<TweetRepository>(context, listen: false);
    tweetBloc = TweetBloc(tweetRepository: tweetRepo);
    _initMainTweetLike();
    _fetchComments();
  }

  @override
  void dispose() {
    tweetBloc.close();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() {
      loadingComments = true;
      error = null;
    });
    try {
      final tweetRepo = RepositoryProvider.of<TweetRepository>(context, listen: false);
      final allTweets = await tweetRepo.fetchTweets();
      comments = allTweets.where((t) => t.isComment == true && t.replyToTweetId == widget.tweet.id).toList();
      // Précharge les likes pour chaque commentaire
      if (user != null) {
        for (final comment in comments) {
          final liked = await likeRepository.isLiked(userId: user!.uid, tweetId: comment.id);
          commentIsLiked[comment.id] = liked;
          commentLikesCount[comment.id] = comment.likes;
        }
      } else {
        for (final comment in comments) {
          commentIsLiked[comment.id] = false;
          commentLikesCount[comment.id] = comment.likes;
        }
      }
      setState(() {
        loadingComments = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des commentaires';
        loadingComments = false;
      });
    }
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
    tweetBloc.add(
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
    _fetchComments();
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
    if (mainTweetIsLiked) {
      tweetBloc.add(LikeTweet(userId: user!.uid, tweetId: widget.tweet.id));
    } else {
      tweetBloc.add(UnlikeTweet(userId: user!.uid, tweetId: widget.tweet.id));
    }
  }

  void _handleLikeComment(Tweet comment) async {
    if (user == null) return;
    final isLiked = commentIsLiked[comment.id] ?? false;
    setState(() {
      commentIsLiked[comment.id] = !isLiked;
      commentLikesCount[comment.id] = (commentLikesCount[comment.id] ?? comment.likes) + (isLiked ? -1 : 1);
    });
    if (isLiked) {
      tweetBloc.add(UnlikeTweet(userId: user!.uid, tweetId: comment.id));
    } else {
      tweetBloc.add(LikeTweet(userId: user!.uid, tweetId: comment.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TweetBloc, TweetState>(
      listener: (context, state) {
        if (state is TweetDeleteSuccess) {
          if (state.deletedTweetId == widget.tweet.id) {
            Navigator.of(context).pop();
          } else {
            _fetchComments();
          }
        }
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Tweet', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TweetWidget(
                tweet: widget.tweet.copyWith(likes: mainTweetLikesCount),
                author: widget.author,
                isLiked: mainTweetIsLiked,
                onLike: _handleMainTweetLike,
                currentUserId: user?.uid,
                onDeleteTweet: (tweetId) {
                  tweetBloc.add(DeleteTweet(tweetId: tweetId));
                },
              ),
            ),
            const Divider(color: Colors.grey, height: 0),
            if (loadingComments)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
            else if (comments.isEmpty)
              const Center(child: Text('Aucun commentaire', style: TextStyle(color: Colors.grey)))
            else
              ...comments.map((comment) => CommentItem(
                comment: comment,
                tweetBloc: tweetBloc,
                userId: user?.uid,
              )),
            const Divider(color: Colors.grey, height: 24),
            // Champ de commentaire
            Container(
              color: const Color(0xFF181C20),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 5,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: "Tweete ta réponse...",
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.grey[900],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.image, color: Colors.blueAccent, size: 26),
                        onPressed: _pickImage,
                      ),
                      _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send, color: Colors.blueAccent, size: 26),
                              onPressed: _submitComment,
                            ),
                    ],
                  ),
                  if (_imageFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, height: 100),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _imageFile = null),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
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
}

class CommentItem extends StatefulWidget {
  final Tweet comment;
  final TweetBloc tweetBloc;
  final String? userId;
  const CommentItem({super.key, required this.comment, required this.tweetBloc, required this.userId});

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
    if (isLiked) {
      widget.tweetBloc.add(LikeTweet(userId: widget.userId!, tweetId: widget.comment.id));
    } else {
      widget.tweetBloc.add(UnlikeTweet(userId: widget.userId!, tweetId: widget.comment.id));
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
          widget.tweetBloc.add(DeleteTweet(tweetId: tweetId));
        },
      ),
    );
  }
} 