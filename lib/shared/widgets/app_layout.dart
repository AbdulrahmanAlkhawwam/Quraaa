import 'package:flutter/material.dart';

import '../../core/assets/app_images.dart';
import '../theme/app_colors.dart';
import 'app_image.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'dev_debug_overlay.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({
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
    this.expandContent = false,
    this.floatingActionButton = const DevDebugOverlay(),
    super.key,
  });

  final Widget child;
  final Widget header;
  final Color cardColor;
  final double topRadius;
  final EdgeInsetsGeometry padding;
  final bool resizeToAvoidBottomInset;
  final bool expandContent;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    Widget contentCard = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      ),
      child: SafeArea(child: child),
    );

    if (expandContent) {
      contentCard = Expanded(child: contentCard);
    }

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      body: SizedBox.expand(
        child: Stack(
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
                      AppColors.libraryGreen.withAlpha(
                        AppColors.overlayLightAlpha,
                      ),
                      AppColors.libraryGreen.withAlpha(
                        AppColors.overlayMediumAlpha,
                      ),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [header, contentCard],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
