import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/assets/app_images.dart';
import '../../../core/localization/localization_constants.dart';
import '../shared.dart';
import 'onboarding_progress_indicator.dart';

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    required this.content,
    required this.bottomButton,
    required this.activeIndex,
    required this.totalSteps,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget content;
  final Widget bottomButton;
  final int activeIndex;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AppImage(
              AppImages.onboardingBackground,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    AppColors.libraryGreen.withAlpha(AppColors.overlayLightAlpha),
                    AppColors.libraryGreen.withAlpha(AppColors.overlayMediumAlpha),
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
              child: Column(
                children: [
                  AppBar(
                    leading: leading,
                    title: Text(title),
                    actions: actions,
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.spacing24,
                        AppSpacing.spacing24,
                        AppSpacing.spacing24,
                        AppSpacing.spacing24 + context.bottomPadding,
                      ),
                      decoration: BoxDecoration(
                        color: context.appCard,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.radius40),
                          topRight: Radius.circular(AppRadius.radius40),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(child: content),
                          OnboardingProgressIndicator(
                            activeIndex: activeIndex,
                            count: totalSteps,
                          ),
                          const SizedBox(height: AppSpacing.spacing24),
                          bottomButton,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSkipButton extends StatelessWidget {
  const OnboardingSkipButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: AppColors.primary50),
        child: Text(
          LocalizationConstants.onboardingSkipKey.tr(),
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }
}

class OnboardingBackButton extends StatelessWidget {
  const OnboardingBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: HugeIcon(
        icon: context.isRTL ? HugeIcons.strokeRoundedArrowRight01 : HugeIcons.strokeRoundedArrowLeft01,
        color: context.appTextPrimary,
        size: 22,
      ),
    );
  }
}

class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.onboardingButtonHeight,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(LocalizationConstants.onboardingNextKey.tr()),
      ),
    );
  }
}
