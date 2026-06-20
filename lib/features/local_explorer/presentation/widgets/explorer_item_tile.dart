import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/local_file_entry.dart';
import 'file_artwork.dart';

class ExplorerItemTile extends StatelessWidget {
  const ExplorerItemTile({
    required this.entry,
    required this.onOpenDirectory,
    required this.onOpenPdf,
    super.key,
  });

  final LocalFileEntry entry;
  final ValueChanged<LocalFileEntry> onOpenDirectory;
  final ValueChanged<LocalFileEntry> onOpenPdf;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = entry.isSupported;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double documentArtworkWidth = (constraints.maxWidth * 0.52)
            .clamp(56.0, 86.0)
            .toDouble();

        return Opacity(
          opacity: isEnabled ? 1 : 0.36,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: !isEnabled
                ? null
                : () {
                    if (entry.isDirectory) {
                      onOpenDirectory(entry);
                      return;
                    }

                    onOpenPdf(entry);
                  },
            child: Padding(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Center(
                      child: entry.isDirectory
                          ? FileArtwork(type: entry.type)
                          : SizedBox(
                              width: documentArtworkWidth,
                              child: FileArtwork(
                                type: entry.type,
                                label: _artworkLabel(entry),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          entry.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.1,
                              ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _trailingLabel(entry),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _trailingLabel(LocalFileEntry entry) {
    return _formatBytes(entry.sizeBytes);
  }

  String? _artworkLabel(LocalFileEntry entry) {
    if (entry.isPdf) {
      return 'PDF';
    }

    final String lowerName = entry.name.toLowerCase();
    if (lowerName.endsWith('.xls') || lowerName.endsWith('.xlsx')) {
      return 'Excel';
    }

    if (lowerName.endsWith('.doc') || lowerName.endsWith('.docx')) {
      return 'Docs';
    }

    return null;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    final double kilobytes = bytes / 1024;
    if (kilobytes < 1024) {
      return '${kilobytes.toStringAsFixed(1)} KB';
    }

    final double megabytes = kilobytes / 1024;
    if (megabytes < 1024) {
      return '${megabytes.toStringAsFixed(1)} MB';
    }

    return '${(megabytes / 1024).toStringAsFixed(1)} GB';
  }
}
