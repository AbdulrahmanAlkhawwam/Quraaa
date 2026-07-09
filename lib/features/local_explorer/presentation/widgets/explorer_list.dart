import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/local_file_entry.dart';
import 'file_artwork.dart';

class ExplorerList extends StatelessWidget {
  const ExplorerList({
    required this.entries,
    required this.onOpenDirectory,
    required this.onOpenPdf,
    super.key,
  });

  final List<LocalFileEntry> entries;
  final ValueChanged<LocalFileEntry> onOpenDirectory;
  final ValueChanged<LocalFileEntry> onOpenPdf;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.spacing32),
      itemBuilder: (BuildContext context, int index) {
        final LocalFileEntry entry = entries[index];
        final bool enabled = entry.isSupported;

        return Opacity(
          opacity: enabled ? 1 : 0.44,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            enabled: enabled,
            leading: SizedBox(
              width: 54,
              child: FileArtwork(type: entry.type),
            ),
            title: Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.appTextPrimary,
                  ),
            ),
            subtitle: Text(
              entry.isPdf
                  ? LocalizationConstants.explorerOpenPdfOnlyKey.tr()
                  : entry.isDirectory
                      ? LocalizationConstants.userDataFoldersTabKey.tr()
                      : LocalizationConstants.explorerOpenPdfOnlyKey.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.appTextTertiary,
                  ),
            ),
            trailing: HugeIcon(
              icon: context.isRTL ? HugeIcons.strokeRoundedArrowLeft01 : HugeIcons.strokeRoundedArrowRight01,
              color: context.appTextTertiary,
              size: 22,
            ),
            onTap: !enabled
                ? null
                : () {
                    if (entry.isDirectory) {
                      onOpenDirectory(entry);
                      return;
                    }

                    onOpenPdf(entry);
                  },
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(height: 1, color: context.appBorder);
      },
      itemCount: entries.length,
    );
  }
}
