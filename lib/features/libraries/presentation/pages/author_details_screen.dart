import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/author_entity.dart';
import '../cubit/author_details_cubit.dart';

class AuthorDetailsScreen extends StatelessWidget {
  const AuthorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.appCard,
        body: SafeArea(
          child: BlocBuilder<AuthorDetailsCubit, AuthorDetailsState>(
            builder: (BuildContext context, AuthorDetailsState state) {
              if (state.loading && state.author == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.author == null) {
                return _ErrorView(
                  message: state.error ??
                      LocalizationConstants.errorsUnknownMessageKey.tr(),
                  onRetry: context.read<AuthorDetailsCubit>().load,
                );
              }
              return _AuthorContent(state: state);
            },
          ),
        ),
      ),
    );
  }
}

class _AuthorContent extends StatelessWidget {
  const _AuthorContent({required this.state});

  final AuthorDetailsState state;

  @override
  Widget build(BuildContext context) {
    final AuthorEntity author = state.author!;
    final String description = author.bio?.trim().isNotEmpty == true
        ? author.bio!.trim()
        : LocalizationConstants.libraryDetailsDefaultDescriptionKey.tr();
    return RefreshIndicator(
      onRefresh: context.read<AuthorDetailsCubit>().load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: AppSpacing.spacing24),
        children: <Widget>[
          _BackHeader(onBack: context.back),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: AppSpacing.spacing16),
                _AuthorIdentity(author: author),
                const SizedBox(height: AppSpacing.spacing20),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.appTextSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing24),
                Text(
                  LocalizationConstants.libraryAuthorWorksKey.tr(),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: context.isDark
                        ? AppColors.primary300
                        : AppColors.libraryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spacing12),
          _AuthorWorks(works: state.books),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spacing20),
              child: Text(
                state.error!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BackHeader extends StatelessWidget {
  const _BackHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding:
              const EdgeInsetsDirectional.only(start: AppSpacing.spacing20),
          child: IconButton(
            onPressed: onBack,
            icon: HugeIcon(
              icon: context.isRTL
                  ? HugeIcons.strokeRoundedArrowRight01
                  : HugeIcons.strokeRoundedArrowLeft01,
              color: context.isDark
                  ? AppColors.primary300
                  : AppColors.libraryGreen,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorIdentity extends StatelessWidget {
  const _AuthorIdentity({required this.author});

  final AuthorEntity author;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = author.photoUrl?.trim() ?? '';
    return Row(
      children: <Widget>[
        ClipOval(
          child: SizedBox(
            width: 76,
            height: 76,
            child: imageUrl.isEmpty
                ? _placeholder(context)
                : AppImage(
                    imageUrl,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorWidget: _placeholder(context),
                  ),
          ),
        ),
        const SizedBox(width: AppSpacing.spacing12),
        Expanded(
          child: Text(
            author.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleLarge.copyWith(
              color: context.isDark
                  ? AppColors.primary300
                  : AppColors.libraryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) => ColoredBox(
        color: context.appSubtleSurface,
        child: Icon(
          Icons.person_outline,
          size: 40,
          color: context.isDark ? AppColors.primary300 : AppColors.primary600,
        ),
      );
}

class _AuthorWorks extends StatelessWidget {
  const _AuthorWorks({required this.works});

  final List<AuthorBookEntity> works;

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing20),
        child: Text(
          LocalizationConstants.explorerEmptyMessageKey.tr(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.appTextSecondary,
          ),
        ),
      );
    }
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing20),
        itemCount: works.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.spacing14),
        itemBuilder: (BuildContext context, int index) {
          final AuthorBookEntity book = works[index];
          return SizedBox(
            width: 116,
            child: InkWell(
              onTap: () => context.pushTo(
                RouteNames.bookDetailsPath(book.listingId),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.radius4),
                      child: SizedBox(
                        width: 64,
                        height: 96,
                        child: book.coverImageUrl.isEmpty
                            ? const ColoredBox(
                                color: AppColors.primary100,
                                child: Icon(Icons.book_outlined),
                              )
                            : AppImage(
                                book.coverImageUrl,
                                width: 64,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing8),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.appTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _BackHeader(onBack: context.back),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spacing24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.spacing16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(LocalizationConstants.commonRetryKey.tr()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
