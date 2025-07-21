import 'package:flutter/material.dart';
import '../core/models/notification.dart';
import '../core/models/user.dart';
import '../core/repositories/user_data/user_repository.dart';
import '../core/repositories/user_data/firebase_user_data_source.dart';
import '../core/repositories/tweet/tweet_repository.dart';
import '../core/repositories/tweet/firebase_tweet_data_source.dart';
import '../screens/tweet_detail_screen.dart';
import '../screens/profile_screen.dart';

class NotificationWidget extends StatelessWidget {
  final AppNotification notification;
  const NotificationWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser?>(
      future: UserRepository(userDataSource: FirebaseUserDataSource()).getUserById(notification.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(title: Text('Chargement...'));
        }
        final user = snapshot.data!;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (user.imagePath != null && user.imagePath!.isNotEmpty)
                ? NetworkImage(user.imagePath!)
                : null,
            backgroundColor: Colors.grey[900],
            child: (user.imagePath == null || user.imagePath!.isEmpty)
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: Text(
            notification.type == NotificationType.LikeReceived
                ? "${user.pseudo ?? ''} a liké un de vos posts"
                : "${user.pseudo ?? ''} veut être en relation avec vous",
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () async {
            if (notification.type == NotificationType.LikeReceived && notification.likeId != null) {
              final tweetRepo = TweetRepository(tweetDataSource: FirebaseTweetDataSource());
              final tweet = await tweetRepo.fetchTweetById(notification.likeId!);
              if (tweet != null) {
                final author = await UserRepository(userDataSource: FirebaseUserDataSource()).getUserById(tweet.userId);
                if (author != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TweetDetailScreen(
                        tweet: tweet,
                        author: author.toUserFromBloc(),
                      ),
                    ),
                  );
                }
              }
            } else if (notification.type == NotificationType.AskingRelationReceived && notification.userId.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: notification.userId),
                ),
              );
            }
          },
        );
      },
    );
  }
} 