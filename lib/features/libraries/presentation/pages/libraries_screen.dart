import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../features/home/presentation/widgets/home_bottom_nav.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/widgets/animated_search_bar.dart';
import '../../domain/entities/library_entity.dart';
import '../cubit/libraries_cubit.dart';

/// The Libraries screen bound to the `/Libraries` paginated endpoint.
class LibrariesScreen extends StatelessWidget {
  const LibrariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LibrariesCubit>(
      create: (_) => sl<LibrariesCubit>()..loadUserSnapshot(),
      child: const _LibrariesView(),
    );
  }
}

class _LibrariesView extends StatelessWidget {
  const _LibrariesView();

  void _onNavItemTapped(BuildContext context, int index) {
    final String route = switch (index) {
      0 => RouteNames.home,
      1 => RouteNames.libraries,
      2 => RouteNames.userBooks,
      3 => RouteNames.audioBooks,
      4 => RouteNames.cart,
      _ => RouteNames.home,
    };

    if (route != RouteNames.libraries) {
      context.goTo(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: const _LibrariesBody(),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: 1,
        onTap: (int index) => _onNavItemTapped(context, index),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final LibrariesState librariesState = context.watch<LibrariesCubit>().state;
    final String firstName = librariesState.firstName;
    final String? profileImage = librariesState.profileImage;
    final bool hasImage = profileImage != null && profileImage.isNotEmpty;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.spacing16,
      title: Row(
        children: <Widget>[
          Text(
            LocalizationConstants.homeGreetingKey.tr(),
            style: AppTextStyles.h3.copyWith(
              fontSize: 22,
              color: AppColors.libraryGreen,
            ),
          ),
          Expanded(
            child: Text(
              firstName,
              style: AppTextStyles.h3.copyWith(
                fontSize: 22,
                color: AppColors.libraryGreen,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        GestureDetector(
          onTap: () => context.goTo(RouteNames.settings),
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsetsDirectional.only(end: AppSpacing.spacing16),
            decoration: BoxDecoration(
              color: AppColors.primary100,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.card, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? AppImage(
                    profileImage,
                    isFile: true,
                    fit: BoxFit.cover,
                    errorWidget: const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUser,
                        color: AppColors.primary600,
                        size: 24,
                      ),
                    ),
                  )
                : const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      color: AppColors.primary600,
                      size: 24,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _LibrariesBody extends StatelessWidget {
  const _LibrariesBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.neutralBackground,
            AppColors.primary50,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing16,
              ),
              child: AnimatedSearchBar(
                suggestions: const <String>[
                  'History',
                  'Mathematics',
                  'Humanity',
                  'Science',
                  'Artificial Intelligence',
                  'Novels',
                  'Programming',
                ],
                onTap: () => context.goTo(RouteNames.search),
                backgroundColor: AppColors.card,
                textColor: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing24),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing16,
              ),
              child: Text(
                LocalizationConstants.homeBestSellersKey.tr(),
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing16),
            const Expanded(
              child: _LibrariesPagedGrid(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibrariesPagedGrid extends StatelessWidget {
  const _LibrariesPagedGrid();

  @override
  Widget build(BuildContext context) {
    final LibrariesCubit cubit = context.watch<LibrariesCubit>();

    return PagedGridView<int, LibraryEntity>(
      pagingController: cubit.state.pagingController,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.spacing16,
        crossAxisSpacing: AppSpacing.spacing16,
        childAspectRatio: 0.75,
      ),
      builderDelegate: PagedChildBuilderDelegate<LibraryEntity>(
        itemBuilder: (BuildContext context, LibraryEntity library, int index) {
          return _LibraryCard(library: library);
        },
        firstPageErrorIndicatorBuilder: (_) => _ErrorIndicator(
          message: cubit.state.errorMessage ??
              LocalizationConstants.errorsNoInternetMessageKey.tr(),
          onRetry: cubit.state.pagingController.retryLastFailedRequest,
        ),
        newPageErrorIndicatorBuilder: (_) => _ErrorIndicator(
          message: cubit.state.errorMessage ??
              LocalizationConstants.errorsNoInternetMessageKey.tr(),
          onRetry: cubit.state.pagingController.retryLastFailedRequest,
        ),
        firstPageProgressIndicatorBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        newPageProgressIndicatorBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        noItemsFoundIndicatorBuilder: (_) => const _EmptyIndicator(),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.library});

  final LibraryEntity library;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushTo(
        '/libraries/${library.id}',
        extra: library,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.radius16),
          boxShadow: AppShadows.elevation1,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: AppImage(
                library.libraryImage.isNotEmpty
                    ? library.libraryImage
                    : library.headerImage,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: AppColors.primary100,
                  child: const Center(
                    child: Icon(
                      Icons.store_outlined,
                      color: AppColors.primary600,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    library.libraryName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.spacing4),
                  Text(
                    library.location,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.spacing4),
                  Text(
                    library.email,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorIndicator extends StatelessWidget {
  const _ErrorIndicator({required this.message, required this.onRetry});

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
                color: AppColors.textSecondary,
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

class _EmptyIndicator extends StatelessWidget {
  const _EmptyIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing24),
        child: Text(
          LocalizationConstants.explorerEmptyMessageKey.tr(),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
