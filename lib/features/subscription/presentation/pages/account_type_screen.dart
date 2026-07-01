import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../widgets/subscription_plan_card.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.spacing16),
          children: <Widget>[
            Row(
              children: <Widget>[
                _BackButton(onTap: () => context.pop()),
                const SizedBox(width: AppSpacing.spacing12),
                Expanded(
                  child: Text(
                    LocalizationConstants.subscriptionAccountTypeTitleKey.tr(),
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              LocalizationConstants.subscriptionAccountTypeSubtitleKey.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing24),
            ..._plans.asMap().entries.map(
              (MapEntry<int, _Plan> entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.spacing16),
                  child: SubscriptionPlanCard(
                    title: entry.value.title,
                    subtitle: entry.value.subtitle,
                    price: entry.value.price,
                    features: entry.value.features,
                    selected: _selectedIndex == entry.key,
                    onTap: () => setState(() => _selectedIndex = entry.key),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.spacing8),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.onboardingButtonHeight,
              child: FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.check_rounded),
                label: Text(LocalizationConstants.notificationContinueKey.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_Plan> get _plans {
    return <_Plan>[
      _Plan(
        title: LocalizationConstants.subscriptionPlanFreeKey.tr(),
        subtitle: 'Good for casual reading',
        price: '\$0 / month',
        features: const <String>[
          'Browse books and categories',
          'Save a small reading list',
          'Basic search experience',
        ],
      ),
      _Plan(
        title: LocalizationConstants.subscriptionPlanPlusKey.tr(),
        subtitle: 'Balanced for active readers',
        price: '\$4.99 / month',
        features: const <String>[
          'Unlimited bookmarks',
          'Advanced recommendations',
          'Priority support',
        ],
      ),
      _Plan(
        title: LocalizationConstants.subscriptionPlanPremiumKey.tr(),
        subtitle: 'Best for power readers',
        price: '\$9.99 / month',
        features: const <String>[
          'All Plus features',
          'Exclusive premium collections',
          'Early access to new features',
        ],
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

class _Plan {
  const _Plan({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.features,
  });

  final String title;
  final String subtitle;
  final String price;
  final List<String> features;
}
