import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../bloc/home_bloc.dart';
import '../mock/home_mock_data.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_banner.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_section.dart';

/// The main home screen that serves as the central hub for the app.
/// Uses a 5-tab bottom navigation with an IndexedStack.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });

    final String route = switch (index) {
      0 => RouteNames.home,
      1 => RouteNames.libraries,
      2 => RouteNames.userBooks,
      3 => RouteNames.audioBooks,
      4 => RouteNames.cart,
      _ => RouteNames.home,
    };

    if (route != RouteNames.home) {
      context.goTo(route);
    }
  }

  void _showNotificationSnackBar(BuildContext context, HomeState state) {
    context.showSuccessSnackBar(
      message: Message(
        title: state.notificationTitle ??
            LocalizationConstants.homeNotificationTitleKey.tr(),
        value: state.notificationBody,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (HomeState previous, HomeState current) =>
          previous.notificationSerial != current.notificationSerial,
      listener: _showNotificationSnackBar,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        drawer: const HomeDrawer(),
        appBar: _buildAppBar(),
        body: Stack(
          children: <Widget>[
            _buildBody(),
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,
              child: HomeBottomNav(
                currentIndex: _selectedIndex,
                onTap: _onNavItemTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final HomeState homeState = context.watch<HomeBloc>().state;
    return HomeAppBar(
      firstName: homeState.firstName,
      profileImage: homeState.profileImage,
      profileImageIsFile: true,
    );
  }

  Widget _buildBody() {
    final List<Widget> pages = <Widget>[
      const _HomeFeed(),
      const _PlaceholderPage(titleKey: LocalizationConstants.homeNavLibrariesKey),
      const _PlaceholderPage(titleKey: LocalizationConstants.homeNavUserBooksKey),
      const _PlaceholderPage(titleKey: LocalizationConstants.homeNavAudioBookKey),
      const _PlaceholderPage(titleKey: LocalizationConstants.homeNavCartKey),
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      reverseDuration: const Duration(milliseconds: 260),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final int currentIndex = (child.key as ValueKey<int>).value;
        final int direction = currentIndex > _previousIndex ? 1 : -1;
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(direction * 0.10, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1).animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(_selectedIndex),
        child: pages[_selectedIndex],
      ),
    );
  }
}

/// The main home feed matching the design in img_1.png.
/// Uses local mock data only - no server side binding.
class _HomeFeed extends StatelessWidget {
  const _HomeFeed();

  @override
  Widget build(BuildContext context) {
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
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing16,
                ),
                child: _HomeSearchBar(
                  onTap: () => context.pushTo(RouteNames.search),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.spacing24),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
                child: HomeBanner(),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.spacing32),
            ),
            SliverToBoxAdapter(
              child: HomeSection(
                title: LocalizationConstants.homeRecommendedForYouKey.tr(),
                totalSize: '3.5 KB',
                books: recommendedBooks,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.spacing24),
            ),
            SliverToBoxAdapter(
              child: HomeSection(
                title: LocalizationConstants.homeNoteKey.tr(),
                totalSize: '3.5 KB',
                books: noteBooks,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.spacing24),
            ),
            SliverToBoxAdapter(
              child: HomeSection(
                title: LocalizationConstants.homeNoteKey.tr(),
                totalSize: '3.5 KB',
                books: noteBooks,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 128),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple pill-shaped search bar used on the home feed.
class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing18),
        decoration: BoxDecoration(
          color: context.appSubtleSurface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                LocalizationConstants.homeSearchHintKey.tr(),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: context.isDark ? AppColors.primary300 : AppColors.primary600,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.search,
              color: AppColors.primary600,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple placeholder page for tabs that are not yet implemented.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.titleKey});

  final String titleKey;

  @override
  Widget build(BuildContext context) {
    final String title = titleKey.tr();
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const FlutterLogo(size: 120),
              const SizedBox(height: AppSpacing.spacing24),
              Text(
                LocalizationConstants.homeFeatureWelcomeToKey.tr(
                  namedArgs: <String, String>{'title': title},
                ),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.appTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing12),
              Text(
                LocalizationConstants.homeFeatureUnderDevelopmentKey.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.appTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
