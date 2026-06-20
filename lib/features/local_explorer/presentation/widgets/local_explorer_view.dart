import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_dimensions.dart';
import '../../domain/entities/local_directory_snapshot.dart';
import '../../domain/entities/local_file_entry.dart';
import '../bloc/local_explorer_bloc.dart';
import 'explorer_access_view.dart';
import 'explorer_content.dart';
import 'explorer_failure_view.dart';
import 'explorer_loading_view.dart';
import 'progress_overlay.dart';

class LocalExplorerView extends StatefulWidget {
  const LocalExplorerView({super.key});

  @override
  State<LocalExplorerView> createState() => _LocalExplorerViewState();
}

class _LocalExplorerViewState extends State<LocalExplorerView> {
  bool _isGridMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.pageMaxWidth,
            ),
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
                  LocalExplorerInitial() => const ExplorerLoadingView(),
                  LocalExplorerAccessRequired() => ExplorerAccessView(
                      onAccessRequested: () => _dispatch(
                        context,
                        const LocalExplorerAccessRequested(),
                      ),
                    ),
                  LocalExplorerLoading(previous: final previous) =>
                    previous == null
                        ? const ExplorerLoadingView()
                        : ProgressOverlay(
                            child: _content(context, previous),
                          ),
                  LocalExplorerLoaded(snapshot: final snapshot) =>
                    _content(context, snapshot),
                  LocalExplorerFailure(message: final message, previous: final previous) =>
                    previous == null
                        ? ExplorerFailureView(
                            message: message,
                            onRetry: () => _dispatch(
                              context,
                              const LocalExplorerRefreshRequested(),
                            ),
                          )
                        : _content(context, previous),
                };
              },
            ),
          ),
        ),
      ),
    );
  }

  ExplorerContent _content(
    BuildContext context,
    LocalDirectorySnapshot snapshot,
  ) {
    return ExplorerContent(
      snapshot: snapshot,
      isGridMode: _isGridMode,
      canNavigateBack: snapshot.canNavigateUp || context.canPop(),
      onToggleView: _toggleView,
      onNavigateBack: () => _navigateBack(context, snapshot),
      onRefresh: () => _dispatch(
        context,
        const LocalExplorerRefreshRequested(),
      ),
      onBreadcrumbSelected: (LocalPathSegment segment) => _dispatch(
        context,
        LocalExplorerBreadcrumbSelected(segment.path),
      ),
      onOpenDirectory: (LocalFileEntry entry) => _dispatch(
        context,
        LocalExplorerDirectoryOpened(entry.path),
      ),
      onOpenPdf: (LocalFileEntry entry) => _openPdf(context, entry),
    );
  }

  void _toggleView() {
    setState(() {
      _isGridMode = !_isGridMode;
    });
  }

  void _navigateBack(
    BuildContext context,
    LocalDirectorySnapshot snapshot,
  ) {
    if (snapshot.canNavigateUp) {
      _dispatch(context, const LocalExplorerParentRequested());
      return;
    }

    if (context.canPop()) {
      context.pop();
    }
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
}
