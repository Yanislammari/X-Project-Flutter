import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:x_project_flutter/core/models/tweet.dart';
import 'package:x_project_flutter/core/repositories/tweet/tweet_repository.dart';
import 'tweet_event.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../repositories/tweet/like_repository.dart';
import '../../models/notification.dart';
import '../../repositories/notification/notification_repository.dart';

part 'tweet_state.dart';

class TweetBloc extends Bloc<TweetEvent, TweetState> {
  final TweetRepository tweetRepository;
  final LikeRepository _likeRepository = LikeRepository();
  final NotificationRepository _notificationRepository = NotificationRepository();

  TweetBloc({required this.tweetRepository}) : super(TweetState()) {
    on<FetchTweets>(_onFetchTweets);
    on<AddTweet>(_onAddTweet);
    on<LikeTweet>(_onLikeTweet);
    on<UnlikeTweet>(_onUnlikeTweet);
    on<DeleteTweet>(_onDeleteTweet);
  }

  Future<void> _onFetchTweets(FetchTweets event, Emitter<TweetState> emit) async {
    emit(state.copyWith(status: TweetStatus.loading));
    try {
      final tweets = await tweetRepository.fetchTweets();
      emit(state.copyWith(status: TweetStatus.loaded, tweets: tweets));
    } catch (e) {
      emit(state.copyWith(status: TweetStatus.error, message: 'Erreur lors du chargement des tweets : $e'));
    }
  }

  Future<void> _onAddTweet(AddTweet event, Emitter<TweetState> emit) async {
    try {
      String? imageUrl;
      
      if (event.imageFile != null) {
        imageUrl = await _uploadImage(event.imageFile!);
      }
      
      await _createTweetDocument(
        userId: event.userId,
        content: event.content,
        imageUrl: imageUrl,
        isComment: event.isComment,
        replyToTweetId: event.replyToTweetId,
      );
      
      add(FetchTweets());
    } catch (e) {
      emit(state.copyWith(status: TweetStatus.error, message: 'Erreur lors de l\'ajout du tweet : $e'));
    }
  }

  Future<void> _onLikeTweet(LikeTweet event, Emitter<TweetState> emit) async {
    try {
      await _likeRepository.addLike(userId: event.userId, tweetId: event.tweetId);
      await _createLikeNotification(event.userId, event.tweetId);
    } catch (e) {
      print('Erreur lors du like : $e');
    }
  }

  Future<void> _onUnlikeTweet(UnlikeTweet event, Emitter<TweetState> emit) async {
    try {
      await _likeRepository.removeLike(userId: event.userId, tweetId: event.tweetId);
    } catch (e) {
      print('Erreur lors du unlike : $e');
    }
  }

  Future<void> _onDeleteTweet(DeleteTweet event, Emitter<TweetState> emit) async {
    try {
      await tweetRepository.deleteTweet(event.tweetId);
      
      final tweets = await tweetRepository.fetchTweets();
      emit(state.copyWith(status: TweetStatus.loaded, tweets: tweets));
    } catch (e) {
      emit(state.copyWith(status: TweetStatus.error, message: 'Erreur lors de la suppression du tweet : $e'));
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('tweet_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> _createTweetDocument({
    required String userId,
    required String content,
    String? imageUrl,
    bool isComment = false,
    String? replyToTweetId,
  }) async {
    await FirebaseFirestore.instance.collection('tweets').add({
      'userId': userId,
      'content': content,
      'photo': imageUrl,
      'likes': 0,
      'created_at': FieldValue.serverTimestamp(),
      'isComment': isComment,
      'replyToTweetId': replyToTweetId,
    });
  }

  Future<void> _createLikeNotification(String userId, String tweetId) async {
    try {
      final tweet = await tweetRepository.fetchTweetById(tweetId);
      
      if (tweet != null && tweet.userId != userId) {
        final notif = AppNotification(
          id: '',
          type: NotificationType.LikeReceived,
          likeId: tweet.id,
          askingRelationId: null,
          userId: userId,
          toUserId: tweet.userId,
          timestamp: DateTime.now(),
        );
        
        await _notificationRepository.addNotification(notif);
      }
    } catch (e) {
      print('Erreur lors de la création de la notification : $e');
    }
  }
} 