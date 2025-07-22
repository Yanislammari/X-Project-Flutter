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
                        width: 150,
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
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        final user = snapshot.data!;
        final isLikeNotification = notification.type == NotificationType.LikeReceived;
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (notification.type == NotificationType.LikeReceived && notification.likeId != null) {
                final tweetRepo = TweetRepository(tweetDataSource: FirebaseTweetDataSource());
                final tweet = await tweetRepo.fetchTweetById(notification.likeId!);
                if (tweet != null) {
                  Navigator.of(context).pushNamed(
                    TweetDetailScreen.routeName,
                    arguments: {
                      'tweetId': tweet.id,
                      'authorId': tweet.userId,
                    },
                  );
                }
              } else if (notification.type == NotificationType.AskingRelationReceived && notification.userId.isNotEmpty) {
                Navigator.of(context).pushNamed(
                  ProfileScreen.routeName,
                  arguments: {'userId': notification.userId},
                );
              }
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isLikeNotification 
                          ? const Color(0xFFF91880).withOpacity(0.1)
                          : const Color(0xFF1D9BF0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLikeNotification 
                            ? const Color(0xFFF91880).withOpacity(0.3)
                            : const Color(0xFF1D9BF0).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      isLikeNotification ? Icons.favorite : Icons.person_add_alt_1,
                      color: isLikeNotification 
                          ? const Color(0xFFF91880)
                          : const Color(0xFF1D9BF0),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User avatar
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: isLikeNotification 
                            ? [const Color(0xFFF91880), const Color(0xFFBF1650)]
                            : [const Color(0xFF1D9BF0), const Color(0xFF0F5F8F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundImage: (user.imagePath != null && user.imagePath!.isNotEmpty)
                          ? NetworkImage(user.imagePath!)
                          : null,
                      radius: 18,
                      backgroundColor: const Color(0xFF536471),
                      child: (user.imagePath == null || user.imagePath!.isEmpty)
                          ? const Icon(Icons.person, size: 20, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: user.pseudo ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              TextSpan(
                                text: isLikeNotification
                                    ? ' a aimé votre Tweet'
                                    : ' souhaite vous suivre',
                                style: const TextStyle(
                                  color: Color(0xFF71767B),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(notification.timestamp),
                          style: const TextStyle(
                            color: Color(0xFF71767B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action indicator
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (isLikeNotification 
                          ? const Color(0xFFF91880)
                          : const Color(0xFF1D9BF0)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: isLikeNotification 
                          ? const Color(0xFFF91880)
                          : const Color(0xFF1D9BF0),
                      size: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
  }
} 