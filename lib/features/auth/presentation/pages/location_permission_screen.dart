import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/assets/app_images.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/shared.dart';
import '../../data/datasources/auth_local_datasource.dart';

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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.onboardingBackground,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    AppColors.libraryGreen.withAlpha(100),
                    AppColors.libraryGreen.withAlpha(120),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.spacing24,
                  AppSpacing.spacing24,
                  AppSpacing.spacing24,
                  AppSpacing.spacing24 + context.bottomPadding,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.radius40),
                    topRight: Radius.circular(AppRadius.radius40),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing24,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.radius40),
                        child: Container(
                          height: 4,
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
                                  height: 4,
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
                        width: 120,
                        height: 120,
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
                            size: 56,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing32),
                    Text(
                      'Get Your Place',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.libraryGreen,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    Text(
                      'Can us Get your Location for make delivery service available',
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
                        child: const Text('Only When Use App'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    SizedBox(
                      height: AppDimensions.onboardingButtonHeight,
                      child: FilledButton(
                        onPressed: () => unawaited(_onAlways()),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary400,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppRadius.radius32,
                            ),
                          ),
                          textStyle: AppTextStyles.buttonMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        child: const Text('Take Permission Always'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
                    SizedBox(
                      height: AppDimensions.onboardingButtonHeight,
                      child: OutlinedButton(
                        onPressed: () => unawaited(_onMaybeLater()),
                        child: const Text('Maybe Later'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
