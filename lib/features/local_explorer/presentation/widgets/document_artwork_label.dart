import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/local_file_entry.dart';

class DocumentArtworkLabel extends StatelessWidget {
  const DocumentArtworkLabel({
    required this.label,
    required this.type,
    super.key,
  });

  final String label;
  final LocalFileEntryType type;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: type == LocalFileEntryType.pdf
                    ? AppColors.pdfLabel
                    : AppColors.unsupportedFileLabel,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
