import 'package:flutter/material.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../shared/shared.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({
    required this.child,
    this.header = const SizedBox.shrink(),
    this.cardColor = AppColors.primary50,
    this.topRadius = AppRadius.radius40,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.spacing24,
      AppSpacing.spacing32,
      AppSpacing.spacing24,
      AppSpacing.spacing24,
    ),
    this.resizeToAvoidBottomInset = true,
    super.key,
  });

  final Widget child;
  final Widget header;
  final Color cardColor;
  final double topRadius;
  final EdgeInsetsGeometry padding;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
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
                    AppColors.libraryGreen.withAlpha(AppColors.overlayLightAlpha),
                    AppColors.libraryGreen.withAlpha(AppColors.overlayMediumAlpha),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Expanded(
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(topRadius),
                    ),
                  ),
                  child: SafeArea(
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
