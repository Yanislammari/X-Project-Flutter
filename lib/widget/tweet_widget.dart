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
    return Container(
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
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: author.imageUrl != null && author.imageUrl!.isNotEmpty
                ? NetworkImage(author.imageUrl!)
                : (author.imageFile != null && author.imageFile!.path.isNotEmpty
                    ? FileImage(author.imageFile!)
                    : null),
            backgroundColor: const Color(0xFF536471),
            child: (author.imageUrl == null || author.imageUrl!.isEmpty) &&
                   (author.imageFile == null || author.imageFile!.path.isEmpty)
                ? const Icon(Icons.person, size: 24, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and menu
                Row(
                  children: [
                    Text(
                      author.pseudo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '@${author.pseudo.toLowerCase()}',
                      style: const TextStyle(
                        color: Color(0xFF71767B),
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (currentUserId != null && currentUserId == tweet.userId)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Color(0xFF71767B),
                          size: 20,
                        ),
                        color: const Color(0xFF1E1E1E),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline, color: Color(0xFFF4212E), size: 18),
                                const SizedBox(width: 12),
                                const Text(
                                  'Supprimer',
                                  style: TextStyle(color: Color(0xFFF4212E), fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'delete' && onDeleteTweet != null) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1E1E1E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  'Supprimer le Tweet ?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                content: const Text(
                                  'Cette action ne peut pas être annulée et votre Tweet sera supprimé de votre profil.',
                                  style: TextStyle(
                                    color: Color(0xFF71767B),
                                    fontSize: 15,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(color: Color(0xFF536471)),
                                      ),
                                    ),
                                    child: const Text(
                                      'Annuler',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      onDeleteTweet!(tweet.id);
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFFF4212E),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Supprimer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Tweet content
                Text(
                  tweet.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
                // Image if exists
                if (tweet.photo != null && tweet.photo!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(0),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  color: Colors.black87,
                                  child: Center(
                                    child: InteractiveViewer(
                                      child: Image.network(
                                        tweet.photo!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: const Color(0xFF1E1E1E),
                                          height: 300,
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              color: Color(0xFF71767B),
                                              size: 64,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                left: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2F3336),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          tweet.photo!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 250,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF1E1E1E),
                            height: 250,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF71767B),
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Actions bar
                Row(
                  children: [
                    // Comment button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: const Color(0xFF71767B),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Like button
                    GestureDetector(
                      onTap: onLike,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? const Color(0xFFF91880) : const Color(0xFF71767B),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tweet.likes.toString(),
                              style: TextStyle(
                                color: isLiked ? const Color(0xFFF91880) : const Color(0xFF71767B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Share button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.share_outlined,
                        color: Color(0xFF71767B),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 