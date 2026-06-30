import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../config/routes/route_names.dart';
import '../../core/di/injection_container.dart';
import '../../core/localization/localization_constants.dart';
import '../../core/services/storage_service.dart';
import '../../features/account/data/user_data_local_data_source.dart';
import '../../features/auth/data/datasources/user_local_datasource.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/profile/data/models/profile_model.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/extensions/profile_model_ui_extensions.dart';
import '../../features/profile/presentation/bloc/profile_state.dart';
import '../../features/profile/presentation/widgets/profile_info_shimmer.dart';
import '../../features/settings/presentation/widgets/profile_avatar.dart';
import '../shared.dart';

const double _backIconSize = 24;
const double _chevronIconSize = 20;

enum UserDataTab { profile, edit, idCard, badges, history, settings }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final UserDataLocalDataSource _dataSource = sl<UserDataLocalDataSource>();
  final UserLocalDataSource _authDataSource = sl<UserLocalDataSource>();

  UserDataTab _selectedTab = UserDataTab.settings;
  UserDataSnapshot? _snapshot;
  bool _loading = true;

  static const double _headerExpandedHeight = 340;
  static const double _headerToolbarHeight = 64;
  static const double _headerBottomHeight = 212;
  static const double _avatarOverlap = 40;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    UserDataSnapshot snapshot = await _dataSource.load();

    // Prefer the authenticated user profile from cache so the screen shows
    // the right data when the user is offline. Guest users keep the local
    // fallback snapshot.
    final UserModel? cachedUser = await _authDataSource.getUser();
    if (cachedUser != null) {
      snapshot = _mergeAuthUser(snapshot, cachedUser);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  UserDataSnapshot _mergeAuthUser(
    UserDataSnapshot localSnapshot,
    UserModel user,
  ) {
    return UserDataSnapshot(
      fullName: user.fullName.isNotEmpty
          ? user.fullName
          : localSnapshot.fullName,
      birthDate: user.birthday ?? localSnapshot.birthDate,
      country: user.country ?? localSnapshot.country,
      phone: user.phoneNumber ?? localSnapshot.phone,
      theme: localSnapshot.theme,
      language: user.language ?? localSnapshot.language,
      bookmarks: localSnapshot.bookmarks,
      budgetBalance: localSnapshot.budgetBalance,
      libraryItems: localSnapshot.libraryItems,
      operations: localSnapshot.operations,
      profileImage: localSnapshot.profileImage,
    );
  }

  UserDataSnapshot _mergeProfile(
    UserDataSnapshot localSnapshot,
    ProfileModel? profile,
  ) {
    if (profile == null) {
      return localSnapshot;
    }

    return UserDataSnapshot(
      fullName: profile.fullName.isNotEmpty
          ? profile.fullName
          : localSnapshot.fullName,
      birthDate: profile.dateOfBirth ?? localSnapshot.birthDate,
      country: localSnapshot.country,
      phone: profile.phoneNumber ?? localSnapshot.phone,
      theme: localSnapshot.theme,
      language: localSnapshot.language,
      bookmarks: localSnapshot.bookmarks,
      budgetBalance: localSnapshot.budgetBalance,
      libraryItems: localSnapshot.libraryItems,
      operations: localSnapshot.operations,
      profileImage: profile.profileImageUrl ?? localSnapshot.profileImage,
    );
  }

  Future<void> _logout() async {
    await sl<StorageService>().clearAll();
    if (!mounted) {
      return;
    }
    context.goTo(RouteNames.auth);
  }

  Future<void> _openEditor(UserDataTab tab) async {
    if (_snapshot == null) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => UserDataEditScreen(
          tab: tab,
          snapshot: _snapshot!,
          dataSource: _dataSource,
          authDataSource: _authDataSource,
          onSaved: _load,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserDataSnapshot? snapshot = _snapshot;

    if (_loading || snapshot == null) {
      return const Scaffold(
        backgroundColor: AppColors.neutralBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (ProfileState previous, ProfileState current) =>
          current.error != previous.error ||
          current.requiresLogin != previous.requiresLogin,
      listener: (BuildContext context, ProfileState profileState) {
        if (profileState.error != null) {
          context.showResolvedErrorSnackBar(profileState.error);
        }
        if (profileState.requiresLogin && context.mounted) {
          context.goTo(RouteNames.auth);
        }
      },
      builder: (BuildContext context, ProfileState profileState) {
        final UserDataSnapshot mergedSnapshot = _mergeProfile(
          snapshot,
          profileState.profile,
        );
        final String? profileImageUrl = mergedSnapshot.profileImage;

        return Scaffold(
          backgroundColor: AppColors.neutralBackground,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: _headerExpandedHeight,
                toolbarHeight: _headerToolbarHeight,
                pinned: true,
                backgroundColor: AppColors.primary50,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.radius40),
                    bottomRight: Radius.circular(AppRadius.radius40),
                  ),
                ),
                leading: IconButton(
                  onPressed: () => context.back(),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    color: AppColors.libraryGreen,
                    size: _backIconSize,
                  ),
                ),
                centerTitle: true,
                title: Text(
                  _tabTitle(context),
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.libraryGreen,
                  ),
                ),
                flexibleSpace: const FlexibleSpaceBar(
                  background: ColoredBox(color: AppColors.primary50),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(_headerBottomHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -_avatarOverlap),
                        child: ProfileAvatar(imagePath: profileImageUrl),
                      ),
                      _buildTabBar(),
                      const SizedBox(height: AppSpacing.spacing16),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing24,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.spacing8),
                      _buildContent(mergedSnapshot, profileState),
                      const SizedBox(height: AppSpacing.spacing24),
                      _buildLogoutButton(),
                      const SizedBox(height: AppSpacing.spacing32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        primary: false,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
        child: Row(
          children: [
            _buildTab(
              LocalizationConstants.userDataProfileTabKey.tr(),
              UserDataTab.profile,
            ),
            _buildTab(
              LocalizationConstants.userDataSettingsTabKey.tr(),
              UserDataTab.settings,
            ),
            _buildTab(
              LocalizationConstants.userDataBooksTabKey.tr(),
              UserDataTab.edit,
            ),
            _buildTab(
              LocalizationConstants.userDataBadgesTabKey.tr(),
              UserDataTab.badges,
            ),
            _buildTab(
              LocalizationConstants.userDataFoldersTabKey.tr(),
              UserDataTab.history,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, UserDataTab tab) {
    return _SegmentTab(
      label: label,
      selected: _selectedTab == tab,
      onTap: () => setState(() => _selectedTab = tab),
    );
  }

  Widget _buildContent(UserDataSnapshot snapshot, ProfileState profileState) {
    return switch (_selectedTab) {
      UserDataTab.profile => _buildProfileMenu(snapshot, profileState),
      UserDataTab.settings => _buildSettingsCard(),
      UserDataTab.edit ||
      UserDataTab.idCard ||
      UserDataTab.badges ||
      UserDataTab.history => _buildDataCard(snapshot),
    };
  }

  Widget _buildProfileMenu(
    UserDataSnapshot snapshot,
    ProfileState profileState,
  ) {
    final List<_ProfileMenuEntry> entries = <_ProfileMenuEntry>[
      _ProfileMenuEntry(
        title: 'My Personal Information',
        onTap: () => _openEditor(UserDataTab.idCard),
      ),
      _ProfileMenuEntry(
        title: 'My Locations',
        onTap: () =>
            _showComingSoonSnack('Locations feature is under development.'),
      ),
      _ProfileMenuEntry(
        title: 'Payment Information',
        onTap: () => _openEditor(UserDataTab.badges),
      ),
      _ProfileMenuEntry(
        title: 'My Personal Files',
        onTap: () => _openEditor(UserDataTab.badges),
      ),
      _ProfileMenuEntry(
        title: 'My Badges',
        onTap: () => setState(() => _selectedTab = UserDataTab.badges),
      ),
    ];

    return Column(
      children: <Widget>[
        _buildProfileInfoCard(snapshot, profileState),
        const SizedBox(height: AppSpacing.spacing16),
        ..._intersperse(
          entries
              .map((entry) => _MenuItem(title: entry.title, onTap: entry.onTap))
              .toList(),
          const SizedBox(height: AppSpacing.spacing8),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard(
    UserDataSnapshot snapshot,
    ProfileState profileState,
  ) {
    if (profileState.loading) {
      return const ProfileInfoShimmer();
    }

    final ProfileModel? profile = profileState.profile;
    if (profile == null) {
      return const SizedBox.shrink();
    }

    return _DataCard(
      values: <String>[
        profile.fullName,
        profile.phoneNumber ?? snapshot.phone,
        profile.dateOfBirth ?? snapshot.birthDate,
        profile.localizedGenderLabel,
      ],
    );
  }

  void _showComingSoonSnack(String message) {
    context.showSuccessSnackBar(
      message: Message(title: 'Coming Soon', value: message),
    );
  }

  List<Widget> _intersperse(List<Widget> items, Widget separator) {
    if (items.isEmpty) {
      return items;
    }

    final List<Widget> result = <Widget>[items.first];
    for (int i = 1; i < items.length; i++) {
      result
        ..add(separator)
        ..add(items[i]);
    }
    return result;
  }

  Widget _buildDataCard(UserDataSnapshot snapshot) {
    final List<String> values = switch (_selectedTab) {
      UserDataTab.edit || UserDataTab.idCard => <String>[
        snapshot.fullName,
        snapshot.birthDate,
        snapshot.country,
        snapshot.phone,
      ],
      UserDataTab.badges => <String>[snapshot.budgetBalance],
      UserDataTab.history => snapshot.operations,
      UserDataTab.settings => <String>[snapshot.theme, snapshot.language],
      UserDataTab.profile => <String>[],
    };

    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    return _DataCard(values: values);
  }

  Widget _buildSettingsCard() {
    final List<String> settingsTitles = <String>[
      LocalizationConstants.userDataSettingsAppearanceKey.tr(),
      LocalizationConstants.userDataSettingsNotificationManagementKey.tr(),
      LocalizationConstants.userDataSettingsSecurityKey.tr(),
      LocalizationConstants.userDataSettingsLanguagesKey.tr(),
    ];

    return Column(
      children: _intersperse(
        settingsTitles
            .map(
              (title) => _MenuItem(
                title: title,
                backgroundColor: AppColors.card,
                borderRadius: AppRadius.radius24,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing20,
                  vertical: AppSpacing.spacing20,
                ),
                boxShadow: AppShadows.elevation1,
                onTap: () => _showPlaceholderDialog(title),
              ),
            )
            .toList(),
        const SizedBox(height: AppSpacing.spacing8),
      ),
    );
  }

  void _showPlaceholderDialog(String title) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: const Text('This screen has not been designed yet.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.onboardingButtonHeight,
      child: FilledButton(
        onPressed: _logout,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error500,
          foregroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radius32),
          ),
        ),
        child: Text(LocalizationConstants.userDataLogoutKey.tr()),
      ),
    );
  }

  String _tabTitle(BuildContext context) {
    return switch (_selectedTab) {
      UserDataTab.profile => LocalizationConstants.userDataProfileTabKey.tr(),
      UserDataTab.edit => LocalizationConstants.userDataBooksTabKey.tr(),
      UserDataTab.idCard => LocalizationConstants.userDataProfileTabKey.tr(),
      UserDataTab.badges => LocalizationConstants.userDataBadgesTabKey.tr(),
      UserDataTab.history => LocalizationConstants.userDataFoldersTabKey.tr(),
      UserDataTab.settings => LocalizationConstants.userDataTitleKey.tr(),
    };
  }
}

// ---------------------------------------------------------------------------
// Data class describing a single entry in the profile menu.
// ---------------------------------------------------------------------------
class _ProfileMenuEntry {
  const _ProfileMenuEntry({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;
}

// ---------------------------------------------------------------------------
// Card that displays a list of read-only values separated by dividers.
// ---------------------------------------------------------------------------
class _DataCard extends StatelessWidget {
  const _DataCard({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.radius32),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: values.asMap().entries.map((entry) {
          final int index = entry.key;
          final String value = entry.value;
          final bool isLast = index == values.length - 1;

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing20,
                  vertical: AppSpacing.spacing16,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: AppSpacing.spacing20,
                  endIndent: AppSpacing.spacing20,
                  color: AppColors.primary100,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rounded segmented tab used in the account tab bar.
// ---------------------------------------------------------------------------
class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.spacing8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius16),
        child: AnimatedContainer(
          duration: AppDurations.short,
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? AppSpacing.spacing16 : AppSpacing.spacing12,
            vertical: AppSpacing.spacing12,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary600 : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.radius16),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: selected ? AppColors.card : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Menu item row with chevron
// ---------------------------------------------------------------------------
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.title,
    required this.onTap,
    this.backgroundColor = AppColors.primary50,
    this.borderRadius = AppRadius.radius16,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.spacing20,
      vertical: AppSpacing.spacing16,
    ),
    this.boxShadow,
  });

  final String title;
  final VoidCallback onTap;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: contentPadding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.primary600,
              size: _chevronIconSize,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// UserDataEditScreen
// =============================================================================
class UserDataEditScreen extends StatefulWidget {
  const UserDataEditScreen({
    super.key,
    required this.tab,
    required this.snapshot,
    required this.dataSource,
    required this.authDataSource,
    required this.onSaved,
  });

  final UserDataTab tab;
  final UserDataSnapshot snapshot;
  final UserDataLocalDataSource dataSource;
  final UserLocalDataSource authDataSource;
  final Future<void> Function() onSaved;

  @override
  State<UserDataEditScreen> createState() => _UserDataEditScreenState();
}

class _UserDataEditScreenState extends State<UserDataEditScreen> {
  late final TextEditingController _oneController;
  late final TextEditingController _twoController;
  late final TextEditingController _threeController;
  late final TextEditingController _fourController;

  @override
  void initState() {
    super.initState();
    _oneController = TextEditingController();
    _twoController = TextEditingController();
    _threeController = TextEditingController();
    _fourController = TextEditingController();
    _seed();
  }

  void _seed() {
    switch (widget.tab) {
      case UserDataTab.profile:
      case UserDataTab.edit:
      case UserDataTab.idCard:
        _oneController.text = widget.snapshot.fullName;
        _twoController.text = widget.snapshot.birthDate;
        _threeController.text = widget.snapshot.country;
        _fourController.text = widget.snapshot.phone;
        break;
      case UserDataTab.badges:
        _oneController.text = widget.snapshot.budgetBalance;
        break;
      case UserDataTab.settings:
        _oneController.text = widget.snapshot.theme;
        _twoController.text = widget.snapshot.language == 'ar'
            ? 'Arabic'
            : 'English';
        break;
      case UserDataTab.history:
        _oneController.text = widget.snapshot.operations.join('\n');
        break;
    }
  }

  @override
  void dispose() {
    _oneController.dispose();
    _twoController.dispose();
    _threeController.dispose();
    _fourController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    switch (widget.tab) {
      case UserDataTab.profile:
      case UserDataTab.edit:
      case UserDataTab.idCard:
        final String fullName = _oneController.text.trim();
        final String birthDate = _twoController.text.trim();
        final String country = _threeController.text.trim();
        final String phone = _fourController.text.trim();

        await widget.dataSource.saveProfile(
          fullName: fullName,
          birthDate: birthDate,
          country: country,
          phone: phone,
        );

        // Keep the authenticated user cache in sync so the profile screen
        // continues to show the right data when offline.
        final UserModel? cachedUser = await widget.authDataSource.getUser();
        if (cachedUser != null) {
          final List<String> nameParts = fullName.trim().split(' ');
          final String firstName = nameParts.first;
          final String? lastName = nameParts.length > 1
              ? nameParts.sublist(1).join(' ')
              : cachedUser.lastName;
          await widget.authDataSource.updateProfile(
            firstName: firstName,
            lastName: lastName,
            birthday: birthDate,
            country: country,
            phoneNumber: phone,
          );
        }
        break;
      case UserDataTab.badges:
        await widget.dataSource.saveBudgetBalance(_oneController.text.trim());
        break;
      case UserDataTab.settings:
        final String languageInput = _twoController.text.trim().toLowerCase();
        final String languageCode =
            (languageInput == 'arabic' || languageInput == 'ar') ? 'ar' : 'en';
        await widget.dataSource.saveAppearance(
          theme: _oneController.text.trim(),
          language: languageCode,
        );
        break;
      case UserDataTab.history:
        await widget.dataSource.saveOperations(
          _oneController.text
              .split('\n')
              .map((String value) => value.trim())
              .where((String value) => value.isNotEmpty)
              .toList(growable: false),
        );
        break;
    }

    await widget.onSaved();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final String title = switch (widget.tab) {
      UserDataTab.profile =>
        LocalizationConstants.userDataEditProfileTitleKey.tr(),
      UserDataTab.edit =>
        LocalizationConstants.userDataEditProfileTitleKey.tr(),
      UserDataTab.idCard =>
        LocalizationConstants.userDataEditProfileTitleKey.tr(),
      UserDataTab.badges =>
        LocalizationConstants.userDataEditBudgetsTitleKey.tr(),
      UserDataTab.settings =>
        LocalizationConstants.userDataEditAppearanceTitleKey.tr(),
      UserDataTab.history =>
        LocalizationConstants.userDataEditHistoryTitleKey.tr(),
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.libraryGreen.withValues(alpha: 0.92),
                  AppColors.primary900.withValues(alpha: 0.96),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spacing24),
              child: Column(
                children: [
                  _BlurHeader(
                    title: title,
                    onBackPressed: () => Navigator.of(context).pop(),
                    onActionPressed: () => Navigator.of(context).pop(),
                    actionIcon: HugeIcons.strokeRoundedPencil,
                    rtl: true /*context.isRTL*/,
                  ),
                  const SizedBox(height: AppSpacing.spacing20),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.spacing20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.radius32),
                      ),
                      child: ListView(
                        children: [
                          _field(
                            _oneController,
                            _labelForPrimaryField(context),
                          ),
                          if (_showsSecondField) ...[
                            const SizedBox(height: AppSpacing.spacing16),
                            _field(
                              _twoController,
                              _labelForSecondaryField(context),
                            ),
                          ],
                          if (_showsThirdField) ...[
                            const SizedBox(height: AppSpacing.spacing16),
                            _field(
                              _threeController,
                              LocalizationConstants.userDataCountryKey.tr(),
                            ),
                          ],
                          if (_showsFourthField) ...[
                            const SizedBox(height: AppSpacing.spacing16),
                            _field(
                              _fourController,
                              LocalizationConstants.userDataPhoneKey.tr(),
                            ),
                          ],
                          if (_isMultiLineTab) ...[
                            const SizedBox(height: AppSpacing.spacing12),
                            Text(
                              LocalizationConstants.userDataEditMultilineHintKey
                                  .tr(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.spacing20),
                          SizedBox(
                            width: double.infinity,
                            height: AppDimensions.onboardingButtonHeight,
                            child: FilledButton(
                              onPressed: _save,
                              child: Text(
                                LocalizationConstants.userDataSaveChangesKey
                                    .tr(),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacing12),
                          SizedBox(
                            width: double.infinity,
                            height: AppDimensions.onboardingButtonHeight,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                LocalizationConstants.userDataCancelKey.tr(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _showsSecondField =>
      widget.tab == UserDataTab.profile ||
      widget.tab == UserDataTab.edit ||
      widget.tab == UserDataTab.idCard ||
      widget.tab == UserDataTab.settings;

  bool get _showsThirdField =>
      widget.tab == UserDataTab.profile ||
      widget.tab == UserDataTab.edit ||
      widget.tab == UserDataTab.idCard;

  bool get _showsFourthField =>
      widget.tab == UserDataTab.profile ||
      widget.tab == UserDataTab.edit ||
      widget.tab == UserDataTab.idCard;

  bool get _isMultiLineTab => widget.tab == UserDataTab.history;

  String _labelForPrimaryField(BuildContext context) {
    return switch (widget.tab) {
      UserDataTab.profile ||
      UserDataTab.edit ||
      UserDataTab.idCard => LocalizationConstants.userDataFullNameKey.tr(),
      UserDataTab.badges => LocalizationConstants.userDataBudgetBalanceKey.tr(),
      UserDataTab.settings => LocalizationConstants.userDataThemeKey.tr(),
      UserDataTab.history => LocalizationConstants.userDataOperationsKey.tr(),
    };
  }

  String _labelForSecondaryField(BuildContext context) {
    return switch (widget.tab) {
      UserDataTab.profile ||
      UserDataTab.edit ||
      UserDataTab.idCard => LocalizationConstants.userDataBirthDateKey.tr(),
      UserDataTab.settings => LocalizationConstants.userDataLanguageKey.tr(),
      _ => '',
    };
  }

  Widget _field(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      maxLines: widget.tab == UserDataTab.history ? null : 1,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _BlurHeader extends StatelessWidget {
  const _BlurHeader({
    required this.title,
    required this.onBackPressed,
    required this.onActionPressed,
    required this.actionIcon,
    required this.rtl,
  });

  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback onActionPressed;
  final List<List<dynamic>> actionIcon;
  final bool rtl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              if (rtl) ...[
                _HeaderButton(icon: actionIcon, onPressed: onActionPressed),
                const Spacer(),
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const Spacer(),
                _HeaderButton(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  onPressed: onBackPressed,
                ),
              ] else ...[
                _HeaderButton(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  onPressed: onBackPressed,
                ),
                const Spacer(),
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const Spacer(),
                _HeaderButton(icon: actionIcon, onPressed: onActionPressed),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onPressed});

  final List<List<dynamic>> icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _IconButtonShell(
      onPressed: onPressed,
      icon: icon,
      size: 52,
      backgroundColor: Colors.white.withValues(alpha: 0.12),
      iconColor: Colors.white,
    );
  }
}

class _IconButtonShell extends StatelessWidget {
  const _IconButtonShell({
    required this.onPressed,
    required this.icon,
    required this.size,
    required this.backgroundColor,
    required this.iconColor,
  });

  final VoidCallback onPressed;
  final List<List<dynamic>> icon;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: HugeIcon(icon: icon, color: iconColor, size: 20),
          splashRadius: size / 2,
        ),
      ),
    );
  }
}
