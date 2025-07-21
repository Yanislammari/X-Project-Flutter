import 'dart:io';

abstract class TweetEvent {}

class FetchTweets extends TweetEvent {}

class AddTweet extends TweetEvent {
  final String userId;
  final String content;
  final File? imageFile;
  final bool isComment;
  final String? replyToTweetId;
  AddTweet({
    required this.userId,
    required this.content,
    this.imageFile,
    this.isComment = false,
    this.replyToTweetId,
  });
}

class LikeTweet extends TweetEvent {
  final String userId;
  final String tweetId;
  LikeTweet({required this.userId, required this.tweetId});
}

class UnlikeTweet extends TweetEvent {
  final String userId;
  final String tweetId;
  UnlikeTweet({required this.userId, required this.tweetId});
} 