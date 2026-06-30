import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../config/routes/route_names.dart';
import '../../core/di/injection_container.dart';
import '../../core/error_monitoring/user_context_provider.dart';
import '../../core/localization/localization_constants.dart';
import '../../core/services/storage_service.dart';
import '../../features/account/data/user_data_local_data_source.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../shared.dart';

enum UserDataTab {
  profile,
  appearance,
  bookmarks,
  budgets,
  library,
  history,
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final UserDataLocalDataSource _dataSource =
      UserDataLocalDataSource(sl<StorageService>());

  UserDataTab _selectedTab = UserDataTab.profile;
  UserDataSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final UserDataSnapshot snapshot = await _dataSource.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
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
          onSaved: _load,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserDataSnapshot? snapshot = _snapshot;

    return Scaffold(
      backgroundColor: AppColors.card,
      body: _loading || snapshot == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Top green area with app bar + avatar
                      _buildHeaderArea(),
                      const SizedBox(height: AppSpacing.spacing16),
                      // Tab bar
                      _buildTabBar(),
                      const SizedBox(height: AppSpacing.spacing16),
                      // User data card
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacing24,
                        ),
                        child: _buildDataCard(snapshot),
                      ),
                      const SizedBox(height: AppSpacing.spacing24),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderArea() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.radius40),
          bottomRight: Radius.circular(AppRadius.radius40),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top bar: back arrow, settings title, pencil icon
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing16,
                vertical: AppSpacing.spacing8,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.back(),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      color: AppColors.libraryGreen,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'settings',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.libraryGreen,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _openEditor(_selectedTab),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedEdit03,
                      color: AppColors.libraryGreen,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spacing8),
            // Circular avatar placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.card,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary200.withOpacity(0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser,
                  color: AppColors.primary500,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spacing24),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing24,
        ),
        child: Row(
          children: [
            _MaterialTab(
              icon: HugeIcons.strokeRoundedUser,
              label: LocalizationConstants.userDataProfileTabKey.tr(),
              selected: _selectedTab == UserDataTab.profile,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.profile;
              }),
            ),
            _MaterialTab(
              icon: HugeIcons.strokeRoundedPaintBrush02,
              label: LocalizationConstants.userDataAppearanceTabKey.tr(),
              selected: _selectedTab == UserDataTab.appearance,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.appearance;
              }),
            ),
            _MaterialTab(
              icon: HugeIcons.strokeRoundedBookmark01,
              label: LocalizationConstants.userDataBookmarksTabKey.tr(),
              selected: _selectedTab == UserDataTab.bookmarks,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.bookmarks;
              }),
            ),
            _MaterialTab(
              icon: HugeIcons.strokeRoundedWallet02,
              label: LocalizationConstants.userDataBudgetsTabKey.tr(),
              selected: _selectedTab == UserDataTab.budgets,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.budgets;
              }),
            ),
            _MaterialTab(
              icon: HugeIcons.strokeRoundedLibrary,
              label: LocalizationConstants.userDataLibraryTabKey.tr(),
              selected: _selectedTab == UserDataTab.library,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.library;
              }),
            ),
            _MaterialTab(
              icon: HugeIcons.strokeRoundedClock01,
              label: LocalizationConstants.userDataHistoryTabKey.tr(),
              selected: _selectedTab == UserDataTab.history,
              onTap: () => setState(() {
                _selectedTab = UserDataTab.history;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(UserDataSnapshot snapshot) {
    final List<String> values = switch (_selectedTab) {
      UserDataTab.profile => <String>[
          snapshot.fullName,
          snapshot.birthDate,
          snapshot.country,
          snapshot.phone,
        ],
      UserDataTab.appearance => <String>[
          snapshot.theme,
          snapshot.language,
        ],
      UserDataTab.bookmarks => snapshot.bookmarks,
      UserDataTab.budgets => <String>[
          snapshot.budgetBalance,
        ],
      UserDataTab.library => snapshot.libraryItems,
      UserDataTab.history => snapshot.operations,
    };

    return Column(
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
        const SizedBox(height: AppSpacing.spacing24),
        SizedBox(
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
      ],
    );
  }

  String _tabTitle(BuildContext context) {
    return switch (_selectedTab) {
      UserDataTab.profile => LocalizationConstants.userDataProfileTabKey.tr(),
      UserDataTab.appearance => LocalizationConstants.userDataAppearanceTabKey.tr(),
      UserDataTab.bookmarks => LocalizationConstants.userDataBookmarksTabKey.tr(),
      UserDataTab.budgets => LocalizationConstants.userDataBudgetsTabKey.tr(),
      UserDataTab.library => LocalizationConstants.userDataLibraryTabKey.tr(),
      UserDataTab.history => LocalizationConstants.userDataHistoryTabKey.tr(),
    };
  }
}

class _MaterialTab extends StatelessWidget {
  const _MaterialTab({
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
                color: selected ? AppColors.primary600 : AppColors.primary600,
                size: 24,
              ),
              if (selected) ...[
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

class UserDataEditScreen extends StatefulWidget {
  const UserDataEditScreen({
    super.key,
    required this.tab,
    required this.snapshot,
    required this.dataSource,
    required this.onSaved,
  });

  final UserDataTab tab;
  final UserDataSnapshot snapshot;
  final UserDataLocalDataSource dataSource;
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
        _oneController.text = widget.snapshot.fullName;
        _twoController.text = widget.snapshot.birthDate;
        _threeController.text = widget.snapshot.country;
        _fourController.text = widget.snapshot.phone;
        break;
      case UserDataTab.appearance:
        _oneController.text = widget.snapshot.theme;
        _twoController.text = widget.snapshot.language;
        break;
      case UserDataTab.bookmarks:
        _oneController.text = widget.snapshot.bookmarks.join('\n');
        break;
      case UserDataTab.budgets:
        _oneController.text = widget.snapshot.budgetBalance;
        break;
      case UserDataTab.library:
        _oneController.text = widget.snapshot.libraryItems.join('\n');
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
        await widget.dataSource.saveProfile(
          fullName: _oneController.text.trim(),
          birthDate: _twoController.text.trim(),
          country: _threeController.text.trim(),
          phone: _fourController.text.trim(),
        );
        break;
      case UserDataTab.appearance:
        await widget.dataSource.saveAppearance(
          theme: _oneController.text.trim(),
          language: _twoController.text.trim(),
        );
        break;
      case UserDataTab.bookmarks:
        await widget.dataSource.saveBookmarks(
          _oneController.text
              .split('\n')
              .map((String value) => value.trim())
              .where((String value) => value.isNotEmpty)
              .toList(growable: false),
        );
        break;
      case UserDataTab.budgets:
        await widget.dataSource.saveBudgetBalance(_oneController.text.trim());
        break;
      case UserDataTab.library:
        await widget.dataSource.saveLibraryItems(
          _oneController.text
              .split('\n')
              .map((String value) => value.trim())
              .where((String value) => value.isNotEmpty)
              .toList(growable: false),
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
      UserDataTab.appearance =>
        LocalizationConstants.userDataEditAppearanceTitleKey.tr(),
      UserDataTab.bookmarks =>
        LocalizationConstants.userDataEditBookmarksTitleKey.tr(),
      UserDataTab.budgets =>
        LocalizationConstants.userDataEditBudgetsTitleKey.tr(),
      UserDataTab.library =>
        LocalizationConstants.userDataEditLibraryTitleKey.tr(),
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
      widget.tab == UserDataTab.profile || widget.tab == UserDataTab.appearance;

  bool get _showsThirdField => widget.tab == UserDataTab.profile;

  bool get _showsFourthField => widget.tab == UserDataTab.profile;

  bool get _isMultiLineTab =>
      widget.tab == UserDataTab.bookmarks ||
      widget.tab == UserDataTab.library ||
      widget.tab == UserDataTab.history;

  String _labelForPrimaryField(BuildContext context) {
    return switch (widget.tab) {
      UserDataTab.profile => LocalizationConstants.userDataFullNameKey.tr(),
      UserDataTab.appearance => LocalizationConstants.userDataThemeKey.tr(),
      UserDataTab.bookmarks =>
        LocalizationConstants.userDataSavedItemsKey.tr(),
      UserDataTab.budgets =>
        LocalizationConstants.userDataBudgetBalanceKey.tr(),
      UserDataTab.library =>
        LocalizationConstants.userDataLibraryItemsKey.tr(),
      UserDataTab.history =>
        LocalizationConstants.userDataOperationsKey.tr(),
    };
  }

  String _labelForSecondaryField(BuildContext context) {
    return switch (widget.tab) {
      UserDataTab.profile =>
        LocalizationConstants.userDataBirthDateKey.tr(),
      UserDataTab.appearance =>
        LocalizationConstants.userDataLanguageKey.tr(),
      _ => '',
    };
  }

  Widget _field(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      maxLines: widget.tab == UserDataTab.profile ? 1 : null,
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
