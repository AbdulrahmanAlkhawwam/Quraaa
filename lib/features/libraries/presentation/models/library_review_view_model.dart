class LibraryReviewViewModel {
  const LibraryReviewViewModel({
    required this.rating,
    required this.comment,
    required this.reviewerName,
    this.reviewerImageUrl = '',
  });

  final int rating;
  final String comment;
  final String reviewerName;
  final String reviewerImageUrl;
}
