import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../bloc/auth_permission_cubit.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthPermissionCubit>(
      create: (_) => sl<AuthPermissionCubit>(),
      child: BlocConsumer<AuthPermissionCubit, AuthPermissionState>(
        listenWhen: (previous, current) =>
            previous.navigationSerial != current.navigationSerial,
        listener: (context, state) {
          final String? nextRoute = state.nextRoute;
          if (nextRoute != null) {
            context.goTo(nextRoute);
          }
        },
        builder: (context, state) {
          return AppLayout(
            expandContent: true,
            cardColor: context.appCard,
            padding: const EdgeInsetsDirectional.fromSTEB(
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
                        color: context.appBorder,
                        borderRadius: BorderRadius.circular(AppRadius.radius40),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: AppDimensions.otpProgressHeight,
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.radius40,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox.shrink()),
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
                      color: context.appSubtleSurface,
                      border: Border.all(color: context.appBorder, width: 2),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedLocation01,
                        color: context.colors.primary,
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
                    color: context.isDark
                        ? AppColors.primary300
                        : AppColors.libraryGreen,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing16),
                Text(
                  LocalizationConstants.authLocationDescriptionKey.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.appTextTertiary,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: AppDimensions.onboardingButtonHeight,
                  child: FilledButton(
                    onPressed: state.isLoading
                        ? null
                        : () => unawaited(
                              context
                                  .read<AuthPermissionCubit>()
                                  .requestLocationWhileInUse(),
                            ),
                    child: Text(
                      LocalizationConstants.authLocationOnlyWhenUseAppKey.tr(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing16),
                SizedBox(
                  height: AppDimensions.onboardingButtonHeight,
                  child: FilledButton(
                    onPressed: state.isLoading
                        ? null
                        : () => unawaited(
                              context
                                  .read<AuthPermissionCubit>()
                                  .requestLocationAlways(),
                            ),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.secondary,
                      foregroundColor: context.colors.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.radius32),
                      ),
                      textStyle: AppTextStyles.buttonMedium.copyWith(
                        color: context.colors.onSecondary,
                      ),
                    ),
                    child:
                        Text(LocalizationConstants.authLocationAlwaysKey.tr()),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing16),
                SizedBox(
                  height: AppDimensions.onboardingButtonHeight,
                  child: OutlinedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => unawaited(
                              context
                                  .read<AuthPermissionCubit>()
                                  .skipLocationPermission(),
                            ),
                    child: Text(
                      LocalizationConstants.authLocationMaybeLaterKey.tr(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
