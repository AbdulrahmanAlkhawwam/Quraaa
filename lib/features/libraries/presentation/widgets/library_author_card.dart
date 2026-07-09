import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../cubit/library_details_state.dart';

/// A card that displays an author inside the library details screen.
class LibraryAuthorCard extends StatelessWidget {
  const LibraryAuthorCard({
    super.key,
    required this.author,
    this.onTap,
  });

  final LibraryAuthorViewModel author;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radius16),
                child: Container(
                  color: AppColors.primary100,
                  child: author.imageUrl.isNotEmpty
                      ? AppImage(
                          author.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing8),
            Text(
              author.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(
        Icons.person_outline,
        color: AppColors.primary600,
        size: 40,
      ),
    );
  }
}
