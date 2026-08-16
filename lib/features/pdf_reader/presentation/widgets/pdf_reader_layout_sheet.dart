import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/extensions/app_context.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/styles/text_styles.dart';
import '../../domain/entities/pdf_reader_local_state.dart';

class PdfReaderLayoutSheet extends StatefulWidget {
  const PdfReaderLayoutSheet({
    required this.initialDirection,
    required this.onDirectionChanged,
    required this.onReset,
    super.key,
  });

  final PdfReaderScrollDirection initialDirection;
  final ValueChanged<PdfReaderScrollDirection> onDirectionChanged;
  final VoidCallback onReset;

  @override
  State<PdfReaderLayoutSheet> createState() => _PdfReaderLayoutSheetState();
}

class _PdfReaderLayoutSheetState extends State<PdfReaderLayoutSheet> {
  late PdfReaderScrollDirection _direction = widget.initialDirection;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              LocalizationConstants.pdfReaderPageNavigationKey.tr(),
              style: AppTextStyles.bodyLarge.copyWith(
                color: context.appTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ChoiceButton(
                    label: LocalizationConstants.pdfReaderHorizontalKey.tr(),
                    icon: Icons.view_week_outlined,
                    selected: _direction == PdfReaderScrollDirection.horizontal,
                    onPressed: () =>
                        _changeDirection(PdfReaderScrollDirection.horizontal),
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing12),
                Expanded(
                  child: _ChoiceButton(
                    label: LocalizationConstants.pdfReaderVerticalKey.tr(),
                    icon: Icons.view_agenda_outlined,
                    selected: _direction == PdfReaderScrollDirection.vertical,
                    onPressed: () =>
                        _changeDirection(PdfReaderScrollDirection.vertical),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              LocalizationConstants.pdfReaderPaginationStatusKey.tr(),
              style: AppTextStyles.bodyLarge.copyWith(
                color: context.appTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _ChoiceButton(
                    label: LocalizationConstants.pdfReaderContinuousKey.tr(),
                    icon: Icons.view_agenda_outlined,
                    selected: true,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing12),
                Expanded(
                  child: _ChoiceButton(
                    label: LocalizationConstants.pdfReaderSplitKey.tr(),
                    icon: Icons.grid_view_rounded,
                    selected: false,
                    enabled: false,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing28),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    _direction = PdfReaderScrollDirection.vertical;
                  });
                  widget.onReset();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  foregroundColor: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radius32),
                  ),
                ),
                child: Text(
                  LocalizationConstants.pdfReaderResetChangesKey.tr(),
                  style: AppTextStyles.buttonLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeDirection(PdfReaderScrollDirection direction) {
    if (_direction == direction) {
      return;
    }
    setState(() {
      _direction = direction;
    });
    widget.onDirectionChanged(direction);
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected
        ? Colors.white
        : enabled
            ? AppColors.primary600
            : context.appTextTertiary;
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: selected ? AppColors.primary500 : context.appCard,
          disabledForegroundColor: context.appTextTertiary,
          side: BorderSide(
            color: selected
                ? AppColors.primary500
                : enabled
                    ? AppColors.primary200
                    : context.appBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radius28),
          ),
        ),
      ),
    );
  }
}
