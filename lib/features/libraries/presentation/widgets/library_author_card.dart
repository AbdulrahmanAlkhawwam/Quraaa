import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../cubit/library_details_state.dart';

/// An author image card with the text overlay used in the design.
class LibraryAuthorCard extends StatelessWidget {
  const LibraryAuthorCard({super.key, required this.author, this.onTap});

  final LibraryAuthorViewModel author;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 182,
      height: 190,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radius10),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ColoredBox(
                color: context.appSubtleSurface,
                child: author.imageUrl.isNotEmpty
                    ? AppImage(
                        author.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: _placeholder(context),
                      )
                    : _placeholder(context),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Color(0x12000000),
                      Color(0xD9000000),
                    ],
                    stops: <double>[0.42, 0.64, 1],
                  ),
                ),
              ),
              PositionedDirectional(
                start: AppSpacing.spacing14,
                end: AppSpacing.spacing10,
                bottom: AppSpacing.spacing12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (author.subtitle.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.spacing4),
                      Text(
                        author.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary300,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.person_outline,
        color: context.isDark ? AppColors.primary300 : AppColors.primary600,
        size: 48,
      ),
    );
  }
}
