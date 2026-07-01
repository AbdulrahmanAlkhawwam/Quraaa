import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import 'settings_search_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const double _expandedHeight = 292;
  static const double _toolbarHeight = 64;
  static const double _collapsedHeight = 208;
  static const double _bottomTabsHeight = 76;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (BuildContext context, ProfileState profileState) {
        final String? profileName = profileState.profile?.fullName.trim();
        final String displayName =
            profileName != null && profileName.isNotEmpty
                ? profileName
                : 'Quraaa User';

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: AppColors.neutralBackground,
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    backgroundColor: AppColors.primary50,
                    surfaceTintColor: Colors.transparent,
                    foregroundColor: AppColors.libraryGreen,
                    pinned: true,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    toolbarHeight: _toolbarHeight,
                    collapsedHeight: _collapsedHeight,
                    expandedHeight: _expandedHeight,
                    leading: IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.home);
                        }
                      },
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: AppColors.libraryGreen,
                        size: 24,
                      ),
                    ),
                    flexibleSpace: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        final bool collapsed = constraints.biggest.height <=
                            _collapsedHeight + 8;

                        return AnimatedSwitcher(
                          duration: AppDurations.short,
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: collapsed
                              ? _CollapsedSettingsHeader(
                                  key: const ValueKey<String>('collapsed'),
                                )
                              : _ExpandedSettingsHeader(
                                  key: const ValueKey<String>('expanded'),
                                  displayName: displayName,
                                ),
                        );
                      },
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(_bottomTabsHeight),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.spacing16,
                          0,
                          AppSpacing.spacing16,
                          AppSpacing.spacing16,
                        ),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.radius24),
                            border: Border.all(color: AppColors.primary100),
                          ),
                          child: TabBar(
                            isScrollable: true,
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: AppColors.libraryGreen,
                              borderRadius: BorderRadius.circular(AppRadius.radius24),
                            ),
                            labelColor: AppColors.card,
                            unselectedLabelColor: AppColors.textSecondary,
                            labelStyle: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: AppTextStyles.bodyMedium,
                            tabs: <Tab>[
                              Tab(
                                text: LocalizationConstants.settingsTabGeneralKey.tr(),
                              ),
                              Tab(
                                text: LocalizationConstants.settingsTabNotificationKey
                                    .tr(),
                              ),
                              Tab(
                                text: LocalizationConstants.settingsTabSecurityKey.tr(),
                              ),
                              Tab(
                                text: LocalizationConstants.settingsTabLanguagesKey.tr(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: <Widget>[
                  _SettingsTabScrollView(
                    title: LocalizationConstants.settingsTabGeneralKey.tr(),
                    subtitle: LocalizationConstants.settingsSearchSubtitleKey.tr(),
                    children: <Widget>[
                      SettingsActionGroup(
                        children: <Widget>[
                          SettingsActionButton(
                            title:
                                LocalizationConstants.settingsAccountTypeKey.tr(),
                            subtitle:
                                LocalizationConstants.settingsAccountTypeSubtitleKey
                                    .tr(),
                            leadingIcon: HugeIcons.strokeRoundedUserAccount,
                            onTap: () => context.push(
                              RouteNames.subscriptionAccountType,
                            ),
                          ),
                          SettingsActionButton(
                            title: LocalizationConstants
                                .userDataSettingsAppearanceKey
                                .tr(),
                            subtitle: LocalizationConstants
                                .settingsAppearanceSubtitleKey
                                .tr(),
                            leadingIcon: HugeIcons.strokeRoundedSettings01,
                            onTap: () => ThemeBottomSheet.show(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _SettingsTabScrollView(
                    title: LocalizationConstants.settingsTabNotificationKey.tr(),
                    subtitle: LocalizationConstants.settingsSearchSubtitleKey.tr(),
                    children: <Widget>[
                      SettingsActionGroup(
                        children: <Widget>[
                          SettingsActionButton(
                            title: LocalizationConstants
                                .userDataSettingsNotificationManagementKey
                                .tr(),
                            subtitle: LocalizationConstants
                                .settingsNotificationsSubtitleKey
                                .tr(),
                            leadingIcon: HugeIcons.strokeRoundedNotification01,
                            onTap: () => _showNotificationBottomSheet(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _SettingsTabScrollView(
                    title: LocalizationConstants.settingsTabSecurityKey.tr(),
                    subtitle: LocalizationConstants.settingsSearchSubtitleKey.tr(),
                    children: <Widget>[
                      SettingsActionGroup(
                        children: <Widget>[
                          SettingsActionButton(
                            title: LocalizationConstants
                                .userDataSettingsSecurityKey
                                .tr(),
                            subtitle: LocalizationConstants
                                .settingsSecuritySubtitleKey
                                .tr(),
                            leadingIcon: HugeIcons.strokeRoundedSettings01,
                            onTap: () => _showPlaceholder(
                              context,
                              LocalizationConstants.settingsTabSecurityKey.tr(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _SettingsTabScrollView(
                    title: LocalizationConstants.settingsTabLanguagesKey.tr(),
                    subtitle: LocalizationConstants.settingsSearchSubtitleKey.tr(),
                    children: <Widget>[
                      SettingsActionGroup(
                        children: <Widget>[
                          SettingsActionButton(
                            title: LocalizationConstants
                                .userDataSettingsLanguagesKey
                                .tr(),
                            subtitle: LocalizationConstants
                                .settingsLanguagesSubtitleKey
                                .tr(),
                            onTap: () => LanguageBottomSheet.show(context),
                          ),
                        ],
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

  void _showPlaceholder(BuildContext context, String title) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(
            LocalizationConstants.profileDialogNotDesignedContentKey.tr(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(LocalizationConstants.commonCloseKey.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationBottomSheet(BuildContext context) {
    NotificationBottomSheet.show(
      context,
      title: LocalizationConstants.settingsNotificationTitleKey.tr(),
      body: LocalizationConstants.settingsNotificationBodyKey.tr(),
      route: RouteNames.notificationPermission,
      buttonLabel: LocalizationConstants.settingsNotificationActionKey.tr(),
    );
  }
}

class _ExpandedSettingsHeader extends StatelessWidget {
  const _ExpandedSettingsHeader({
    super.key,
    required this.displayName,
  });

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spacing24,
        56,
        AppSpacing.spacing24,
        AppSpacing.spacing24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const Spacer(),
          Center(
            child: const _UserAvatar(),
          ),
          const SizedBox(height: AppSpacing.spacing20),
          Center(
            child: Text(
              displayName,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.libraryGreen,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Center(
            child: Text(
              LocalizationConstants.settingsScreenTitleKey.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsedSettingsHeader extends StatelessWidget {
  const _CollapsedSettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ExpandableSearchBar(
        title: LocalizationConstants.settingsSearchTitleKey.tr(),
        subtitle: LocalizationConstants.settingsSearchSubtitleKey.tr(),
        openBuilder: (_) => const SettingsSearchScreen(),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing16,
        ),
        height: 58,
      ),
    );
  }
}

class _SettingsTabScrollView extends StatelessWidget {
  const _SettingsTabScrollView({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spacing16,
        AppSpacing.spacing16,
        AppSpacing.spacing16,
        AppSpacing.spacing32,
      ),
      children: <Widget>[
        Text(
          title,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing6),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing20),
        ..._separate(children),
      ],
    );
  }

  List<Widget> _separate(List<Widget> items) {
    final List<Widget> result = <Widget>[];
    for (int index = 0; index < items.length; index++) {
      result.add(items[index]);
      if (index != items.length - 1) {
        result.add(const SizedBox(height: AppSpacing.spacing16));
      }
    }
    return result;
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  static const String _avatarSvg = '''
<svg width="180" height="180" viewBox="0 0 180 180" fill="none" xmlns="http://www.w3.org/2000/svg">
<circle cx="90" cy="90" r="90" fill="#F0F9EC"/>
<circle cx="90" cy="70" r="30" fill="#5FAC3A"/>
<path d="M42 146C51.5 120 69 108 90 108C111 108 128.5 120 138 146" fill="#203913"/>
<path d="M62 146C66 132 77 122 90 122C103 122 114 132 118 146" fill="#79C553"/>
<circle cx="90" cy="70" r="14" fill="#F7FFF2"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        color: AppColors.primary100,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.card, width: 4),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppImage(
        _avatarSvg,
        fit: BoxFit.cover,
      ),
    );
  }
}
