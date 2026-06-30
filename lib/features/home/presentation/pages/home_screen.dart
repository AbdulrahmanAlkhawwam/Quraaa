import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../features/account/data/user_data_local_data_source.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/models/message.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/home_drawer.dart';

/// The main home screen that serves as the central hub for the app.
/// Uses a 5-tab bottom navigation with IndexedStack.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotificationService? _notificationService;
  int _selectedIndex = 0;
  int _previousIndex = 0;
  int _notificationCount = 0;
  final List<RemoteMessage> _notifications = <RemoteMessage>[];
  StreamSubscription<RemoteMessage>? _notificationSub;
  bool _notificationsReady = false;
  UserDataSnapshot? _userSnapshot;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final UserDataLocalDataSource dataSource =
        UserDataLocalDataSource(sl<StorageService>());
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
      if (!mounted) return;
      setState(() => _notificationsReady = true);
    } catch (e) {
      // Firebase not configured or unavailable – skip silently.
      debugPrint('HomeScreen: notifications unavailable ($e)');
    }
  }

  void _onNotificationReceived(RemoteMessage message) {
    if (!mounted) return;
    setState(() {
      _notifications.add(message);
      _notificationCount = _notifications.length;
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
  }

  void _openNotifications() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _NotificationsSheet(
        notifications: _notifications,
        onClear: () => setState(() {
          _notifications.clear();
          _notificationCount = 0;
        }),
      ),
    );
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
            style: AppTextStyles.h3.copyWith(color: AppColors.libraryGreen),
          ),
          Text(
            firstName,
            style: AppTextStyles.h3.copyWith(color: AppColors.libraryGreen),
          ),
        ],
      ),
      actions: <Widget>[
        GestureDetector(
          onTap: () => context.goTo(RouteNames.profile),
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
                ? Image.file(
                    File(profileImage),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedUser,
                        color: AppColors.primary600,
                        size: 24,
                      ),
                    ),
                  )
                : Center(
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
      _TestNotificationPage(),
      _PlaceholderPage(title: 'Stores'),
      _PlaceholderPage(title: 'User Books'),
      _PlaceholderPage(title: 'Audio Book'),
      _PlaceholderPage(title: 'Cart'),
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

/// Test page for the notification bottom sheet widget.
class _TestNotificationPage extends StatelessWidget {
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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacing24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const FlutterLogo(size: 120),
                const SizedBox(height: AppSpacing.spacing24),
                Text(
                  'Test Notification Widget',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.onboardingButtonHeight,
                  child: FilledButton.icon(
                    onPressed: () => _showTestNotification(context),
                    icon: const Icon(Icons.notification_add),
                    label: const Text('Show Notification'),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing16),
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.onboardingButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () => _showTestNotificationNoRoute(context),
                    icon: const Icon(Icons.notifications_none),
                    label: const Text('Show Without Button'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTestNotification(BuildContext context) {
    NotificationBottomSheet.show(
      context,
      image: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.primary100,
          borderRadius: BorderRadius.circular(AppRadius.radius20),
        ),
        child: const Center(
          child: Icon(
            Icons.emoji_events,
            size: 72,
            color: AppColors.primary600,
          ),
        ),
      ),
      title: '🎉 Congratulations!',
      body:
          'Amazing progress! You\'ve completed the first level of the Best Reader badge and unlocked the next challenge. Keep reading regularly to earn more achievements and climb to even higher levels.',
      route: RouteNames.profile,
      buttonLabel: 'See my Badges',
    );
  }

  void _showTestNotificationNoRoute(BuildContext context) {
    NotificationBottomSheet.show(
      context,
      title: 'New Update Available',
      body: 'We have added some exciting new features. Check them out in the latest version!',
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

/// Bottom sheet to display received notifications.
class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet({
    required this.notifications,
    required this.onClear,
  });

  final List<RemoteMessage> notifications;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.radius32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spacing20),
            child: Row(
              children: <Widget>[
                HugeIcon(
                  icon: HugeIcons.strokeRoundedNotification01,
                  color: AppColors.libraryGreen,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.spacing12),
                Expanded(
                  child: Text(
                    'Notifications',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (notifications.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      onClear();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.spacing32),
              child: Text(
                'No notifications yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: notifications.length,
                itemBuilder: (BuildContext context, int index) {
                  final RemoteMessage msg = notifications[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AppSpacing.spacing8),
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(AppRadius.radius12),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedNotification01,
                        color: AppColors.primary600,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      msg.notification?.title ?? 'Notification',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      msg.notification?.body ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: AppSpacing.spacing16),
        ],
      ),
    );
  }
}
