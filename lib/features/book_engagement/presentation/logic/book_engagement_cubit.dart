import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/book_comment.dart';
import '../../domain/entities/book_rating_summary.dart';
import '../../domain/entities/book_report_reason.dart';
import '../../domain/use_cases/add_book_review_use_case.dart';
import '../../domain/use_cases/delete_book_review_use_case.dart';
import '../../domain/use_cases/get_book_comments_use_case.dart';
import '../../domain/use_cases/get_book_rating_use_case.dart';
import '../../domain/use_cases/get_book_report_reasons_use_case.dart';
import '../../domain/use_cases/get_my_book_review_use_case.dart';
import '../../domain/use_cases/report_book_use_case.dart';
import '../../domain/use_cases/update_book_review_use_case.dart';

class BookEngagementState extends Equatable {
  const BookEngagementState({
    this.loading = false,
    this.saving = false,
    this.comments = const <BookComment>[],
    this.rating = BookRatingSummary.empty,
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
  BookEngagementCubit({
    required this.bookId,
    required this._getComments,
    required this._getRating,
    required this._getReportReasons,
    required this._getMyReview,
    required this._addReview,
    required this._updateReview,
    required this._deleteReview,
    required this._reportBook,
  }) : super(const BookEngagementState());

  final String bookId;
  final GetBookCommentsUseCase _getComments;
  final GetBookRatingUseCase _getRating;
  final GetBookReportReasonsUseCase _getReportReasons;
  final GetMyBookReviewUseCase _getMyReview;
  final AddBookReviewUseCase _addReview;
  final UpdateBookReviewUseCase _updateReview;
  final DeleteBookReviewUseCase _deleteReview;
  final ReportBookUseCase _reportBook;

  /// Loads everything in parallel. Each part that fails keeps its previous
  /// value; the first failure's message is surfaced.
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
    final (
      Either<Failure, List<BookComment>> comments,
      Either<Failure, BookRatingSummary> rating,
      Either<Failure, List<BookReportReason>> reasons,
      Either<Failure, BookComment?> myReview,
    ) = await (
      _getComments(bookId),
      _getRating(bookId),
      _getReportReasons(),
      _getMyReview(bookId),
    ).wait;
    if (isClosed) return;
    final String? error = <Failure?>[
      comments.getLeft().toNullable(),
      rating.getLeft().toNullable(),
      reasons.getLeft().toNullable(),
      myReview.getLeft().toNullable(),
    ].nonNulls.firstOrNull?.message;
    emit(
      BookEngagementState(
        comments: comments.getOrElse((_) => state.comments),
        rating: rating.getOrElse((_) => state.rating),
        reasons: reasons.getOrElse((_) => state.reasons),
        myReview: myReview.getOrElse((_) => state.myReview),
        error: error,
        actionSerial: state.actionSerial,
      ),
    );
  }

  Future<void> addReview({required int score, required String comment}) async {
    if (saving) return;
    emit(_saving());
    await _finishAndReload(
      await _addReview(
        BookReviewParams(bookId: bookId, score: score, content: comment.trim()),
      ),
    );
  }

  Future<void> updateComment(BookComment comment, String content) async {
    if (saving || content.trim().isEmpty) return;
    emit(_saving());
    await _finishAndReload(
      await _updateReview(
        BookReviewParams(
          bookId: bookId,
          score: comment.score,
          content: content.trim(),
        ),
      ),
    );
  }

  Future<void> deleteComment(BookComment comment) async {
    if (saving) return;
    emit(_saving());
    await _finishAndReload(await _deleteReview(bookId));
  }

  Future<void> _finishAndReload(Either<Failure, Unit> result) async {
    if (isClosed) return;
    final Failure? failure = result.getLeft().toNullable();
    if (failure != null) {
      emit(_done(error: failure.message));
      return;
    }
    emit(_done(success: true));
    await load();
  }

  Future<void> report(BookReportReason reason, String details) async {
    if (saving) return;
    emit(_saving());
    final Either<Failure, Unit> result = await _reportBook(
      ReportBookParams(bookId: bookId, reason: reason.value, details: details),
    );
    if (isClosed) return;
    emit(
      result.fold(
        (Failure failure) => _done(error: failure.message),
        (_) => _done(success: true),
      ),
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
