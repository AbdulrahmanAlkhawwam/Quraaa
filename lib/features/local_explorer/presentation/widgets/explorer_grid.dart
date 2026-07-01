import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/local_file_entry.dart';
import 'explorer_item_tile.dart';

class ExplorerGrid extends StatelessWidget {
  const ExplorerGrid({
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 620
                ? 3
                : 2;

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.spacing32),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppSpacing.spacing16,
            crossAxisSpacing: AppSpacing.spacing16,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (BuildContext context, int index) {
            return ExplorerItemTile(
              entry: entries[index],
              onOpenDirectory: onOpenDirectory,
              onOpenPdf: onOpenPdf,
            );
          },
          itemCount: entries.length,
        );
      },
    );
  }
}
