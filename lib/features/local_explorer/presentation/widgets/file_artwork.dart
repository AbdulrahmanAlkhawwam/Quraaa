import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../domain/entities/local_file_entry.dart';

class FileArtwork extends StatelessWidget {
  const FileArtwork({
    required this.type,
    super.key,
  });

  final LocalFileEntryType type;

  @override
  Widget build(BuildContext context) {
    final _ArtworkStyle style = _styleFor(type);

    return AspectRatio(
      aspectRatio: type == LocalFileEntryType.directory ? 1.35 : 0.82,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: style.iconColor.withAlpha(36)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              blurRadius: 12,
              offset: Offset(0, 3),
              color: Color(0x12000000),
            ),
          ],
        ),
        child: Center(
          child: HugeIcon(
            icon: style.icon,
            color: style.iconColor,
            size: type == LocalFileEntryType.directory ? 70 : 62,
          ),
        ),
      ),
    );
  }

  _ArtworkStyle _styleFor(LocalFileEntryType type) {
    return switch (type) {
      LocalFileEntryType.directory => const _ArtworkStyle(
          icon: HugeIcons.strokeRoundedFolder01,
          backgroundColor: AppColors.folderBody,
          iconColor: AppColors.secondary,
        ),
      LocalFileEntryType.pdf => const _ArtworkStyle(
          icon: HugeIcons.strokeRoundedPdf02,
          backgroundColor: AppColors.pdfSurface,
          iconColor: AppColors.pdfLabel,
        ),
      LocalFileEntryType.unsupported => const _ArtworkStyle(
          icon: HugeIcons.strokeRoundedFileUnknown,
          backgroundColor: AppColors.unsupportedFileSurface,
          iconColor: AppColors.unsupportedFileLabel,
        ),
    };
  }
}

class _ArtworkStyle {
  const _ArtworkStyle({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final List<List<dynamic>> icon;
  final Color backgroundColor;
  final Color iconColor;
}
