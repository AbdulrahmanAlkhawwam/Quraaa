import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../widgets/landing_page.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  final AuthLocalDataSource _authJourney = sl<AuthLocalDataSource>();

  Future<void> _onOnlyWhenUseApp() async {
    await _authJourney.markLocationPermissionSeen();
    try {
      await Geolocator.requestPermission();
    } catch (_) {
      // Ignore permission errors and proceed.
    }
    if (!mounted) return;
    await _navigateNext(context);
  }

  Future<void> _onAlways() async {
    await _authJourney.markLocationPermissionSeen();
    try {
      await Geolocator.requestPermission();
      // On supported platforms, attempt to upgrade to always.
      final LocationPermission current = await Geolocator.checkPermission();
      if (current == LocationPermission.whileInUse) {
        await Geolocator.requestPermission();
      }
    } catch (_) {
      // Ignore permission errors and proceed.
    }
    if (!mounted) return;
    await _navigateNext(context);
  }

  Future<void> _onMaybeLater() async {
    await _authJourney.markLocationPermissionSeen();
    if (!mounted) return;
    await _navigateNext(context);
  }

  Future<void> _navigateNext(BuildContext context) async {
    final bool notificationSeen =
        await _authJourney.isNotificationPermissionSeen();
    if (!context.mounted) return;
    if (notificationSeen) {
      context.goTo(RouteNames.home);
    } else {
      context.goTo(RouteNames.notificationPermission);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LandingPage(
      cardColor: AppColors.card,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spacing24,
        AppSpacing.spacing24,
        AppSpacing.spacing24,
        AppSpacing.spacing24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing24,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius40),
              child: Container(
                height: AppDimensions.otpProgressHeight,
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(
                    AppRadius.radius40,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: AppDimensions.otpProgressHeight,
                        decoration: BoxDecoration(
                          color: AppColors.primary600,
                          borderRadius: BorderRadius.circular(
                            AppRadius.radius40,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing32),
          const Spacer(),
          Center(
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
                  icon: HugeIcons.strokeRoundedLocation01,
                  color: AppColors.primary600,
                  size: AppDimensions.permissionIconInnerSize,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing32),
          Text(
            LocalizationConstants.authLocationTitleKey.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.libraryGreen,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing16),
          Text(
            LocalizationConstants.authLocationDescriptionKey.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: AppDimensions.onboardingButtonHeight,
            child: FilledButton(
              onPressed: () => unawaited(_onOnlyWhenUseApp()),
              child: Text(
                LocalizationConstants.authLocationOnlyWhenUseAppKey.tr(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing16),
          SizedBox(
            height: AppDimensions.onboardingButtonHeight,
            child: FilledButton(
              onPressed: () => unawaited(_onAlways()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary400,
                foregroundColor: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppRadius.radius32,
                  ),
                ),
                textStyle: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.card,
                ),
              ),
              child: Text(
                LocalizationConstants.authLocationAlwaysKey.tr(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing16),
          SizedBox(
            height: AppDimensions.onboardingButtonHeight,
            child: OutlinedButton(
              onPressed: () => unawaited(_onMaybeLater()),
              child: Text(
                LocalizationConstants.authLocationMaybeLaterKey.tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
