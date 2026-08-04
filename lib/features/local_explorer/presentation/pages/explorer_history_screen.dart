import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/explorer_history_entry.dart';
import '../cubit/explorer_history_cubit.dart';

class ExplorerHistoryScreen extends StatelessWidget {
  const ExplorerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExplorerHistoryCubit>(
      create: (_) => sl<ExplorerHistoryCubit>()..load(),
      child: const _ExplorerHistoryView(),
    );
  }
}

class _ExplorerHistoryView extends StatelessWidget {
  const _ExplorerHistoryView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExplorerHistoryCubit, ExplorerHistoryState>(
      listenWhen: (previous, current) =>
          previous.errorSerial != current.errorSerial,
      listener: (context, state) {
        final String? errorKey = state.errorKey;
        if (errorKey == null) return;
        context.showErrorSnackBar(
          message: Message(title: '', value: errorKey.tr()),
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.appBackground,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                const _HistoryAppBar(),
                Expanded(
                  child: state.loading
                      ? const Center(child: CircularProgressIndicator())
                      : state.entries.isEmpty
                          ? const _EmptyHistory()
                          : _HistoryList(entries: state.entries),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryAppBar extends StatelessWidget {
  const _HistoryAppBar();

  @override
  Widget build(BuildContext context) {
    final Color foreground = context.isDark
        ? AppColors.primary300
        : AppColors.libraryGreen;
    return SizedBox(
      height: 86,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: HugeIcon(
                icon: context.isRTL
                    ? HugeIcons.strokeRoundedArrowRight01
                    : HugeIcons.strokeRoundedArrowLeft01,
                color: foreground,
                size: 23,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                LocalizationConstants.explorerHistoryTitleKey.tr(),
                style: AppTextStyles.h3.copyWith(
                  color: foreground,
                  fontSize: 29,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.entries});

  final List<ExplorerHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 32),
      itemCount: entries.length,
      separatorBuilder: (_, __) => Divider(
        height: 24,
        color: context.appBorder,
      ),
      itemBuilder: (context, index) {
        final ExplorerHistoryEntry entry = entries[index];
        return InkWell(
          onTap: () => unawaited(_open(context, entry)),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: context.appTextPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _directoryLabel(entry),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.appTextSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    _relativeDate(entry.openedAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.appTextTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _directoryLabel(ExplorerHistoryEntry entry) {
    if (entry.directoryName == 'Internal Storage') {
      return LocalizationConstants.explorerHistoryInternalStorageKey.tr();
    }
    return entry.directoryName;
  }

  String _relativeDate(DateTime openedAt) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime openedDay = DateTime(
      openedAt.toLocal().year,
      openedAt.toLocal().month,
      openedAt.toLocal().day,
    );
    final int days = today.difference(openedDay).inDays;
    if (days <= 0) {
      return LocalizationConstants.explorerHistoryTodayKey.tr();
    }
    if (days == 1) {
      return LocalizationConstants.explorerHistoryYesterdayKey.tr();
    }
    if (days <= 7) {
      return LocalizationConstants.explorerHistoryLastWeekKey.tr();
    }
    if (days <= 31) {
      return LocalizationConstants.explorerHistoryLastMonthKey.tr();
    }
    return '${openedAt.year.toString().padLeft(4, '0')}/'
        '${openedAt.month.toString().padLeft(2, '0')}/'
        '${openedAt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _open(
    BuildContext context,
    ExplorerHistoryEntry entry,
  ) async {
    final bool available = await context
        .read<ExplorerHistoryCubit>()
        .prepareToOpen(entry);
    if (!available || !context.mounted) return;
    context.pushNamed(
      RouteNames.pdfReaderName,
      queryParameters: <String, String>{
        'path': entry.path,
        'name': entry.name,
      },
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HugeIcon(
              icon: HugeIcons.strokeRoundedFileClock,
              color: context.appTextTertiary,
              size: 58,
            ),
            const SizedBox(height: 16),
            Text(
              LocalizationConstants.explorerHistoryEmptyKey.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: context.appTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
