import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/models/user.dart';
import '../core/models/tweet.dart';
import '../core/repositories/user_data/user_repository.dart';
import '../core/repositories/tweet/tweet_repository.dart';
import '../widget/tweet_widget.dart';
import '../screens/tweet_detail_screen.dart';
import '../core/blocs/tweet_bloc/tweet_bloc.dart';
import '../core/blocs/tweet_bloc/tweet_event.dart';
import '../core/repositories/tweet/like_repository.dart';
import 'package:flutter/services.dart';
import '../core/blocs/relation_bloc/relation_bloc.dart';
import '../core/blocs/relation_bloc/relation_event.dart';
import '../core/blocs/relation_bloc/relation_state.dart';
import '../core/repositories/relation/relation_repository.dart';
import '../core/models/asking_relation.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final VoidCallback? onPopRefetch;
  const ProfileScreen({super.key, required this.userId, this.onPopRefetch});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseUser? firebaseUser;
  UserFromBloc? user;
  List<Tweet> userTweets = [];
  bool isLoading = true;
  String? error;
  bool get isCurrentUser => FirebaseAuth.instance.currentUser?.uid == widget.userId;
  late final TweetBloc tweetBloc;
  late final RelationBloc relationBloc;

  @override
  void initState() {
    super.initState();
    tweetBloc = TweetBloc(tweetRepository: RepositoryProvider.of<TweetRepository>(context, listen: false));
    relationBloc = RelationBloc(relationRepository: RelationRepository());
    _fetchProfile();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (!isCurrentUser && currentUserId != null) {
      relationBloc.add(CheckFullRelationStatus(currentUserId: currentUserId, profileUserId: widget.userId));
    }
  }

  @override
  void dispose() {
    widget.onPopRefetch?.call();
    tweetBloc.close();
    relationBloc.close();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final userRepo = RepositoryProvider.of<UserRepository>(context, listen: false);
      final tweetRepo = RepositoryProvider.of<TweetRepository>(context, listen: false);
      firebaseUser = await userRepo.getUserById(widget.userId);
      user = firebaseUser?.toUserFromBloc();
      final allTweets = await tweetRepo.fetchTweets();
      userTweets = allTweets.where((t) => t.userId == widget.userId && t.isComment == false).toList();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement du profil';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop('refresh');
        return false;
      },
      child: BlocProvider.value(
        value: relationBloc,
        child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop('refresh');
            },
          ),
          actions: [
            if (isCurrentUser)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () {
                  // Naviguer vers l'écran de modification du profil
                },
              ),
            if (!isCurrentUser)
              BlocConsumer<RelationBloc, RelationState>(
                listener: (context, state) {
                  if (state is RelationActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Action réalisée !', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                    );
                    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                    if (currentUserId != null) {
                      relationBloc.add(CheckFullRelationStatus(currentUserId: currentUserId, profileUserId: widget.userId));
                    }
                  } else if (state is RelationActionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                  if (state is RelationStatusState) {
                    // DEBUG
                    print('[DEBUG] isRelated:  [33m [1m [4m [7m${state.isRelated} [0m, hasSentRequest: ${state.hasSentRequest}, hasReceivedRequest: ${state.hasReceivedRequest}, loading: ${state.loading}');
                    if (state.loading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    if (state.isRelated) {
                      return IconButton(
                        icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                        tooltip: 'Supprimer la relation',
                        onPressed: () {
                          if (currentUserId != null) {
                            relationBloc.add(DeleteRelation(userA: currentUserId, userB: widget.userId));
                          }
                        },
                      );
                    }
                    if (state.hasReceivedRequest && !state.isRelated) {
                      return Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            tooltip: 'Accepter la demande',
                            onPressed: () {
                              if (currentUserId != null) {
                                relationBloc.add(AcceptRelationRequest(fromUserId: widget.userId, toUserId: currentUserId));
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.redAccent),
                            tooltip: 'Refuser la demande',
                            onPressed: () {
                              if (currentUserId != null) {
                                relationBloc.add(RefuseRelationRequest(fromUserId: widget.userId, toUserId: currentUserId));
                              }
                            },
                          ),
                        ],
                      );
                    }
                    if (state.hasSentRequest) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.hourglass_top, color: Colors.orange, size: 28),
                      );
                    }
                    // Sinon, bouton d'envoi de demande
                    return IconButton(
                      icon: const Icon(Icons.person_add_alt_1, color: Colors.blueAccent),
                      tooltip: 'Envoyer une demande de relation',
                      onPressed: () {
                        if (currentUserId != null) {
                          relationBloc.add(
                            SendRelationRequest(
                              AskingRelation(fromUserId: currentUserId, toUserId: widget.userId),
                            ),
                          );
                        }
                      },
                    );
                  }
                  // Fallback loading
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
              ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                : RefreshIndicator(
                    onRefresh: _fetchProfile,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      children: [
                        const SizedBox(height: 24),
                        // Photo de profil centrée
                        Center(
                          child: CircleAvatar(
                            radius: 54,
                            backgroundImage: (user?.imageUrl != null && user!.imageUrl!.isNotEmpty)
                                ? NetworkImage(user!.imageUrl!)
                                : null,
                            backgroundColor: Colors.grey[900],
                            child: (user?.imageUrl == null || user!.imageUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 54, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Pseudo
                        Center(
                          child: Text(
                            user?.pseudo ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Bio
                        if (user?.bio != null && user!.bio.isNotEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                user!.bio,
                                style: const TextStyle(color: Colors.grey, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        const SizedBox(height: 18),
                        // Ligne séparatrice
                        Container(
                          height: 1,
                          color: Colors.grey[800],
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        const SizedBox(height: 18),
                        // Section tweets
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          child: Text(
                            'Tweets',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        ...userTweets.map((tweet) => TweetItem(
                              tweet: tweet,
                              author: user!,
                              userId: FirebaseAuth.instance.currentUser?.uid,
                              tweetBloc: tweetBloc,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MultiRepositoryProvider(
                                      providers: [
                                        RepositoryProvider.value(value: RepositoryProvider.of<TweetRepository>(context)),
                                        RepositoryProvider.value(value: RepositoryProvider.of<UserRepository>(context)),
                                      ],
                                      child: TweetDetailScreen(
                                        tweet: tweet,
                                        author: user!,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),
                        if (userTweets.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Text('Aucun tweet', style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}

class TweetItem extends StatefulWidget {
  final Tweet tweet;
  final UserFromBloc author;
  final String? userId;
  final TweetBloc tweetBloc;
  final VoidCallback? onTap;
  const TweetItem({super.key, required this.tweet, required this.author, required this.userId, required this.tweetBloc, this.onTap});

  @override
  State<TweetItem> createState() => _TweetItemState();
}

class _TweetItemState extends State<TweetItem> {
  late bool isLiked;
  late int likesCount;
  final likeRepository = LikeRepository();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    isLiked = false;
    likesCount = widget.tweet.likes;
    _initLike();
  }

  Future<void> _initLike() async {
    if (widget.userId != null) {
      final liked = await likeRepository.isLiked(userId: widget.userId!, tweetId: widget.tweet.id);
      if (mounted) setState(() => isLiked = liked);
    }
  }

  void _handleLike() async {
    if (widget.userId == null || loading) return;
    setState(() {
      loading = true;
      isLiked = !isLiked;
      likesCount += isLiked ? 1 : -1;
    });
    if (isLiked) {
      widget.tweetBloc.add(LikeTweet(userId: widget.userId!, tweetId: widget.tweet.id));
    } else {
      widget.tweetBloc.add(UnlikeTweet(userId: widget.userId!, tweetId: widget.tweet.id));
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: TweetWidget(
        tweet: widget.tweet.copyWith(likes: likesCount),
        author: widget.author,
        isLiked: isLiked,
        onLike: _handleLike,
      ),
    );
  }
} 