import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

class SettingsSearchScreen extends StatefulWidget {
  const SettingsSearchScreen({super.key});

  @override
  State<SettingsSearchScreen> createState() => _SettingsSearchScreenState();
}

class _SettingsSearchScreenState extends State<SettingsSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<_SettingsShortcut> results = _shortcuts()
        .where(
          (_SettingsShortcut shortcut) =>
              _controller.text.trim().isEmpty ||
              shortcut.title.toLowerCase().contains(
                    _controller.text.trim().toLowerCase(),
                  ) ||
              shortcut.subtitle.toLowerCase().contains(
                    _controller.text.trim().toLowerCase(),
              ),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _BackButton(onTap: () => context.pop()),
                  const SizedBox(width: AppSpacing.spacing12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.radius24),
                        border: Border.all(color: AppColors.primary100),
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: LocalizationConstants.settingsSearchTitleKey
                              .tr(),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(AppSpacing.spacing12),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedSearch01,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                          suffixIcon: _controller.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _controller.clear();
                                    setState(() {});
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.all(AppSpacing.spacing12),
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedCancel01,
                                      color: AppColors.textTertiary,
                                      size: 20,
                                    ),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.spacing16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing20),
              Text(
                LocalizationConstants.settingsSearchSubtitleKey.tr(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing16),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Text(
                          LocalizationConstants.settingsSearchEmptyKey.tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.spacing12),
                        itemBuilder: (BuildContext context, int index) {
                          final _SettingsShortcut shortcut = results[index];
                          return SettingsActionGroup(
                            children: <Widget>[
                              SettingsActionButton(
                                title: shortcut.title,
                                subtitle: shortcut.subtitle,
                                leadingIcon: shortcut.icon,
                                onTap: () => shortcut.onTap(context),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_SettingsShortcut> _shortcuts() {
    return <_SettingsShortcut>[
      _SettingsShortcut(
        title: LocalizationConstants.settingsAccountTypeKey.tr(),
        subtitle: LocalizationConstants.subscriptionAccountTypeSubtitleKey.tr(),
        icon: HugeIcons.strokeRoundedUserAccount,
        onTap: (BuildContext context) =>
            context.push(RouteNames.subscriptionAccountType),
      ),
      _SettingsShortcut(
        title: LocalizationConstants.userDataSettingsAppearanceKey.tr(),
        subtitle: 'Theme and layout options',
        icon: HugeIcons.strokeRoundedSettings01,
        onTap: (BuildContext context) => Navigator.of(context).maybePop(),
      ),
      _SettingsShortcut(
        title: LocalizationConstants
            .userDataSettingsNotificationManagementKey
            .tr(),
        subtitle: 'Push, email, and reminder preferences',
        icon: HugeIcons.strokeRoundedNotification01,
        onTap: (BuildContext context) => Navigator.of(context).maybePop(),
      ),
      _SettingsShortcut(
        title: LocalizationConstants.userDataSettingsSecurityKey.tr(),
        subtitle: 'Password and privacy controls',
        icon: HugeIcons.strokeRoundedSettings01,
        onTap: (BuildContext context) => Navigator.of(context).maybePop(),
      ),
      _SettingsShortcut(
        title: LocalizationConstants.userDataSettingsLanguagesKey.tr(),
        subtitle: 'Arabic and English',
        onTap: (BuildContext context) => Navigator.of(context).maybePop(),
      ),
    ];
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.radius16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius16),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsShortcut {
  const _SettingsShortcut({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
  });

  final String title;
  final String subtitle;
  final List<List<dynamic>>? icon;
  final void Function(BuildContext context) onTap;
}
