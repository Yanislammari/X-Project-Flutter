import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/models/tweet.dart';
import '../core/models/user.dart';
import '../core/repositories/tweet/tweet_repository.dart';
import '../core/repositories/tweet/firebase_tweet_data_source.dart';
import '../core/repositories/tweet/like_repository.dart';
import '../core/repositories/user_data/user_repository.dart';
import '../core/repositories/user_data/firebase_user_data_source.dart';
import '../widget/tweet_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/add_tweet_screen.dart';
import '../core/blocs/tweet_bloc/tweet_bloc.dart';
import '../core/blocs/tweet_bloc/tweet_event.dart';
import '../core/blocs/tweet_bloc/tweet_state.dart';
import '../screens/tweet_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../globals.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => TweetRepository(tweetDataSource: FirebaseTweetDataSource()),
        ),
        RepositoryProvider(
          create: (_) => UserRepository(userDataSource: FirebaseUserDataSource()),
        ),
      ],
      child: const _TweetListView(),
    );
  }
}

class _TweetListView extends StatefulWidget {
  const _TweetListView();

  @override
  State<_TweetListView> createState() => _TweetListViewState();
}

class _TweetListViewState extends State<_TweetListView> {
  final likeRepository = LikeRepository();
  final user = FirebaseAuth.instance.currentUser;
  late String? userId;
  late final TweetBloc tweetBloc;
  List<Tweet> tweets = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    userId = user?.uid;
    final tweetRepo = RepositoryProvider.of<TweetRepository>(context, listen: false);
    tweetBloc = TweetBloc(tweetRepository: tweetRepo);
    _fetchTweets();
    shouldRefetchTweets.addListener(_onShouldRefetchTweets);
  }

  void _onShouldRefetchTweets() {
    if (shouldRefetchTweets.value) {
      _fetchTweets();
      shouldRefetchTweets.value = false;
    }
  }

  @override
  void dispose() {
    shouldRefetchTweets.removeListener(_onShouldRefetchTweets);
    tweetBloc.close();
    super.dispose();
  }

  Future<void> _fetchTweets() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final tweetRepo = RepositoryProvider.of<TweetRepository>(context, listen: false);
      final fetchedTweets = await tweetRepo.fetchTweets();
      tweets = fetchedTweets;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des tweets';
        isLoading = false;
      });
    }
  }

  void _handleAddTweet() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: RepositoryProvider.of<TweetRepository>(context)),
            RepositoryProvider.value(value: RepositoryProvider.of<UserRepository>(context)),
          ],
          child: BlocProvider(
            create: (context) => TweetBloc(
              tweetRepository: RepositoryProvider.of<TweetRepository>(context),
            ),
            child: const AddTweetScreen(),
          ),
        ),
      ),
    );
    // Après ajout, on refetch la liste
    _fetchTweets();
  }

  void _openProfileScreen(BuildContext context, String userId) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: userId),
      ),
    );
    if (result == 'refresh') {
      _fetchTweets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRepository = RepositoryProvider.of<UserRepository>(context);
    return BlocListener<TweetBloc, TweetState>(
      listener: (context, state) {
        if (state is TweetDeleteSuccess) {
          _fetchTweets();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        // AppBar supprimée, elle est maintenant gérée dans MainScreen
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                  : RefreshIndicator(
                      onRefresh: _fetchTweets,
                      child: ListView.builder(
                        itemCount: tweets.where((t) => !t.isComment).length,
                        itemBuilder: (context, index) {
                          final tweet = tweets.where((t) => !t.isComment).toList()[index];
                          return FutureBuilder(
                            future: userRepository.getUserById(tweet.userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              if (!snapshot.hasData || snapshot.data == null) {
                                return const SizedBox.shrink();
                              }
                              final user = (snapshot.data as FirebaseUser).toUserFromBloc();
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => MultiRepositoryProvider(
                                        providers: [
                                          RepositoryProvider.value(value: RepositoryProvider.of<TweetRepository>(context)),
                                          RepositoryProvider.value(value: RepositoryProvider.of<UserRepository>(context)),
                                        ],
                                        child: TweetDetailScreen(
                                          tweet: tweet,
                                          author: user,
                                        ),
                                      ),
                                    ),
                                  );
                                  _fetchTweets();
                                },
                                child: TweetItem(
                                  tweet: tweet,
                                  author: user,
                                  userId: userId,
                                  tweetBloc: tweetBloc,
                                  onDeleteTweet: (tweetId) {
                                    tweetBloc.add(DeleteTweet(tweetId: tweetId));
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _handleAddTweet,
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
          shape: const CircleBorder(),
          elevation: 6,
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
  final Function(String)? onDeleteTweet;
  const TweetItem({super.key, required this.tweet, required this.author, required this.userId, required this.tweetBloc, this.onDeleteTweet});

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
    return TweetWidget(
      tweet: widget.tweet.copyWith(likes: likesCount),
      author: widget.author,
      isLiked: isLiked,
      onLike: _handleLike,
      currentUserId: widget.userId,
      onDeleteTweet: widget.onDeleteTweet,
    );
  }
} 