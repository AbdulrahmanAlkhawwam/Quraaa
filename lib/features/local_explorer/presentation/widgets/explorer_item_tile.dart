import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
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

    return Opacity(
      opacity: isEnabled ? 1 : 0.42,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
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
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Center(child: FileArtwork(type: entry.type)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      entry.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.15,
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
  }

  String _trailingLabel(LocalFileEntry entry) {
    if (entry.isDirectory) {
      return 'Folder';
    }

    return _formatBytes(entry.sizeBytes);
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
