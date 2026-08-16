import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/extensions/app_context.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/styles/text_styles.dart';

class PdfReaderProgressSheet extends StatelessWidget {
  const PdfReaderProgressSheet({
    required this.fileName,
    required this.fileSizeLabel,
    required this.currentPage,
    required this.pageCount,
    required this.readingDays,
    super.key,
  });

  final String fileName;
  final String fileSizeLabel;
  final int currentPage;
  final int pageCount;
  final List<DateTime> readingDays;

  @override
  Widget build(BuildContext context) {
    final double progress =
        pageCount <= 0 ? 0 : (currentPage / pageCount).clamp(0.0, 1.0);
    final Set<String> activeDays = readingDays.map(_dateKey).toSet();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(28, 28, 28, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const _PdfFileIcon(),
                  const SizedBox(width: AppSpacing.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          fileName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h3.copyWith(
                            color: context.appTextPrimary,
                            fontSize: 25,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing8),
                        Text(
                          LocalizationConstants.pdfReaderFileSizeKey.tr(
                            namedArgs: <String, String>{
                              'size': fileSizeLabel,
                            },
                          ),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: context.appTextSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            color: AppColors.primary600,
                            backgroundColor: AppColors.primary50,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing8),
                        Text(
                          LocalizationConstants.pdfReaderProgressPagesKey.tr(
                            namedArgs: <String, String>{
                              'current': currentPage.toString(),
                              'total': pageCount.toString(),
                            },
                          ),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.appTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing28),
              Text(
                LocalizationConstants.pdfReaderStreakKey.tr(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: context.appTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing12),
              _StreakGrid(activeDays: activeDays),
            ],
          ),
        ),
      ),
    );
  }

  String _dateKey(DateTime date) {
    final DateTime local = date.toLocal();
    return local.year.toString() +
        '-' +
        local.month.toString() +
        '-' +
        local.day.toString();
  }
}

class _PdfFileIcon extends StatelessWidget {
  const _PdfFileIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 126,
      decoration: BoxDecoration(
        color: const Color(0xFFF49389),
        borderRadius: BorderRadius.circular(AppRadius.radius16),
      ),
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            end: 0,
            top: 0,
            child: ClipPath(
              clipper: _FoldClipper(),
              child: Container(
                width: 48,
                height: 48,
                color: const Color(0xFFFFC8C2),
              ),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 44),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedPdf02,
                color: Color(0xFFD5362D),
                size: 42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _StreakGrid extends StatelessWidget {
  const _StreakGrid({required this.activeDays});

  final Set<String> activeDays;

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final List<DateTime> days = List<DateTime>.generate(
      84,
      (int index) => DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 83 - index)),
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 14,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemBuilder: (BuildContext context, int index) {
        final DateTime day = days[index];
        final String key = day.year.toString() +
            '-' +
            day.month.toString() +
            '-' +
            day.day.toString();
        final bool active = activeDays.contains(key);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: active ? AppColors.primary600 : AppColors.primary50,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      },
    );
  }
}
