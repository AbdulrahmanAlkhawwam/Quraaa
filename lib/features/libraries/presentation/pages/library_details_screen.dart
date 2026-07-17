import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/library_entity.dart';
import '../cubit/library_details_cubit.dart';
import '../cubit/library_details_state.dart';
import '../widgets/library_author_card.dart';
import '../widgets/library_book_card.dart';
import '../widgets/library_info_header.dart';

/// Library details screen bound to `/Libraries/{libraryId}/books`.
class LibraryDetailsScreen extends StatelessWidget {
  const LibraryDetailsScreen({
    super.key,
    this.library,
  });

  final LibraryEntity? library;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: const _LibraryDetailsView(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowLeft01,
          color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
          size: 28,
        ),
        onPressed: () => context.back(),
      ),
      title: Text(
        library?.libraryName ??
            LocalizationConstants.libraryDetailsTitleKey.tr(),
        style: AppTextStyles.appBarTitle.copyWith(
          color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedStar,
            color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
            size: 28,
          ),
          onPressed: () {
            // TODO: toggle favorite
          },
        ),
      ],
    );
  }
}

class _LibraryDetailsView extends StatefulWidget {
  const _LibraryDetailsView();

  @override
  State<_LibraryDetailsView> createState() => _LibraryDetailsViewState();
}

class _LibraryDetailsViewState extends State<_LibraryDetailsView> {
  @override
  void initState() {
    super.initState();
    context.read<LibraryDetailsCubit>().loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    final LibraryEntity? library =
        context.findAncestorWidgetOfExactType<LibraryDetailsScreen>()?.library;

    final List<Color> backgroundColors = context.isDark
        ? <Color>[AppColors.neutralBackgroundDark, AppColors.surfaceDark]
        : <Color>[AppColors.neutralBackground, AppColors.primary50];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: backgroundColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: BlocBuilder<LibraryDetailsCubit, LibraryDetailsState>(
          builder: (BuildContext context, LibraryDetailsState state) {
            if (state.status == LibraryDetailsStatus.initial ||
                (state.status == LibraryDetailsStatus.loading &&
                    state.books.isEmpty)) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == LibraryDetailsStatus.error &&
                state.books.isEmpty) {
              return _ErrorView(
                message: state.errorMessage ??
                    LocalizationConstants.errorsUnknownMessageKey.tr(),
                onRetry: () =>
                    context.read<LibraryDetailsCubit>().loadBooks(),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: AppSpacing.spacing16,
                bottom: AppSpacing.spacing32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (library != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing16,
                      ),
                      child: LibraryInfoHeader(library: library),
                    ),
                  const SizedBox(height: AppSpacing.spacing24),
                  if (state.authors.isNotEmpty) ...<Widget>[
                    _SectionTitle(
                      title: LocalizationConstants.libraryDetailsAuthorsKey.tr(),
                    ),
                    const SizedBox(height: AppSpacing.spacing12),
                    SizedBox(
                      height: 170,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacing16,
                        ),
                        itemCount: state.authors.length,
                        separatorBuilder: (_, _) => const SizedBox(
                          width: AppSpacing.spacing16,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return LibraryAuthorCard(
                            author: state.authors[index],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing24),
                  ],
                  _SectionTitle(
                    title: LocalizationConstants.libraryDetailsRecentlyAddedKey
                        .tr(),
                  ),
                  const SizedBox(height: AppSpacing.spacing12),
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing16,
                      ),
                      itemCount: state.books.length,
                      separatorBuilder: (_, _) => const SizedBox(
                        width: AppSpacing.spacing16,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return LibraryDetailsBookCard(
                          book: state.books[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: context.appTextPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.appTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(LocalizationConstants.commonRetryKey.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
