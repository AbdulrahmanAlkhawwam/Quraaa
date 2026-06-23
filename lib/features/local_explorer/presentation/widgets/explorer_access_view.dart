import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import 'explorer_permission_button.dart';
import 'explorer_permission_header.dart';
import 'explorer_permission_icon.dart';
import 'explorer_permission_progress_bar.dart';

class ExplorerAccessView extends StatelessWidget {
  const ExplorerAccessView({
    required this.onAccessRequested,
    required this.onDismissed,
    super.key,
  });

  static const double _maxSheetWidth = 420;
  static const double _sheetHeightRatio = 0.665;
  static const double _sheetRadius = 16;
  static const double _wideHorizontalPadding = 18;

  final VoidCallback onAccessRequested;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double sheetHeight = constraints.maxHeight * _sheetHeightRatio;
          final double sheetWidth = constraints.maxWidth > _maxSheetWidth
              ? _maxSheetWidth
              : constraints.maxWidth;

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const Positioned.fill(child: ExplorerPermissionHeader()),
              Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: SizedBox(
                  width: sheetWidth,
                  height: sheetHeight,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(_sheetRadius),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _wideHorizontalPadding,
                      ),
                      child: _PermissionSheetContent(
                        onAccessRequested: onAccessRequested,
                        onDismissed: onDismissed,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PermissionSheetContent extends StatelessWidget {
  const _PermissionSheetContent({
    required this.onAccessRequested,
    required this.onDismissed,
  });

  final VoidCallback onAccessRequested;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double height = constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PositionedDirectional(
              top: height * 0.067,
              start: 0,
              end: 0,
              child: const ExplorerPermissionProgressBar(),
            ),
            PositionedDirectional(
              top: height * 0.225,
              start: 0,
              end: 0,
              child: const ExplorerPermissionIcon(),
            ),
            PositionedDirectional(
              top: height * 0.51,
              start: 0,
              end: 0,
              child: Text(
                LocalizationConstants.explorerAccessTitleKey.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.explorerTitle().copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.05,
                ),
              ),
            ),
            PositionedDirectional(
              top: height * 0.595,
              start: 0,
              end: 0,
              child: Text(
                LocalizationConstants.explorerAccessMessageKey.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8C9A89),
                      fontSize: 12,
                      height: 1.2,
                    ),
              ),
            ),
            PositionedDirectional(
              top: height * 0.704,
              start: 0,
              end: 0,
              child: ExplorerPermissionButton(
                label: LocalizationConstants.explorerAccessActionKey.tr(),
                isPrimary: true,
                onPressed: onAccessRequested,
              ),
            ),
            PositionedDirectional(
              top: height * 0.833,
              start: 0,
              end: 0,
              child: ExplorerPermissionButton(
                label: LocalizationConstants.explorerAccessDismissKey.tr(),
                onPressed: onDismissed,
              ),
            ),
          ],
        );
      },
    );
  }
}
