import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/localization/localization_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/styles/text_styles.dart';
import 'bottom_sheet_drag_handle.dart';

/// Future: replace [image] with [NotificationBadge] enum to show a pre-defined badge widget.
// enum NotificationBadge { lv1, lv2, lv3, bestReader, ... }

class NotificationBottomSheet extends StatelessWidget {
  const NotificationBottomSheet({
    super.key,
    this.image,
    required this.title,
    required this.body,
    this.route,
    this.buttonLabel,
  });

  final Widget? image;
  final String title;
  final String body;
  final String? route;
  final String? buttonLabel;

  static Future<void> show(
    BuildContext context, {
    Widget? image,
    required String title,
    required String body,
    String? route,
    String? buttonLabel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => NotificationBottomSheet(
        image: image,
        title: title,
        body: body,
        route: route,
        buttonLabel: buttonLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.radius40),
            topRight: Radius.circular(AppRadius.radius40),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetDragHandle(),
              // Close button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing24,
                ),
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: _CloseButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spacing8),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (image != null) ...[
                        image!,
                        const SizedBox(height: AppSpacing.spacing24),
                      ],
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing16),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      if (route != null && route!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.spacing32),
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.onboardingButtonHeight,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.push(route!);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary600,
                              foregroundColor: AppColors.card,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.radius32,
                                ),
                              ),
                            ),
                            child: Text(
                              buttonLabel ??
                                  LocalizationConstants.notificationContinueKey
                                      .tr(),
                              style: AppTextStyles.buttonLarge,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.spacing24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary100,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedCancel01,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
