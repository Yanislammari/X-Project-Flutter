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
      child: BlocProvider(
        create: (context) => TweetBloc(
          tweetRepository: RepositoryProvider.of<TweetRepository>(context),
        )..add(FetchTweets()),
        child: const _TweetListView(),
      ),
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

  @override
  void initState() {
    super.initState();
    userId = user?.uid;
    shouldRefetchTweets.addListener(_onShouldRefetchTweets);
  }

  void _onShouldRefetchTweets() {
    if (shouldRefetchTweets.value) {
      context.read<TweetBloc>().add(FetchTweets());
      shouldRefetchTweets.value = false;
    }
  }

  @override
  void dispose() {
    shouldRefetchTweets.removeListener(_onShouldRefetchTweets);
    super.dispose();
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
    // Après ajout, on refetch la liste via le bloc
    context.read<TweetBloc>().add(FetchTweets());
  }

  void _openProfileScreen(BuildContext context, String userId) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: userId),
      ),
    );
    if (result == 'refresh') {
      context.read<TweetBloc>().add(FetchTweets());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRepository = RepositoryProvider.of<UserRepository>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BlocBuilder<TweetBloc, TweetState>(
          builder: (context, state) {
            if (state.status == TweetStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1D9BF0),
                  strokeWidth: 2,
                ),
              );
            } else if (state.status == TweetStatus.error) {
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
                      state.message ?? 'Une erreur est survenue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<TweetBloc>().add(FetchTweets()),
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
            } else if (state.status == TweetStatus.loaded && state.tweets != null) {
              final tweets = state.tweets!.where((t) => !t.isComment).toList();
              
              return RefreshIndicator(
                color: const Color(0xFF1D9BF0),
                backgroundColor: const Color(0xFF16181C),
                onRefresh: () async {
                  context.read<TweetBloc>().add(FetchTweets());
                },
                child: tweets.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                          const Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.post_add_outlined,
                                  color: Color(0xFF71767B),
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Aucun Tweet pour le moment',
                                  style: TextStyle(
                                    color: Color(0xFF71767B),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Soyez le premier à partager quelque chose !',
                                  style: TextStyle(
                                    color: Color(0xFF71767B),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: tweets.length,
                        itemBuilder: (context, index) {
                          final tweet = tweets[index];
                          return FutureBuilder(
                            future: userRepository.getUserById(tweet.userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF16181C),
                                          borderRadius: BorderRadius.circular(20),
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
                                              width: double.infinity,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF16181C),
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
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
                                        child: BlocProvider(
                                          create: (context) => TweetBloc(
                                            tweetRepository: RepositoryProvider.of<TweetRepository>(context),
                                          )..add(FetchTweets()),
                                          child: TweetDetailScreen(
                                            tweet: tweet,
                                            author: user,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  // Rafraîchir après retour du détail
                                  context.read<TweetBloc>().add(FetchTweets());
                                },
                                child: TweetItem(
                                  tweet: tweet,
                                  author: user,
                                  userId: userId,
                                  onDeleteTweet: (tweetId) {
                                    context.read<TweetBloc>().add(DeleteTweet(tweetId: tweetId));
                                  },
                                ),
                              );
                            },
                          );
                        },
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
          onPressed: _handleAddTweet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
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
  final Function(String)? onDeleteTweet;
  const TweetItem({super.key, required this.tweet, required this.author, required this.userId, this.onDeleteTweet});

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
    final tweetBloc = context.read<TweetBloc>();
    if (isLiked) {
      tweetBloc.add(LikeTweet(userId: widget.userId!, tweetId: widget.tweet.id));
    } else {
      tweetBloc.add(UnlikeTweet(userId: widget.userId!, tweetId: widget.tweet.id));
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