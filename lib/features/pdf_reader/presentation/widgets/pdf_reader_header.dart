import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import 'pdf_page_counter_badge.dart';
import 'pdf_reader_title_block.dart';

class PdfReaderHeader extends StatelessWidget {
  const PdfReaderHeader({
    required this.fileName,
    this.currentPage,
    this.pageCount,
    super.key,
  });

  final String fileName;
  final int? currentPage;
  final int? pageCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spacing24,
        AppSpacing.spacing16,
        AppSpacing.spacing24,
        AppSpacing.spacing8,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget leading = IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: context.canPop() ? () => context.pop() : null,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: AppColors.secondary,
              size: 28,
            ),
            color: AppColors.secondary,
            iconSize: 28,
          );
          final Widget title = PdfReaderTitleBlock(fileName: fileName);
          final Widget counter = PdfPageCounterBadge(
            currentPage: currentPage,
            pageCount: pageCount,
          );

          if (constraints.maxWidth < 460) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    leading,
                    const SizedBox(width: AppSpacing.spacing8),
                    Expanded(child: title),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Row(
                  children: <Widget>[
                    const Spacer(),
                    counter,
                  ],
                ),
              ],
            );
          }

          return Row(
            children: <Widget>[
              leading,
              const SizedBox(width: AppSpacing.spacing8),
              Expanded(child: title),
              const SizedBox(width: AppSpacing.spacing16),
              counter,
            ],
          );
        },
      ),
    );
  }
}
