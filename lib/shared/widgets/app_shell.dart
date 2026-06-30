import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../config/routes/route_names.dart';
import '../../core/di/injection_container.dart';
import '../../core/localization/localization_constants.dart';
import '../../core/localization/localization_service.dart';
import '../../core/localization/supported_locales.dart';
import '../../core/services/storage_service.dart';
import '../../features/account/data/user_data_local_data_source.dart';
import '../../features/auth/data/datasources/user_local_datasource.dart';
import '../../features/auth/data/models/user_model.dart';
import '../shared.dart';

enum UserDataTab {
  profile,
  edit,
  idCard,
  badges,
  history,
  settings,
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final UserDataLocalDataSource _dataSource =
      UserDataLocalDataSource(sl<StorageService>());
  final UserLocalDataSource _authDataSource = sl<UserLocalDataSource>();

  UserDataTab _selectedTab = UserDataTab.profile;
  UserDataSnapshot? _snapshot;
  bool _loading = true;

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
      fullName: user.fullName.isNotEmpty ? user.fullName : localSnapshot.fullName,
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
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String? profileImage = snapshot.profileImage;
    final bool hasImage = profileImage != null && profileImage.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            toolbarHeight: 64,
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
                size: 24,
              ),
            ),
            centerTitle: true,
            title: Text(
              'settings',
              style: AppTextStyles.h3.copyWith(color: AppColors.libraryGreen),
            ),
            actions: [
              IconButton(
                onPressed: () => _openEditor(_selectedTab),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedEdit03,
                  color: AppColors.libraryGreen,
                  size: 24,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.radius40),
                    bottomRight: Radius.circular(AppRadius.radius40),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    // Avatar
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.card,
                          width: 4,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasImage
                          ? Image.file(
                              File(profileImage),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedUser,
                                  color: AppColors.primary500,
                                  size: 64,
                                ),
                              ),
                            )
                          : Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedUser,
                                color: AppColors.primary500,
                                size: 64,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                color: Colors.white,
                child: _buildTabBar(),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.spacing16),
                _buildContent(snapshot),
                const SizedBox(height: AppSpacing.spacing24),
                _buildLogoutButton(),
                const SizedBox(height: AppSpacing.spacing32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        primary: false,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing24,
        ),
        child: Row(
          children: [
            _IconTab(
              icon: HugeIcons.strokeRoundedUser,
              label: 'Profile',
              selected: _selectedTab == UserDataTab.profile,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.profile;
              }),
            ),
            _IconTab(
              icon: HugeIcons.strokeRoundedPaintBrush02,
              label: '',
              selected: _selectedTab == UserDataTab.edit,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.edit;
              }),
            ),
            _IconTab(
              icon: HugeIcons.strokeRoundedId,
              label: '',
              selected: _selectedTab == UserDataTab.idCard,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.idCard;
              }),
            ),
            _IconTab(
              icon: HugeIcons.strokeRoundedAward01,
              label: '',
              selected: _selectedTab == UserDataTab.badges,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.badges;
              }),
            ),
            _IconTab(
              icon: HugeIcons.strokeRoundedClock01,
              label: '',
              selected: _selectedTab == UserDataTab.history,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.history;
              }),
            ),
            _IconTab(
              icon: HugeIcons.strokeRoundedSettings01,
              label: '',
              selected: _selectedTab == UserDataTab.settings,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.settings;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(UserDataSnapshot snapshot) {
    return switch (_selectedTab) {
      UserDataTab.profile => _buildProfileMenu(snapshot),
      UserDataTab.edit => _buildDataCard(snapshot),
      UserDataTab.idCard => _buildDataCard(snapshot),
      UserDataTab.badges => _buildDataCard(snapshot),
      UserDataTab.history => _buildDataCard(snapshot),
      UserDataTab.settings => _buildDataCard(snapshot),
    };
  }

  Widget _buildProfileMenu(UserDataSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
      child: Column(
        children: [
          _MenuItem(
            title: 'My Personal Information',
            onTap: () => _openEditor(UserDataTab.idCard),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          _MenuItem(
            title: 'My Locations',
            onTap: () {
              context.showSuccessSnackBar(
                message: const Message(
                  title: 'Coming Soon',
                  value: 'Locations feature is under development.',
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.spacing8),
          _MenuItem(
            title: 'Payment Information',
            onTap: () => _openEditor(UserDataTab.badges),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          _MenuItem(
            title: 'My Personal Files',
            onTap: () => _openEditor(UserDataTab.badges),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          _MenuItem(
            title: 'My Badges',
            onTap: () => setState(() => _selectedTab = UserDataTab.badges),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(UserDataSnapshot snapshot) {
    if (_selectedTab == UserDataTab.settings) {
      return _buildSettingsCard(snapshot);
    }

    final List<String> values = switch (_selectedTab) {
      UserDataTab.edit => <String>[
          snapshot.fullName,
          snapshot.birthDate,
          snapshot.country,
          snapshot.phone,
        ],
      UserDataTab.idCard => <String>[
          snapshot.fullName,
          snapshot.birthDate,
          snapshot.country,
          snapshot.phone,
        ],
      UserDataTab.badges => <String>[
          snapshot.budgetBalance,
        ],
      UserDataTab.history => snapshot.operations,
      UserDataTab.settings => <String>[
          snapshot.theme,
          snapshot.language,
        ],
      UserDataTab.profile => <String>[],
    };

    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.radius32),
          border: Border.all(
            color: AppColors.primary100,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: values.asMap().entries.map((entry) {
            final int index = entry.key;
            final String value = entry.value;
            final bool isLast = index == values.length - 1;

            return Column(
              children: [
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
      ),
    );
  }

  Widget _buildSettingsCard(UserDataSnapshot snapshot) {
    final String languageLabel = snapshot.language == 'ar'
        ? LocalizationConstants.userDataArabicLanguageKey.tr()
        : LocalizationConstants.userDataEnglishLanguageKey.tr();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.radius32),
              border: Border.all(
                color: AppColors.primary100,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Theme row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing20,
                    vertical: AppSpacing.spacing16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalizationConstants.userDataThemeKey.tr(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.theme,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  indent: AppSpacing.spacing20,
                  endIndent: AppSpacing.spacing20,
                  color: AppColors.primary100,
                ),
                // Language row with change button
                InkWell(
                  onTap: () => _showLanguagePicker(snapshot),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.radius32),
                    bottomRight: Radius.circular(AppRadius.radius32),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacing20,
                      vertical: AppSpacing.spacing16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocalizationConstants.userDataLanguageKey.tr(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                languageLabel,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary50,
                            borderRadius: BorderRadius.circular(AppRadius.radius16),
                          ),
                          child: Text(
                            LocalizationConstants.userDataChangeLanguageKey.tr(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary600,
                              fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  Future<void> _showLanguagePicker(UserDataSnapshot snapshot) async {
    final Locale? selectedLocale = await showModalBottomSheet<Locale>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          margin: const EdgeInsets.all(AppSpacing.spacing16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.radius32),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spacing24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    LocalizationConstants.userDataChangeLanguageKey.tr(),
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.spacing20),
                  _LanguageOption(
                    label: LocalizationConstants.userDataEnglishLanguageKey.tr(),
                    locale: SupportedLocales.english,
                    isSelected: snapshot.language == 'en' ||
                        context.locale == SupportedLocales.english,
                    onTap: () => Navigator.of(ctx).pop(SupportedLocales.english),
                  ),
                  const SizedBox(height: AppSpacing.spacing12),
                  _LanguageOption(
                    label: LocalizationConstants.userDataArabicLanguageKey.tr(),
                    locale: SupportedLocales.arabic,
                    isSelected: snapshot.language == 'ar' ||
                        context.locale == SupportedLocales.arabic,
                    onTap: () => Navigator.of(ctx).pop(SupportedLocales.arabic),
                  ),
                  const SizedBox(height: AppSpacing.spacing16),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedLocale != null && mounted) {
      await context.setLocale(selectedLocale);
      final String languageCode = selectedLocale.languageCode;
      await _dataSource.saveAppearance(
        theme: snapshot.theme,
        language: languageCode,
      );
      await _load();
    }
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
      child: SizedBox(
        width: double.infinity,
        height: AppDimensions.onboardingButtonHeight,
        child: FilledButton(
          onPressed: _logout,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error500,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radius32),
            ),
          ),
          child: Text(LocalizationConstants.userDataLogoutKey.tr()),
        ),
      ),
    );
  }

  String _tabTitle(BuildContext context) {
    return switch (_selectedTab) {
      UserDataTab.profile => 'Profile',
      UserDataTab.edit => 'Edit',
      UserDataTab.idCard => 'ID Card',
      UserDataTab.badges => 'Badges',
      UserDataTab.history => 'History',
      UserDataTab.settings => 'Settings',
    };
  }
}

// ---------------------------------------------------------------------------
// Icon-only tab (active tab shows label too)
// ---------------------------------------------------------------------------
class _IconTab extends StatelessWidget {
  const _IconTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
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
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: selected ? AppSpacing.spacing16 : AppSpacing.spacing12,
            vertical: AppSpacing.spacing12,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary50 : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.radius16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: icon,
                color: AppColors.primary600,
                size: 24,
              ),
              if (selected && label.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
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
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing20,
          vertical: AppSpacing.spacing16,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary50,
          borderRadius: BorderRadius.circular(AppRadius.radius16),
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
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Language Option
// =============================================================================
class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing20,
          vertical: AppSpacing.spacing16,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary50 : AppColors.primary100,
          borderRadius: BorderRadius.circular(AppRadius.radius16),
          border: Border.all(
            color: isSelected ? AppColors.primary600 : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isSelected ? AppColors.primary600 : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                color: AppColors.primary600,
                size: 24,
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
        _twoController.text = widget.snapshot.language == 'ar' ? 'Arabic' : 'English';
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
                  AppColors.libraryGreen.withOpacity(0.92),
                  AppColors.primary900.withOpacity(0.96),
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
                              LocalizationConstants.userDataEditMultilineHintKey.tr(),
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
                                LocalizationConstants.userDataSaveChangesKey.tr(),
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
      UserDataTab.idCard =>
        LocalizationConstants.userDataFullNameKey.tr(),
      UserDataTab.badges =>
        LocalizationConstants.userDataBudgetBalanceKey.tr(),
      UserDataTab.settings =>
        LocalizationConstants.userDataThemeKey.tr(),
      UserDataTab.history =>
        LocalizationConstants.userDataOperationsKey.tr(),
    };
  }

  String _labelForSecondaryField(BuildContext context) {
    return switch (widget.tab) {
      UserDataTab.profile ||
      UserDataTab.edit ||
      UserDataTab.idCard =>
        LocalizationConstants.userDataBirthDateKey.tr(),
      UserDataTab.settings =>
        LocalizationConstants.userDataLanguageKey.tr(),
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
      borderRadius: BorderRadius.circular(28 /*AppRadius.radius28*/),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 78,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing12,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.18),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
            borderRadius: BorderRadius.circular(28 /*AppRadius.radius28*/),
          ),
          child: Row(
            children: [
              if (rtl) ...[
                _HeaderButton(
                  icon: actionIcon,
                  onPressed: onActionPressed,
                ),
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
                _HeaderButton(
                  icon: actionIcon,
                  onPressed: onActionPressed,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onPressed,
  });

  final List<List<dynamic>> icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _IconButtonShell(
      onPressed: onPressed,
      icon: icon,
      size: 52,
      backgroundColor: Colors.white.withOpacity(0.12),
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
          borderRadius: BorderRadius.circular(18 /*AppRadius.radius18*/),
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
