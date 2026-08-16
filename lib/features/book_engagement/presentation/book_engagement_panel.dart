import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/error_monitoring/user_context_provider.dart';
import '../../../shared/shared.dart';
import '../domain/book_engagement.dart';
import 'book_engagement_cubit.dart';

class BookEngagementPanel extends StatefulWidget {
  const BookEngagementPanel({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookEngagementPanel> createState() => _BookEngagementPanelState();
}

class _BookEngagementPanelState extends State<BookEngagementPanel> {
  final String _currentUserId = sl<UserContextProvider>().snapshot.userId ?? '';
  late final BookEngagementCubit _cubit = BookEngagementCubit(
    sl<BookEngagementRepository>(),
    widget.bookId,
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookEngagementCubit, BookEngagementState>(
      bloc: _cubit,
      listenWhen: (previous, current) =>
          previous.error != current.error ||
          previous.actionSerial != current.actionSerial,
      listener: (BuildContext context, BookEngagementState state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        } else if (state.actionSerial > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('book_engagement.saved'.tr())),
          );
        }
      },
      builder: (BuildContext context, BookEngagementState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'book_engagement.reviews'.tr(),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: context.appTextPrimary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'book_engagement.report'.tr(),
                  onPressed: state.saving || state.reasons.isEmpty
                      ? null
                      : () => _showReport(state.reasons),
                  icon: const Icon(Icons.flag_outlined),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                ...List<Widget>.generate(
                  5,
                  (int index) => Icon(
                    index < state.rating.average.round()
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xFFFFC400),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${state.rating.average.toStringAsFixed(1)} '
                  '(${state.rating.count})',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.appTextSecondary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: state.saving ? null : _showReview,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: Text('book_engagement.add_review'.tr()),
                ),
              ],
            ),
            if (state.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.comments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'book_engagement.empty'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.appTextSecondary,
                  ),
                ),
              )
            else
              ...state.comments.take(5).map(
                    (BookComment comment) => _CommentCard(
                      comment: comment,
                      editable: _currentUserId.isNotEmpty &&
                          comment.userId == _currentUserId,
                      onEdit: () => _editComment(comment),
                      onDelete: () => _deleteComment(comment),
                    ),
                  ),
          ],
        );
      },
    );
  }

  Future<void> _showReview() async {
    String commentText = '';
    int score = 5;
    final bool? submit = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => AlertDialog(
          title: Text('book_engagement.add_review'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  5,
                  (int index) => IconButton(
                    onPressed: () => setState(() => score = index + 1),
                    icon: Icon(
                      index < score ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFC400),
                    ),
                  ),
                ),
              ),
              TextFormField(
                maxLines: 3,
                onChanged: (String value) => commentText = value,
                decoration: InputDecoration(
                  hintText: 'book_engagement.comment_hint'.tr(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('common.save'.tr()),
            ),
          ],
        ),
      ),
    );
    if (submit == true) {
      await _cubit.addReview(score: score, comment: commentText);
    }
  }

  Future<void> _editComment(BookComment comment) async {
    String content = comment.content;
    final bool? save = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('book_engagement.edit_comment'.tr()),
        content: TextFormField(
          initialValue: content,
          onChanged: (String value) => content = value,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'book_engagement.comment_hint'.tr(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('common.save'.tr()),
          ),
        ],
      ),
    );
    final String normalized = content.trim();
    if (save == true && normalized.isNotEmpty) {
      await _cubit.updateComment(comment, normalized);
    }
  }

  Future<void> _deleteComment(BookComment comment) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('book_engagement.delete_comment'.tr()),
        content: Text('book_engagement.delete_comment_confirm'.tr()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('book_engagement.delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true) await _cubit.deleteComment(comment);
  }

  Future<void> _showReport(List<BookReportReason> reasons) async {
    BookReportReason selected = reasons.first;
    String details = '';
    final bool? submit = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => AlertDialog(
          title: Text('book_engagement.report'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<BookReportReason>(
                initialValue: selected,
                items: reasons
                    .map(
                      (BookReportReason reason) => DropdownMenuItem(
                        value: reason,
                        child: Text(
                          context.locale.languageCode == 'ar'
                              ? reason.nameAr
                              : reason.nameEn,
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (BookReportReason? value) {
                  if (value != null) setState(() => selected = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 3,
                onChanged: (String value) => details = value,
                decoration: InputDecoration(
                  hintText: 'book_engagement.report_details'.tr(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('book_engagement.send'.tr()),
            ),
          ],
        ),
      ),
    );
    if (submit == true) await _cubit.report(selected, details);
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({
    required this.comment,
    required this.editable,
    required this.onEdit,
    required this.onDelete,
  });

  final BookComment comment;
  final bool editable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appSubtleSurface,
        borderRadius: BorderRadius.circular(AppRadius.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  comment.name.isEmpty
                      ? 'book_engagement.reader'.tr()
                      : comment.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.appTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (editable)
                PopupMenuButton<String>(
                  onSelected: (String value) =>
                      value == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('book_engagement.edit_comment'.tr()),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('book_engagement.delete_comment'.tr()),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.appTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
