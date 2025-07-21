import 'package:x_project_flutter/core/models/tweet.dart';
import 'firebase_tweet_data_source.dart';

class TweetRepository {
  final FirebaseTweetDataSource tweetDataSource;

  const TweetRepository({required this.tweetDataSource});

  Future<List<Tweet>> fetchTweets() async {
    return await tweetDataSource.fetchTweets();
  }

  Future<Tweet?> fetchTweetById(String id) async {
    return await tweetDataSource.fetchTweetById(id);
  }
} 