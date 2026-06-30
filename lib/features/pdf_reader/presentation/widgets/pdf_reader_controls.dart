import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../bloc/pdf_reader_bloc.dart';

class PdfReaderControls extends StatelessWidget {
  const PdfReaderControls({
    required this.state,
    required this.isLandscape,
    required this.onPrevious,
    required this.onNext,
    required this.onSpreadModeChanged,
    super.key,
  });

  final PdfReaderReady state;
  final bool isLandscape;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<PdfReaderSpreadMode> onSpreadModeChanged;

  @override
  Widget build(BuildContext context) {
    final bool canUseTwoPages = isLandscape && state.pageCount > 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spacing24,
        AppSpacing.spacing8,
        AppSpacing.spacing24,
        AppSpacing.spacing16,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.radius16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing8,
            vertical: AppSpacing.spacing4,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.spacing8,
            runSpacing: AppSpacing.spacing4,
            children: <Widget>[
              _ReaderArrowButton(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                onPressed: state.canGoPrevious ? onPrevious : null,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 90),
                child: Text(
                  _pageLabel(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              _ReaderArrowButton(
                icon: HugeIcons.strokeRoundedArrowRight01,
                onPressed: state.canGoNext ? onNext : null,
              ),
              if (canUseTwoPages)
                _TwoPageModeToggle(
                  enabled: state.spreadMode == PdfReaderSpreadMode.twoPages,
                  onChanged: (bool enabled) {
                    onSpreadModeChanged(
                      enabled
                          ? PdfReaderSpreadMode.twoPages
                          : PdfReaderSpreadMode.singlePage,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _pageLabel() {
    final int firstPage = state.currentPageIndex + 1;
    if (state.spreadMode == PdfReaderSpreadMode.twoPages &&
        state.currentPageIndex + 1 < state.pageCount) {
      return '$firstPage-${firstPage + 1} / ${state.pageCount}';
    }

    return '$firstPage / ${state.pageCount}';
  }
}

class _ReaderArrowButton extends StatelessWidget {
  const _ReaderArrowButton({
    required this.icon,
    required this.onPressed,
  });

  final List<List<dynamic>> icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      icon: HugeIcon(
        icon: icon,
        color: onPressed == null ? AppColors.textMuted : AppColors.secondary,
        size: 24,
      ),
    );
  }
}

class _TwoPageModeToggle extends StatelessWidget {
  const _TwoPageModeToggle({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const HugeIcon(
          icon: HugeIcons.strokeRoundedBookOpen01,
          color: AppColors.secondary,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.spacing4),
        Text(
          LocalizationConstants.pdfReaderTwoPageModeKey.tr(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Switch.adaptive(
          value: enabled,
          onChanged: onChanged,
          activeThumbColor: AppColors.secondary,
        ),
      ],
    );
  }
}
