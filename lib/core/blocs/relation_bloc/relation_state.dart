part of 'relation_bloc.dart';

enum RelationStatus {
  initial,
  loading,
  success,
  error,
  alreadySent,
  exists,
  notExists,
  actionSuccess,
  actionError,
  statusLoaded,
}

class RelationState {
  final RelationStatus status;
  final String? message;
  final Exception? error;
  final bool? isRelated;
  final bool? hasSentRequest;
  final bool? hasReceivedRequest;
  final bool loading;

  RelationState({
    this.status = RelationStatus.initial,
    this.message,
    this.error,
    this.isRelated,
    this.hasSentRequest,
    this.hasReceivedRequest,
    this.loading = false,
  });

  RelationState copyWith({
    RelationStatus? status,
    String? message,
    Exception? error,
    bool? isRelated,
    bool? hasSentRequest,
    bool? hasReceivedRequest,
    bool? loading,
  }) {
    return RelationState(
      status: status ?? this.status,
      message: message ?? this.message,
      error: error ?? this.error,
      isRelated: isRelated ?? this.isRelated,
      hasSentRequest: hasSentRequest ?? this.hasSentRequest,
      hasReceivedRequest: hasReceivedRequest ?? this.hasReceivedRequest,
      loading: loading ?? this.loading,
    );
  }
} 