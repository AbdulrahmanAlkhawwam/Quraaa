import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/architecture/result.dart';
import '../domain/book_engagement.dart';

class BookEngagementState extends Equatable {
  const BookEngagementState({
    this.loading = false,
    this.saving = false,
    this.comments = const <BookComment>[],
    this.rating = const BookRatingSummary(average: 0, count: 0),
    this.reasons = const <BookReportReason>[],
    this.myReview,
    this.error,
    this.actionSerial = 0,
  });

  final bool loading;
  final bool saving;
  final List<BookComment> comments;
  final BookRatingSummary rating;
  final List<BookReportReason> reasons;
  final BookComment? myReview;
  final String? error;
  final int actionSerial;

  @override
  List<Object?> get props => <Object?>[
        loading,
        saving,
        comments,
        rating,
        reasons,
        myReview,
        error,
        actionSerial,
      ];
}

class BookEngagementCubit extends Cubit<BookEngagementState> {
  BookEngagementCubit(this._repository, this.bookId)
      : super(const BookEngagementState());

  final BookEngagementRepository _repository;
  final String bookId;

  Future<void> load() async {
    if (bookId.isEmpty) return;
    emit(
      BookEngagementState(
        loading: true,
        comments: state.comments,
        rating: state.rating,
        reasons: state.reasons,
        myReview: state.myReview,
        actionSerial: state.actionSerial,
      ),
    );
    final List<Result<dynamic>> results =
        await Future.wait(<Future<Result<dynamic>>>[
      _repository.getComments(bookId),
      _repository.getRating(bookId),
      _repository.getReportReasons(),
      _repository.getMyReview(bookId),
    ]);
    if (isClosed) return;
    String? error;
    List<BookComment> comments = state.comments;
    BookRatingSummary rating = state.rating;
    List<BookReportReason> reasons = state.reasons;
    BookComment? myReview = state.myReview;
    results[0].fold(
      (failure) => error ??= failure.message,
      (value) => comments = value as List<BookComment>,
    );
    results[1].fold(
      (failure) => error ??= failure.message,
      (value) => rating = value as BookRatingSummary,
    );
    results[2].fold(
      (failure) => error ??= failure.message,
      (value) => reasons = value as List<BookReportReason>,
    );
    results[3].fold(
      (failure) => error ??= failure.message,
      (value) => myReview = value as BookComment?,
    );
    emit(
      BookEngagementState(
        comments: comments,
        rating: rating,
        reasons: reasons,
        myReview: myReview,
        error: error,
        actionSerial: state.actionSerial,
      ),
    );
  }

  Future<void> addReview({required int score, required String comment}) async {
    if (saving) return;
    emit(_saving());
    final Result<void> result = await _repository.addReview(
      bookId,
      score,
      comment.trim(),
    );
    await _finishAndReload(result);
  }

  Future<void> updateComment(BookComment comment, String content) async {
    if (saving || content.trim().isEmpty) return;
    emit(_saving());
    final Result<void> result = await _repository.updateReview(
      bookId,
      comment.score,
      content.trim(),
    );
    await _finishAndReload(result);
  }

  Future<void> deleteComment(BookComment comment) async {
    if (saving) return;
    emit(_saving());
    final Result<void> result = await _repository.deleteReview(bookId);
    await _finishAndReload(result);
  }

  Future<void> _finishAndReload(Result<void> result) async {
    if (isClosed) return;
    String? error;
    result.fold((failure) => error = failure.message, (_) {});
    if (error != null) {
      emit(_done(error: error));
      return;
    }
    emit(_done(success: true));
    await load();
  }

  Future<void> report(BookReportReason reason, String details) async {
    if (saving) return;
    emit(_saving());
    final Result<void> result = await _repository.report(
      bookId,
      reason.value,
      details,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(_done(error: failure.message)),
      (_) => emit(_done(success: true)),
    );
  }

  bool get saving => state.saving;

  BookEngagementState _saving() => BookEngagementState(
        saving: true,
        comments: state.comments,
        rating: state.rating,
        reasons: state.reasons,
        myReview: state.myReview,
        actionSerial: state.actionSerial,
      );

  BookEngagementState _done({String? error, bool success = false}) =>
      BookEngagementState(
        comments: state.comments,
        rating: state.rating,
        reasons: state.reasons,
        myReview: state.myReview,
        error: error,
        actionSerial: state.actionSerial + (success ? 1 : 0),
      );
}
