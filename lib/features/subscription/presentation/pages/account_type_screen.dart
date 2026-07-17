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
      backgroundColor: context.appBackground,
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
                      color: context.appTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              LocalizationConstants.subscriptionAccountTypeSubtitleKey.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.appTextSecondary,
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
        subtitle: LocalizationConstants.subscriptionPlanFreeSubtitleKey.tr(),
        price: '\$0 / month',
        features: <String>[
          LocalizationConstants.subscriptionPlanFreeFeatureBrowseKey.tr(),
          LocalizationConstants.subscriptionPlanFreeFeatureSaveKey.tr(),
          LocalizationConstants.subscriptionPlanFreeFeatureSearchKey.tr(),
        ],
      ),
      _Plan(
        title: LocalizationConstants.subscriptionPlanPlusKey.tr(),
        subtitle: LocalizationConstants.subscriptionPlanPlusSubtitleKey.tr(),
        price: '\$4.99 / month',
        features: <String>[
          LocalizationConstants.subscriptionPlanPlusFeatureBookmarksKey.tr(),
          LocalizationConstants.subscriptionPlanPlusFeatureRecommendationsKey.tr(),
          LocalizationConstants.subscriptionPlanPlusFeatureSupportKey.tr(),
        ],
      ),
      _Plan(
        title: LocalizationConstants.subscriptionPlanPremiumKey.tr(),
        subtitle: LocalizationConstants.subscriptionPlanPremiumSubtitleKey.tr(),
        price: '\$9.99 / month',
        features: <String>[
          LocalizationConstants.subscriptionPlanPremiumFeaturePlusKey.tr(),
          LocalizationConstants.subscriptionPlanPremiumFeatureCollectionsKey.tr(),
          LocalizationConstants.subscriptionPlanPremiumFeatureEarlyAccessKey.tr(),
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
      color: context.appCard,
      borderRadius: BorderRadius.circular(AppRadius.radius16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius16),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: context.appTextPrimary,
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
