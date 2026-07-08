import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../widgets/account_type_card.dart';
import '../widgets/settings_palette.dart';

class AccountTypePage extends StatelessWidget {
  const AccountTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: palette.background,
        statusBarIconBrightness:
            palette.isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: palette.background,
        systemNavigationBarIconBrightness:
            palette.isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: palette.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(38, 28, 38, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _AccountTypeHeader(palette: palette),
                const SizedBox(height: 16),
                AccountTypeCard(
                  title: 'Personal Account',
                  description:
                      'this account is for one user without any subscription',
                  badgeText: 'Current Plan',
                  selected: true,
                  badgeColor: palette.accent,
                  badgeTextColor: palette.onAccent,
                ),
                const SizedBox(height: 22),
                const AccountTypeCard(
                  title: 'Family Account',
                  description:
                      'this account is for 5 person . can share your date but without any subscription',
                ),
                const SizedBox(height: 22),
                AccountTypeCard(
                  title: 'Pro Account',
                  description:
                      'this account is for one user with unlimited AI',
                  badgeText: '\$20/mo',
                  badgeColor: const Color(0xFF4D194D),
                  badgeTextColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTypeHeader extends StatelessWidget {
  const _AccountTypeHeader({required this.palette});

  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: palette.secondaryText,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            LocalizationConstants.settingsProfileAccountTypeKey.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.explorerTitle().copyWith(
              color: palette.text,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
