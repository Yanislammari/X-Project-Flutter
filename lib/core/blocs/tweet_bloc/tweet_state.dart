import 'package:x_project_flutter/core/models/tweet.dart';

abstract class TweetState {}

class TweetInitial extends TweetState {}
class TweetLoading extends TweetState {}
class TweetLoaded extends TweetState {
  final List<Tweet> tweets;
  TweetLoaded(this.tweets);
}
class TweetError extends TweetState {
  final String message;
  TweetError(this.message);
}

class TweetDeleteSuccess extends TweetState {
  final String deletedTweetId;
  TweetDeleteSuccess(this.deletedTweetId);
} 