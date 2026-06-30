import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../config/routes/route_names.dart';
import '../../core/di/injection_container.dart';
import '../../core/error_monitoring/user_context_provider.dart';
import '../../core/localization/localization_constants.dart';
import '../../core/services/storage_service.dart';
import '../../features/auth/data/datasources/local/auth_journey_local_data_source.dart';
import '../../features/account/data/user_data_local_data_source.dart';
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
    await sl<AuthJourneyLocalDataSource>().clearSession();
    await sl<UserContextProvider>().clearUser();
    if (!mounted) {
      return;
    }
    context.goTo(RouteNames.auth);
  }

  void _openNotificationDemo() {
    context.goTo(
      '${RouteNames.routeBridge}?route=${Uri.encodeComponent(RouteNames.login)}',
    );
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
    final bool rtl = true/*context.isRTL*/;
    final UserDataSnapshot? snapshot = _snapshot;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNotificationDemo,
        backgroundColor: AppColors.libraryGreen,
        foregroundColor: AppColors.primary50,
        icon: const Icon(Icons.notifications_active_outlined),
        label: const Text('Demo notification'),
      ),
      body: _loading || snapshot == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/onboarding.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.libraryGreen.withOpacity(0.72),
                          AppColors.primary900.withOpacity(0.9),
                          AppColors.primary50.withOpacity(0.12),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacing24,
                    ),
                    child: Column(
                      children: [
                        _BlurHeader(
                          title: LocalizationConstants.userDataTitleKey.tr(),
                          onBackPressed: () => context.back(),
                          onActionPressed: () => _openEditor(_selectedTab),
                          actionIcon: HugeIcons.strokeRoundedPencil,
                          rtl: rtl,
                        ),
                        const SizedBox(height: AppSpacing.spacing16),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.radius40),
                            // todo : boxShadow: AppShadows.soft,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.radius40),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/images/onboarding.jpg',
                                  fit: BoxFit.cover,
                                ),
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary100.withOpacity(0.22),
                                          AppColors.primary50.withOpacity(0.46),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.22),
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(AppRadius.radius40),
                                      ),
                                    ),
                                    child: Center(
                                      child: HugeIcon(
                                        icon: HugeIcons.strokeRoundedUser,
                                        color: AppColors.libraryGreen,
                                        size: 110,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing16),
                        SizedBox(
                          height: 86,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: rtl,
                            child: Row(
                              children: [
                                _TabPill(
                                  icon: HugeIcons.strokeRoundedUser,
                                  label: LocalizationConstants
                                      .userDataProfileTabKey
                                      .tr(),
                                  selected: _selectedTab == UserDataTab.profile,
                                  onTap: () => setState(() {
                                    _selectedTab = UserDataTab.profile;
                                  }),
                                ),
                                _TabPill(
                                  icon: HugeIcons.strokeRoundedPaintBrush02,
                                  label: LocalizationConstants
                                      .userDataAppearanceTabKey
                                      .tr(),
                                  selected:
                                      _selectedTab == UserDataTab.appearance,
                                  onTap: () => setState(() {
                                    _selectedTab = UserDataTab.appearance;
                                  }),
                                ),
                                _TabPill(
                                  icon: HugeIcons.strokeRoundedBookmark01,
                                  label: LocalizationConstants
                                      .userDataBookmarksTabKey
                                      .tr(),
                                  selected:
                                      _selectedTab == UserDataTab.bookmarks,
                                  onTap: () => setState(() {
                                    _selectedTab = UserDataTab.bookmarks;
                                  }),
                                ),
                                _TabPill(
                                  icon: HugeIcons.strokeRoundedWallet02,
                                  label: LocalizationConstants
                                      .userDataBudgetsTabKey
                                      .tr(),
                                  selected: _selectedTab == UserDataTab.budgets,
                                  onTap: () => setState(() {
                                    _selectedTab = UserDataTab.budgets;
                                  }),
                                ),
                                _TabPill(
                                  icon: HugeIcons.strokeRoundedLibrary,
                                  label: LocalizationConstants
                                      .userDataLibraryTabKey
                                      .tr(),
                                  selected: _selectedTab == UserDataTab.library,
                                  onTap: () => setState(() {
                                    _selectedTab = UserDataTab.library;
                                  }),
                                ),
                                _TabPill(
                                  icon: HugeIcons.strokeRoundedClock01,
                                  label: LocalizationConstants
                                      .userDataHistoryTabKey
                                      .tr(),
                                  selected: _selectedTab == UserDataTab.history,
                                  onTap: () => setState(() {
                                    _selectedTab = UserDataTab.history;
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacing12),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _TabBody(
                              key: ValueKey<UserDataTab>(_selectedTab),
                              tab: _selectedTab,
                              snapshot: snapshot,
                              onEdit: () => _openEditor(_selectedTab),
                              onLogout: _logout,
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
      borderRadius: BorderRadius.circular(28/*AppRadius.radius28*/),
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
            borderRadius: BorderRadius.circular(28/*AppRadius.radius28*/),
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

class _TabPill extends StatelessWidget {
  const _TabPill({
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
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.spacing12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing16,
            vertical: AppSpacing.spacing16, //todo : it was spacing 14
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary50 : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(AppRadius.radius24),
            border: Border.all(
              color: selected ? AppColors.primary300 : Colors.white.withOpacity(0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: icon,
                color: selected ? AppColors.primary700 : AppColors.primary100,
                size: 22,
              ),
              const SizedBox(width: 10/*AppSpacing.spacing10*/),
              Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: selected ? AppColors.primary700 : AppColors.primary100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({
    super.key,
    required this.tab,
    required this.snapshot,
    required this.onEdit,
    required this.onLogout,
  });

  final UserDataTab tab;
  final UserDataSnapshot snapshot;
  final VoidCallback onEdit;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spacing20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.radius32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              _title(context),
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.libraryGreen,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing20),
          Expanded(
            child: _TabPreview(tab: tab, snapshot: snapshot),
          ),
          const SizedBox(height: AppSpacing.spacing20),
          SizedBox(
            height: AppDimensions.onboardingButtonHeight,
            child: FilledButton(
              onPressed: onEdit,
              child: Text(LocalizationConstants.userDataEditKey.tr()),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing12),
          SizedBox(
            height: AppDimensions.onboardingButtonHeight,
            child: OutlinedButton(
              onPressed: onLogout,
              child: Text(LocalizationConstants.userDataLogoutKey.tr()),
            ),
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    return switch (tab) {
      UserDataTab.profile => LocalizationConstants.userDataProfileTabKey.tr(),
      UserDataTab.appearance => LocalizationConstants.userDataAppearanceTabKey.tr(),
      UserDataTab.bookmarks => LocalizationConstants.userDataBookmarksTabKey.tr(),
      UserDataTab.budgets => LocalizationConstants.userDataBudgetsTabKey.tr(),
      UserDataTab.library => LocalizationConstants.userDataLibraryTabKey.tr(),
      UserDataTab.history => LocalizationConstants.userDataHistoryTabKey.tr(),
    };
  }
}

class _TabPreview extends StatelessWidget {
  const _TabPreview({required this.tab, required this.snapshot});

  final UserDataTab tab;
  final UserDataSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final List<String> items = switch (tab) {
      UserDataTab.profile => <String>[
          '${LocalizationConstants.userDataFullNameKey.tr()}: ${snapshot.fullName}',
          '${LocalizationConstants.userDataBirthDateKey.tr()}: ${snapshot.birthDate}',
          '${LocalizationConstants.userDataCountryKey.tr()}: ${snapshot.country}',
          '${LocalizationConstants.userDataPhoneKey.tr()}: ${snapshot.phone}',
        ],
      UserDataTab.appearance => <String>[
          '${LocalizationConstants.userDataThemeKey.tr()}: ${snapshot.theme}',
          '${LocalizationConstants.userDataLanguageKey.tr()}: ${snapshot.language}',
        ],
      UserDataTab.bookmarks => snapshot.bookmarks,
      UserDataTab.budgets => <String>[
          '${LocalizationConstants.userDataBudgetBalanceKey.tr()}: ${snapshot.budgetBalance}',
        ],
      UserDataTab.library => snapshot.libraryItems,
      UserDataTab.history => snapshot.operations,
    };

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing16),
          child: Text(
            items[index],
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        );
      },
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
                    rtl: true/*context.isRTL*/,
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
      UserDataTab.bookmarks => LocalizationConstants.userDataSavedItemsKey.tr(),
      UserDataTab.budgets => LocalizationConstants.userDataBudgetBalanceKey.tr(),
      UserDataTab.library => LocalizationConstants.userDataLibraryItemsKey.tr(),
      UserDataTab.history => LocalizationConstants.userDataOperationsKey.tr(),
    };
  }

  String _labelForSecondaryField(BuildContext context) {
    return switch (widget.tab) {
      UserDataTab.profile => LocalizationConstants.userDataBirthDateKey.tr(),
      UserDataTab.appearance => LocalizationConstants.userDataLanguageKey.tr(),
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
          borderRadius: BorderRadius.circular(18/*AppRadius.radius18*/),
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
