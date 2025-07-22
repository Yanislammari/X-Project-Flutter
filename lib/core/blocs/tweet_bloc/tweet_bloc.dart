import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/models/tweet.dart';
import 'package:x_project_flutter/core/repositories/tweet/tweet_repository.dart';
import 'tweet_event.dart';
import 'tweet_state.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../repositories/tweet/like_repository.dart';
import '../../models/notification.dart';
import '../../repositories/notification/notification_repository.dart';
import '../../repositories/user_data/user_repository.dart';
import '../../repositories/user_data/firebase_user_data_source.dart';

class TweetBloc extends Bloc<TweetEvent, TweetState> {
  final TweetRepository tweetRepository;
  final LikeRepository likeRepository = LikeRepository();

  TweetBloc({required this.tweetRepository}) : super(TweetInitial()) {
    on<FetchTweets>(_onFetchTweets);
    on<AddTweet>(_onAddTweet);
    on<LikeTweet>(_onLikeTweet);
    on<UnlikeTweet>(_onUnlikeTweet);
    on<DeleteTweet>(_onDeleteTweet);
  }

  Future<void> _onFetchTweets(FetchTweets event, Emitter<TweetState> emit) async {
    emit(TweetLoading());
    try {
      final tweets = await tweetRepository.fetchTweets();
      emit(TweetLoaded(tweets));
    } catch (e) {
      emit(TweetError('Erreur lors du chargement des tweets'));
    }
  }

  Future<void> _onAddTweet(AddTweet event, Emitter<TweetState> emit) async {
    try {
      String? imageUrl;
      if (event.imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('tweet_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(event.imageFile!);
        imageUrl = await ref.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection('tweets').add({
        'userId': event.userId,
        'content': event.content,
        'photo': imageUrl,
        'likes': 0,
        'created_at': FieldValue.serverTimestamp(),
        'isComment': event.isComment,
        'replyToTweetId': event.replyToTweetId,
      });
      add(FetchTweets());
    } catch (e) {
      emit(TweetError('Erreur lors de l\'ajout du tweet : $e'));
    }
  }

  Future<void> _onLikeTweet(LikeTweet event, Emitter<TweetState> emit) async {
    try {
      await likeRepository.addLike(userId: event.userId, tweetId: event.tweetId);
      final tweet = await tweetRepository.fetchTweetById(event.tweetId);
      if (tweet != null && tweet.userId != event.userId) {
        final notif = AppNotification(
          id: '',
          type: NotificationType.LikeReceived,
          likeId: tweet.id,
          askingRelationId: null,
          userId: event.userId,
          toUserId: tweet.userId,
          timestamp: DateTime.now(),
        );
        await NotificationRepository().addNotification(notif);
        print('[DEBUG][NOTIF] Notification LikeReceived créée pour ${tweet.userId}');
      }
    } catch (e) {
    }
  }

  Future<void> _onUnlikeTweet(UnlikeTweet event, Emitter<TweetState> emit) async {
    try {
      await likeRepository.removeLike(userId: event.userId, tweetId: event.tweetId);
    } catch (e) {
    }
  }

  Future<void> _onDeleteTweet(DeleteTweet event, Emitter<TweetState> emit) async {
    try {
      await tweetRepository.deleteTweet(event.tweetId);
      emit(TweetDeleteSuccess(event.tweetId));
    } catch (e) {
      emit(TweetError('Erreur lors de la suppression du tweet : $e'));
    }
  }
} 