import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../features/account/data/user_data_local_data_source.dart';
import '../../../../shared/shared.dart';
import '../mock/home_mock_data.dart';
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
  NotificationService? _notificationService;
  int _selectedIndex = 0;
  int _previousIndex = 0;
  final List<RemoteMessage> _notifications = <RemoteMessage>[];
  StreamSubscription<RemoteMessage>? _notificationSub;
  UserDataSnapshot? _userSnapshot;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final UserDataLocalDataSource dataSource = sl<UserDataLocalDataSource>();
    final UserDataSnapshot snapshot = await dataSource.load();
    if (!mounted) return;
    setState(() => _userSnapshot = snapshot);
  }

  String get _firstName {
    final String fullName = _userSnapshot?.fullName ?? '';
    if (fullName.trim().isEmpty) return '';
    return fullName.trim().split(' ').first;
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      _notificationService = sl<NotificationService>();
      await _notificationService!.initialize();
      _notificationSub = _notificationService!.foregroundMessages.listen(
        _onNotificationReceived,
      );
    } catch (e) {
      // Firebase not configured or unavailable – skip silently.
      debugPrint('HomeScreen: notifications unavailable ($e)');
    }
  }

  void _onNotificationReceived(RemoteMessage message) {
    if (!mounted) return;
    setState(() {
      _notifications.add(message);
    });
    context.showSuccessSnackBar(
      message: Message(
        title: message.notification?.title ?? 'New Notification',
        value: message.notification?.body ?? '',
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const HomeDrawer(),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final String firstName = _firstName;
    final String? profileImage = _userSnapshot?.profileImage;
    final bool hasImage = profileImage != null && profileImage.isNotEmpty;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.spacing16,
      title: Row(
        children: <Widget>[
          Text(
            'Hi, ',
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
              border: Border.all(color: AppColors.primary600, width: 2),
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

  Widget _buildBody() {
    final List<Widget> pages = <Widget>[
      const _HomeFeed(),
      const _PlaceholderPage(title: 'Libraries'),
      const _PlaceholderPage(title: 'User Books'),
      const _PlaceholderPage(title: 'Audio Book'),
      const _PlaceholderPage(title: 'Cart'),
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final int currentIndex = (child.key as ValueKey<int>).value;
        final int direction = currentIndex > _previousIndex ? 1 : -1;
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(direction * 0.08, 0),
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
            child: child,
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
/// Uses local mock data only – no server side binding.
class _HomeFeed extends StatelessWidget {
  const _HomeFeed();

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
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing16,
                ),
                child: _HomeSearchBar(
                  onTap: () => context.goTo(RouteNames.search),
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
              child: SizedBox(height: AppSpacing.spacing24),
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
          color: AppColors.primary100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                LocalizationConstants.homeSearchHintKey.tr(),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary600,
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
  const _PlaceholderPage({required this.title});

  final String title;

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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const FlutterLogo(size: 120),
              const SizedBox(height: AppSpacing.spacing24),
              Text(
                'Welcome to $title',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing12),
              const Text(
                'This page is under development.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
