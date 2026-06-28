import 'dart:async';
import 'dart:math' show pi;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../shared/shared.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../widgets/landing_page.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bellController;
  late final Animation<double> _bellAnimation;
  final AuthLocalDataSource _authJourney = sl<AuthLocalDataSource>();
  final NotificationService _notificationService = sl<NotificationService>();

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _bellAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -0.35)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.35, end: 0.35)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.35, end: 0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_bellController);

    _bellController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _bellController.forward(from: 0);
          }
        });
      }
    });

    _bellController.forward();
  }

  @override
  void dispose() {
    _bellController.dispose();
    super.dispose();
  }

  Future<void> _onTakePermission() async {
    await _authJourney.markNotificationPermissionSeen();
    try {
      await _notificationService.requestPermission();
    } catch (_) {
      // Ignore permission errors and proceed.
    }
    if (!mounted) return;
    await _navigateNext(context);
  }

  Future<void> _onMaybeLater() async {
    await _authJourney.markNotificationPermissionSeen();
    if (!mounted) return;
    await _navigateNext(context);
  }

  Future<void> _navigateNext(BuildContext context) async {
    final bool locationSeen = await _authJourney.isLocationPermissionSeen();
    if (!context.mounted) return;
    if (locationSeen) {
      context.goTo(RouteNames.home);
    } else {
      context.goTo(RouteNames.locationPermission);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LandingPage(
      cardColor: AppColors.card,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spacing24,
        AppSpacing.spacing40,
        AppSpacing.spacing24,
        AppSpacing.spacing24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Center(
            child: AnimatedBuilder(
              animation: _bellAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _bellAnimation.value * pi,
                  child: child,
                );
              },
              child: Container(
                width: AppDimensions.permissionIconSize,
                height: AppDimensions.permissionIconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary50,
                  border: Border.all(
                    color: AppColors.primary200,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedNotification01,
                    color: AppColors.primary600,
                    size: AppDimensions.permissionIconInnerSize,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing32),
          Text(
            LocalizationConstants.authNotificationTitleKey.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.libraryGreen,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing16),
          Text(
            LocalizationConstants.authNotificationDescriptionKey.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: AppDimensions.onboardingButtonHeight,
            child: FilledButton(
              onPressed: () => unawaited(_onTakePermission()),
              child: Text(
                LocalizationConstants.authNotificationTakePermissionKey.tr(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing16),
          SizedBox(
            height: AppDimensions.onboardingButtonHeight,
            child: OutlinedButton(
              onPressed: () => unawaited(_onMaybeLater()),
              child: Text(
                LocalizationConstants.authNotificationMaybeLaterKey.tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
