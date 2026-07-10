import 'package:flutter/material.dart';

import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/local_directory_snapshot.dart';
import '../../domain/entities/local_file_entry.dart';
import 'breadcrumb_bar.dart';
import 'explorer_empty_view.dart';
import 'explorer_grid.dart';
import 'explorer_header.dart';
import 'explorer_list.dart';

class ExplorerContent extends StatelessWidget {
  const ExplorerContent({
    required this.snapshot,
    required this.isGridMode,
    required this.canNavigateBack,
    required this.onToggleView,
    required this.onNavigateBack,
    required this.onRefresh,
    required this.onBreadcrumbSelected,
    required this.onOpenDirectory,
    required this.onOpenPdf,
    super.key,
  });

  final LocalDirectorySnapshot snapshot;
  final bool isGridMode;
  final bool canNavigateBack;
  final VoidCallback onToggleView;
  final VoidCallback onNavigateBack;
  final VoidCallback onRefresh;
  final ValueChanged<LocalPathSegment> onBreadcrumbSelected;
  final ValueChanged<LocalFileEntry> onOpenDirectory;
  final ValueChanged<LocalFileEntry> onOpenPdf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.spacing24,
        AppSpacing.spacing24,
        AppSpacing.spacing24,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExplorerHeader(
            isGridMode: isGridMode,
            canNavigateBack: canNavigateBack,
            onNavigateBack: onNavigateBack,
            onToggleView: onToggleView,
            onRefresh: onRefresh,
          ),
          const SizedBox(height: AppSpacing.spacing32),
          BreadcrumbBar(
            breadcrumbs: snapshot.breadcrumbs,
            onSelected: onBreadcrumbSelected,
          ),
          const SizedBox(height: AppSpacing.spacing16),
          Expanded(
            child: snapshot.entries.isEmpty
                ? const ExplorerEmptyView()
                : isGridMode
                    ? ExplorerGrid(
                        entries: snapshot.entries,
                        onOpenDirectory: onOpenDirectory,
                        onOpenPdf: onOpenPdf,
                      )
                    : ExplorerList(
                        entries: snapshot.entries,
                        onOpenDirectory: onOpenDirectory,
                        onOpenPdf: onOpenPdf,
                      ),
          ),
        ],
      ),
    );
  }
}
