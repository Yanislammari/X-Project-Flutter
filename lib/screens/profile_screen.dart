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
import '../core/repositories/relation/relation_repository.dart';
import '../core/models/asking_relation.dart';
import '../profile_screen/profile_screen.dart' as edit_profile;

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
  bool isLoadingUser = true;
  String? userError;
  bool get isCurrentUser => FirebaseAuth.instance.currentUser?.uid == widget.userId;
  late final RelationBloc relationBloc;

  @override
  void initState() {
    super.initState();
    relationBloc = RelationBloc(relationRepository: RelationRepository());
    _fetchUserProfile();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (!isCurrentUser && currentUserId != null) {
      relationBloc.add(CheckFullRelationStatus(currentUserId: currentUserId, profileUserId: widget.userId));
    }
  }

  @override
  void dispose() {
    widget.onPopRefetch?.call();
    relationBloc.close();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      isLoadingUser = true;
      userError = null;
    });
    try {
      final userRepo = RepositoryProvider.of<UserRepository>(context, listen: false);
      firebaseUser = await userRepo.getUserById(widget.userId);
      user = firebaseUser?.toUserFromBloc();
      setState(() {
        isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        userError = 'Erreur lors du chargement du profil';
        isLoadingUser = false;
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: relationBloc),
          BlocProvider(
            create: (context) => TweetBloc(
              tweetRepository: RepositoryProvider.of<TweetRepository>(context),
            )..add(FetchTweets()),
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.black,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.black.withOpacity(0.8),
                pinned: true,
                expandedHeight: 280,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop('refresh');
                    },
                  ),
                ),
                actions: [
                  if (isCurrentUser)
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF1D9BF0)),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const edit_profile.ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  if (!isCurrentUser)
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: BlocConsumer<RelationBloc, RelationState>(
                        listener: (context, state) {
                          if (state.status == RelationStatus.actionSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Action réalisée !',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: const Color(0xFF00BA7C),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                            if (currentUserId != null) {
                              relationBloc.add(CheckFullRelationStatus(currentUserId: currentUserId, profileUserId: widget.userId));
                            }
                          } else if (state.status == RelationStatus.actionError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  state.message ?? 'Une erreur est survenue',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: const Color(0xFFF4212E),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                          if (state.status == RelationStatus.statusLoaded) {
                                                          if (state.loading == true) {
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF1D9BF0),
                                  ),
                                ),
                              );
                            }
                            if (state.isRelated == true) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.person_remove, color: Color(0xFFF4212E)),
                                  tooltip: 'Supprimer la relation',
                                  onPressed: () {
                                    if (currentUserId != null) {
                                      relationBloc.add(DeleteRelation(userA: currentUserId, userB: widget.userId));
                                    }
                                  },
                                ),
                              );
                            }
                            if (state.hasReceivedRequest == true && state.isRelated != true) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.check_circle, color: Color(0xFF00BA7C)),
                                      tooltip: 'Accepter la demande',
                                      onPressed: () {
                                        if (currentUserId != null) {
                                          relationBloc.add(AcceptRelationRequest(fromUserId: widget.userId, toUserId: currentUserId));
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.cancel, color: Color(0xFFF4212E)),
                                      tooltip: 'Refuser la demande',
                                      onPressed: () {
                                        if (currentUserId != null) {
                                          relationBloc.add(RefuseRelationRequest(fromUserId: widget.userId, toUserId: currentUserId));
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }
                            if (state.hasSentRequest == true) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.hourglass_top, color: Color(0xFFFFD400), size: 24),
                                ),
                              );
                            }
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF1D9BF0)),
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
                              ),
                            );
                          }
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1D9BF0),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF1D9BF0).withOpacity(0.3),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isLoadingUser)
                          const CircularProgressIndicator(
                            color: Color(0xFF1D9BF0),
                            strokeWidth: 2,
                          )
                        else if (userError != null)
                          Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFF4212E),
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userError!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        else ...[
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                color: const Color(0xFF1D9BF0),
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: (user?.imageUrl != null && user!.imageUrl!.isNotEmpty)
                                  ? NetworkImage(user!.imageUrl!)
                                  : null,
                              backgroundColor: const Color(0xFF536471),
                              child: (user?.imageUrl == null || user!.imageUrl!.isEmpty)
                                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.pseudo ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          if (user?.bio != null && user!.bio.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                user!.bio,
                                style: const TextStyle(
                                  color: Color(0xFF71767B),
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<TweetBloc, TweetState>(
                  builder: (context, state) {
                    if (state.status == TweetStatus.loaded && state.tweets != null) {
                      final userTweets = state.tweets!.where((t) => t.userId == widget.userId && t.isComment == false).toList();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF1D9BF0),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tweets (${userTweets.length})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF1D9BF0),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tweets',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              BlocBuilder<TweetBloc, TweetState>(
                builder: (context, state) {
                                              if (state.status == TweetStatus.loading) {
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
                                      } else if (state.status == TweetStatus.loaded && state.tweets != null) {
                    final userTweets = state.tweets!.where((t) => t.userId == widget.userId && t.isComment == false).toList();
                    
                    if (userTweets.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(64),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.post_add_outlined,
                                  color: Color(0xFF71767B),
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Aucun Tweet',
                                  style: TextStyle(
                                    color: Color(0xFF71767B),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Quand vous tweetez, ils apparaîtront ici.',
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
                      );
                    }
                    
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tweet = userTweets[index];
                          return TweetItem(
                            tweet: tweet,
                            author: user!,
                            userId: FirebaseAuth.instance.currentUser?.uid,
                            onDeleteTweet: (tweetId) {
                              context.read<TweetBloc>().add(DeleteTweet(tweetId: tweetId));
                            },
                            onTap: () {
                              Navigator.of(context).push(
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
                                        author: user!,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: userTweets.length,
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
            ],
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
  final VoidCallback? onTap;
  final Function(String)? onDeleteTweet;
  const TweetItem({super.key, required this.tweet, required this.author, required this.userId, this.onTap, this.onDeleteTweet});

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
    return GestureDetector(
      onTap: widget.onTap,
      child: TweetWidget(
        tweet: widget.tweet.copyWith(likes: likesCount),
        author: widget.author,
        isLiked: isLiked,
        onLike: _handleLike,
        currentUserId: widget.userId,
        onDeleteTweet: widget.onDeleteTweet,
      ),
    );
  }
} 