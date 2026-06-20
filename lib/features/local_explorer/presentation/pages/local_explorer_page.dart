import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/local_directory_snapshot.dart';
import '../../domain/entities/local_file_entry.dart';
import '../bloc/local_explorer_bloc.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/explorer_item_tile.dart';
import '../widgets/explorer_note.dart';
import '../widgets/file_artwork.dart';

class LocalExplorerPage extends StatelessWidget {
  const LocalExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocalExplorerBloc>(
      create: (BuildContext context) {
        return sl<LocalExplorerBloc>()..add(const LocalExplorerStarted());
      },
      child: const _LocalExplorerView(),
    );
  }
}

class _LocalExplorerView extends StatefulWidget {
  const _LocalExplorerView();

  @override
  State<_LocalExplorerView> createState() => _LocalExplorerViewState();
}

class _LocalExplorerViewState extends State<_LocalExplorerView> {
  bool _isGridMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppDimensions.pageMaxWidth),
            child: BlocConsumer<LocalExplorerBloc, LocalExplorerState>(
              listener: (BuildContext context, LocalExplorerState state) {
                if (state is LocalExplorerFailure && state.previous != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (BuildContext context, LocalExplorerState state) {
                return switch (state) {
                  LocalExplorerInitial() => const _LoadingView(),
                  LocalExplorerAccessRequired() => const _AccessView(),
                  LocalExplorerLoading(previous: final previous) =>
                    previous == null
                        ? const _LoadingView()
                        : _WithProgressOverlay(
                            child: _ExplorerContent(
                              snapshot: previous,
                              isGridMode: _isGridMode,
                              onToggleView: _toggleView,
                            ),
                          ),
                  LocalExplorerLoaded(snapshot: final snapshot) =>
                    _ExplorerContent(
                      snapshot: snapshot,
                      isGridMode: _isGridMode,
                      onToggleView: _toggleView,
                    ),
                  LocalExplorerFailure(message: final message, previous: final previous) =>
                    previous == null
                        ? _FailureView(message: message)
                        : _ExplorerContent(
                            snapshot: previous,
                            isGridMode: _isGridMode,
                            onToggleView: _toggleView,
                          ),
                };
              },
            ),
          ),
        ),
      ),
    );
  }

  void _toggleView() {
    setState(() {
      _isGridMode = !_isGridMode;
    });
  }
}

class _ExplorerContent extends StatelessWidget {
  const _ExplorerContent({
    required this.snapshot,
    required this.isGridMode,
    required this.onToggleView,
  });

  final LocalDirectorySnapshot snapshot;
  final bool isGridMode;
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ExplorerHeader(
            snapshot: snapshot,
            isGridMode: isGridMode,
            onToggleView: onToggleView,
          ),
          const SizedBox(height: AppSpacing.lg),
          BreadcrumbBar(
            breadcrumbs: snapshot.breadcrumbs,
            onSelected: (LocalPathSegment segment) => _dispatch(
              context,
              LocalExplorerBreadcrumbSelected(segment.path),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ExplorerNote(
            title: LocalizationConstants.explorerNoteTitleKey.tr(),
            message: LocalizationConstants.explorerNoteMessageKey.tr(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: snapshot.entries.isEmpty
                ? const _EmptyView()
                : isGridMode
                    ? _ExplorerGrid(entries: snapshot.entries)
                    : _ExplorerList(entries: snapshot.entries),
          ),
        ],
      ),
    );
  }
}

class _ExplorerHeader extends StatelessWidget {
  const _ExplorerHeader({
    required this.snapshot,
    required this.isGridMode,
    required this.onToggleView,
  });

  final LocalDirectorySnapshot snapshot;
  final bool isGridMode;
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: snapshot.canNavigateUp
              ? () => _dispatch(
                    context,
                    const LocalExplorerParentRequested(),
                  )
              : context.canPop()
                  ? () => context.pop()
                  : null,
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.secondary,
            size: 34,
          ),
          color: AppColors.secondary,
          iconSize: 34,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            LocalizationConstants.explorerTitleKey.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        IconButton(
          tooltip: isGridMode ? 'List view' : 'Grid view',
          onPressed: onToggleView,
          icon: HugeIcon(
            icon: isGridMode
                ? HugeIcons.strokeRoundedFlowSquare
                : HugeIcons.strokeRoundedViewAgenda,
            color: AppColors.secondary,
            size: 30,
          ),
          color: AppColors.secondary,
          iconSize: 30,
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          tooltip: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
          onPressed: () => _dispatch(
            context,
            const LocalExplorerRefreshRequested(),
          ),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowReloadHorizontal,
            color: AppColors.secondary,
            size: 32,
          ),
          color: AppColors.secondary,
          iconSize: 32,
        ),
      ],
    );
  }
}

class _ExplorerGrid extends StatelessWidget {
  const _ExplorerGrid({required this.entries});

  final List<LocalFileEntry> entries;

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
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: 0.96,
          ),
          itemBuilder: (BuildContext context, int index) {
            return ExplorerItemTile(
              entry: entries[index],
              onOpenDirectory: (LocalFileEntry entry) =>
                  _openDirectory(context, entry),
              onOpenPdf: (LocalFileEntry entry) => _openPdf(context, entry),
            );
          },
          itemCount: entries.length,
        );
      },
    );
  }
}

class _ExplorerList extends StatelessWidget {
  const _ExplorerList({required this.entries});

  final List<LocalFileEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
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
                    color: AppColors.textPrimary,
                  ),
            ),
            subtitle: Text(
              entry.isPdf
                  ? LocalizationConstants.explorerOpenPdfOnlyKey.tr()
                  : entry.isDirectory
                      ? 'Folder'
                      : 'Unsupported',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            trailing: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.textMuted,
              size: 22,
            ),
            onTap: !enabled
                ? null
                : () => _openEntry(context, entry),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(height: 1, color: AppColors.borderLight);
      },
      itemCount: entries.length,
    );
  }
}

class _WithProgressOverlay extends StatelessWidget {
  const _WithProgressOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        const Positioned(
          left: 0,
          top: 0,
          right: 0,
          child: LinearProgressIndicator(minHeight: 2),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const HugeIcon(
              icon: HugeIcons.strokeRoundedFolderOpen,
              color: AppColors.textMuted,
              size: 56,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              LocalizationConstants.explorerEmptyTitleKey.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              LocalizationConstants.explorerEmptyMessageKey.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessView extends StatelessWidget {
  const _AccessView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.noteSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.noteBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedFolderUnlocked,
                  color: AppColors.secondary,
                  size: 58,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  LocalizationConstants.explorerAccessTitleKey.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  LocalizationConstants.explorerAccessMessageKey.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: () => _dispatch(
                    context,
                    const LocalExplorerAccessRequested(),
                  ),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedFolderUnlocked,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: Text(LocalizationConstants.explorerAccessActionKey.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const HugeIcon(
              icon: HugeIcons.strokeRoundedCancelCircle,
              color: AppColors.pdfLabel,
              size: 52,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => _dispatch(
                context,
                const LocalExplorerRefreshRequested(),
              ),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowReloadHorizontal,
                color: AppColors.secondary,
                size: 20,
              ),
              label: Text(LocalizationConstants.retryKey.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

void _openDirectory(BuildContext context, LocalFileEntry entry) {
  _dispatch(context, LocalExplorerDirectoryOpened(entry.path));
}

void _openEntry(BuildContext context, LocalFileEntry entry) {
  if (entry.isDirectory) {
    _openDirectory(context, entry);
    return;
  }

  _openPdf(context, entry);
}

void _openPdf(BuildContext context, LocalFileEntry entry) {
  context.pushNamed(
    RouteNames.pdfReaderName,
    queryParameters: <String, String>{
      'path': entry.path,
      'name': entry.name,
    },
    extra: entry,
  );
}

void _dispatch(BuildContext context, LocalExplorerEvent event) {
  context.read<LocalExplorerBloc>().add(event);
}
