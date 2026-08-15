import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/assistant_book.dart';
import '../../domain/entities/assistant_response.dart';

class AssistantAnswerCard extends StatelessWidget {
  const AssistantAnswerCard({
    required this.response,
    required this.scale,
    super.key,
  });

  final AssistantResponse response;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final AssistantBook? book =
        response.books.isEmpty ? null : response.books.first;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: context.appSubtleSurface,
        borderRadius: BorderRadius.circular(22 * scale),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (book != null) ...<Widget>[
            Container(
              padding: EdgeInsets.all(8 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4 * scale),
                    child: AppImage(
                      book.coverUrl,
                      width: 72 * scale,
                      height: 96 * scale,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        width: 72 * scale,
                        height: 96 * scale,
                        color: context.appSubtleSurface,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.menu_book_outlined,
                          color: AppColors.primary600,
                          size: 28 * scale,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.primary900,
                            fontSize: 20 * scale,
                            height: 1.1,
                          ),
                        ),
                        if (book.author.trim().isNotEmpty) ...<Widget>[
                          SizedBox(height: 5 * scale),
                          Text(
                            book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary700,
                              fontSize: 12 * scale,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.bookmark_border,
                    color: AppColors.primary900,
                    size: 18 * scale,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * scale),
          ],
          Text(
            response.answer,
            textAlign: TextAlign.start,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.appTextPrimary,
              fontSize: 14 * scale,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
