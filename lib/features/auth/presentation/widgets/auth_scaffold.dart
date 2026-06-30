import 'package:flutter/material.dart';

import '../../../../core/assets/app_images.dart';
import '../../../../shared/shared.dart';

/// Shared auth scaffold that renders the onboarding background, gradient
/// overlay and a rounded bottom card.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
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
                    AppColors.libraryGreen.withAlpha(100),
                    AppColors.libraryGreen.withAlpha(120),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: padding.add(
                        EdgeInsets.only(bottom: context.bottomPadding),
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(topRadius),
                          topRight: Radius.circular(topRadius),
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
