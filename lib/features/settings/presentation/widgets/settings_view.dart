import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../core/localization/supported_locales.dart';
import '../../../../shared/shared.dart' hide NotificationBottomSheet, LanguageBottomSheet;
import '../../domain/entities/appearance_option.dart';
import '../../domain/entities/language_option.dart';
import '../../domain/entities/settings_section.dart';
import '../../domain/entities/settings_tab.dart';
import '../bloc/settings_bloc.dart';
import 'appearance_bottom_sheet.dart';
import 'language_bottom_sheet.dart';
import 'notification_bottom_sheet.dart';
import 'settings_header.dart';
import 'settings_palette.dart';
import 'settings_search_bar.dart';
import 'settings_section_list.dart';
import 'settings_tab_bar.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    if (_searchQuery.isEmpty && _searchController.text.isEmpty) {
      return;
    }

    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _resetSearchVisibility(BuildContext context) {
    _clearSearch();
    _searchFocusNode.unfocus();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    context.read<SettingsBloc>().add(const SettingsScrolled(0));
  }

  void _onSectionTap(
    BuildContext context,
    SettingsLoaded state,
    SettingsSection section,
  ) {
    if (section.action == SettingsSectionAction.navigate) {
      if (section.id == 'account_type') {
        context.push(RouteNames.settingsAccountType);
        return;
      }

      _showComingSoon(context, section.labelKey.tr());
      return;
    }

    if (section.action != SettingsSectionAction.bottomSheet) {
      _showComingSoon(context, section.labelKey.tr());
      return;
    }

    switch (section.target) {
      case 'appearance':
        _showAppearanceSheet(context, state);
      case 'notification':
        _showNotificationSheet(context, state);
      case 'language':
        _showLanguageSheet(context, state);
      default:
        _showComingSoon(context, section.labelKey.tr());
    }
  }


  void _showComingSoon(BuildContext context, String feature) {
    context.showSuccessSnackBar(
      message: Message(
        title: LocalizationConstants.profileComingSoonTitleKey.tr(),
        value: LocalizationConstants.profileComingSoonMessageKey.tr(
          namedArgs: <String, String>{'feature': feature},
        ),
      ),
    );
  }

  void _showAppearanceSheet(BuildContext context, SettingsLoaded state) {
    final SettingsPalette palette = SettingsPalette.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.sheet,
      barrierColor: palette.scrim,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        return AppearanceBottomSheet(
          options: state.appearanceOptions,
          onSelected: (AppearanceOption option) {
            context.read<SettingsBloc>().add(
                  SettingsAppearanceSelected(option.id),
                );
            unawaited(
              context.read<AppThemeCubit>().setThemeMode(
                    _themeModeFor(option.mode),
                  ),
            );
          },
        );
      },
    );
  }

  void _showNotificationSheet(BuildContext context, SettingsLoaded state) {
    final SettingsPalette palette = SettingsPalette.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.sheet,
      barrierColor: palette.scrim,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        return NotificationBottomSheet(
          settings: state.notificationSettings,
          onToggle: (setting) {
            context.read<SettingsBloc>().add(
                  SettingsNotificationToggled(
                    id: setting.id,
                    value: setting.value,
                  ),
                );
          },
        );
      },
    );
  }

  void _showLanguageSheet(BuildContext context, SettingsLoaded state) {
    final SettingsPalette palette = SettingsPalette.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.sheet,
      barrierColor: palette.scrim,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        return LanguageBottomSheet(
          options: state.languageOptions,
          onSelected: (LanguageOption option) {
            context.read<SettingsBloc>().add(
                  SettingsLanguageSelected(option.id),
                );
            unawaited(_setLocale(context, option.languageCode));
          },
        );
      },
    );
  }

  ThemeMode _themeModeFor(AppearanceMode mode) {
    return switch (mode) {
      AppearanceMode.light => ThemeMode.light,
      AppearanceMode.dark => ThemeMode.dark,
      AppearanceMode.system => ThemeMode.system,
    };
  }

  Future<void> _setLocale(BuildContext context, String languageCode) async {
    final Locale locale = SupportedLocales.fromCode(languageCode);
    if (context.locale == locale || !context.mounted) {
      return;
    }

    await context.setLocale(locale);
  }

  List<_SettingsSearchResult> _searchResults(SettingsLoaded state) {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return <_SettingsSearchResult>[];
    }

    final List<_SettingsSearchResult> results = <_SettingsSearchResult>[];

    for (final SettingsTab tab in state.tabs) {
      for (final SettingsSection section in state.sectionsForTab(tab)) {
        final String label = section.labelKey.tr();
        final String tabLabel = tab.labelKey.tr();
        final String searchable = '$label $tabLabel'.toLowerCase();

        if (searchable.contains(query)) {
          results.add(
            _SettingsSearchResult(
              tab: tab,
              label: label,
              tabLabel: tabLabel,
            ),
          );
        }
      }
    }

    return results;
  }

  void _onSearchResultSelected(
    BuildContext context,
    _SettingsSearchResult result,
  ) {
    _clearSearch();
    _searchFocusNode.unfocus();
    context.read<SettingsBloc>().add(SettingsTabChanged(result.tab));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen: (SettingsState previous, SettingsState current) =>
          current is SettingsLogoutSuccess,
      listener: (BuildContext context, SettingsState state) {
        if (state is SettingsLogoutSuccess) {
          context.goTo(RouteNames.auth);
        }
      },
      builder: (BuildContext context, SettingsState state) {
        final SettingsPalette palette = SettingsPalette.of(context);

        if (state is SettingsLoading) {
          return Scaffold(
            backgroundColor: palette.background,
            body: Center(
              child: CircularProgressIndicator(color: palette.accent),
            ),
          );
        }

        if (state is SettingsFailure) {
          return Scaffold(
            backgroundColor: palette.background,
            body: Center(child: Text(state.message.tr())),
          );
        }

        if (state is! SettingsLoaded) {
          return const Scaffold(body: SizedBox.shrink());
        }

        final double searchOpacity =
            ((state.scrollOffset - 100) / 80).clamp(0, 1);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: palette.header,
            statusBarIconBrightness:
                palette.isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: palette.background,
            systemNavigationBarIconBrightness:
                palette.isDark ? Brightness.light : Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: palette.background,
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollUpdateNotification) {
                  context.read<SettingsBloc>().add(
                        SettingsScrolled(notification.metrics.pixels),
                      );
                }
                return false;
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SettingsHeader(activeTab: state.activeTab),
                  ),
                  SliverToBoxAdapter(
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: searchOpacity,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: searchOpacity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SettingsSearchBar(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: _onSearchChanged,
                              ),
                              _SettingsSearchResultsDropdown(
                                results: _searchResults(state),
                                onSelected: (result) {
                                  _onSearchResultSelected(context, result);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SettingsTabBar(
                      tabs: state.tabs,
                      activeTab: state.activeTab,
                      onTabChanged: (SettingsTab tab) {
                        _resetSearchVisibility(context);
                        context.read<SettingsBloc>().add(
                              SettingsTabChanged(tab),
                            );
                      },
                    ),
                  ),
                  SettingsSectionList(
                    activeTab: state.activeTab,
                    sections: state.sectionsForTab(state.activeTab),
                    onSectionTap: (SettingsSection section) {
                      _onSectionTap(context, state, section);
                    },
                    onLogoutTap: () {
                      context.read<SettingsBloc>().add(
                            const SettingsLogoutRequested(),
                          );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsSearchResult {
  const _SettingsSearchResult({
    required this.tab,
    required this.label,
    required this.tabLabel,
  });

  final SettingsTab tab;
  final String label;
  final String tabLabel;
}

class _SettingsSearchResultsDropdown extends StatelessWidget {
  const _SettingsSearchResultsDropdown({
    required this.results,
    required this.onSelected,
  });

  final List<_SettingsSearchResult> results;
  final ValueChanged<_SettingsSearchResult> onSelected;

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);

    if (results.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(40, 0, 40, 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.sheet,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.border),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(palette.isDark ? 0.28 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: results.length,
              separatorBuilder: (context, index) {
                return Divider(
                  height: 1,
                  thickness: 1,
                  color: palette.border.withOpacity(0.45),
                );
              },
              itemBuilder: (BuildContext context, int index) {
                final _SettingsSearchResult result = results[index];

                return InkWell(
                  onTap: () => onSelected(result),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                result.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: palette.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                result.tabLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: palette.inactiveIcon,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          color: palette.inactiveIcon,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
