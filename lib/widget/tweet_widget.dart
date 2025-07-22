import 'package:flutter/material.dart';
import '../core/models/tweet.dart';
import '../core/models/user.dart';

class TweetWidget extends StatelessWidget {
  final Tweet tweet;
  final UserFromBloc author;
  final bool isLiked;
  final VoidCallback onLike;
  final String? currentUserId;
  final Function(String)? onDeleteTweet;

  const TweetWidget({
    Key? key,
    required this.tweet,
    required this.author,
    required this.isLiked,
    required this.onLike,
    this.currentUserId,
    this.onDeleteTweet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = const Color(0xFF181C20);
    final textColor = Colors.white;
    final secondaryTextColor = Colors.grey[400];
    final borderColor = Colors.grey[800];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: author.imageUrl != null && author.imageUrl!.isNotEmpty
                      ? NetworkImage(author.imageUrl!)
                      : (author.imageFile != null && author.imageFile!.path.isNotEmpty
                          ? FileImage(author.imageFile!)
                          : null),
                  backgroundColor: Colors.grey[900],
                  child: (author.imageUrl == null || author.imageUrl!.isEmpty) &&
                         (author.imageFile == null || author.imageFile!.path.isEmpty)
                      ? Icon(Icons.person, size: 32, color: secondaryTextColor)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.pseudo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    if (author.bio.isNotEmpty)
                      Text(
                        author.bio,
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                if (currentUserId != null && currentUserId == tweet.userId)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz, color: secondaryTextColor, size: 22),
                    color: Colors.grey[900],
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            const Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete' && onDeleteTweet != null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: const Text('Supprimer le tweet', style: TextStyle(color: Colors.white)),
                            content: const Text('Êtes-vous sûr de vouloir supprimer ce tweet ?', style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onDeleteTweet!(tweet.id);
                                },
                                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  )
                else
                  Icon(Icons.more_horiz, color: secondaryTextColor, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tweet.content,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
            if (tweet.photo != null && tweet.photo!.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(10),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(
                                    tweet.photo!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[900],
                                      height: 220,
                                      child: const Center(child: Icon(Icons.broken_image)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 32),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    tweet.photo!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 220,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      height: 220,
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.redAccent : secondaryTextColor,
                  ),
                  onPressed: onLike,
                ),
                Text(
                  tweet.likes.toString(),
                  style: TextStyle(
                    color: tweet.likes >= 0 ? textColor : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chat_bubble_outline, color: secondaryTextColor, size: 20),
                // Icône retweet supprimée
              ],
            ),
          ],
        ),
      ),
    );
  }
} 