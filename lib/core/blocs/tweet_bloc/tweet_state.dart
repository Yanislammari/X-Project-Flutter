part of 'tweet_bloc.dart';

enum TweetStatus {
  initial,
  loading,
  loaded,
  error,
}

class TweetState {
  final TweetStatus status;
  final String? message;
  final List<Tweet>? tweets;
  final Exception? error;

  TweetState({
    this.status = TweetStatus.initial,
    this.message,
    this.tweets,
    this.error,
  });

  TweetState copyWith({
    TweetStatus? status,
    String? message,
    List<Tweet>? tweets,
    Exception? error,
  }) {
    return TweetState(
      status: status ?? this.status,
      message: message ?? this.message,
      tweets: tweets ?? this.tweets,
      error: error ?? this.error,
    );
  }
} 