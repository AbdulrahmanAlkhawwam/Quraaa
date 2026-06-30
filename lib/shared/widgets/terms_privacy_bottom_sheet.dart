import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/localization/localization_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/styles/text_styles.dart';
import 'bottom_sheet_drag_handle.dart';

class TermsPrivacyBottomSheet extends StatelessWidget {
  const TermsPrivacyBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const TermsPrivacyBottomSheet(),
    );
  }

  static const List<_SectionConfig> _sections = <_SectionConfig>[
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyAcceptanceKey,
      descKey: LocalizationConstants.termsPrivacyAcceptanceDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyEligibilityKey,
      descKey: LocalizationConstants.termsPrivacyEligibilityDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyUserAccountKey,
      descKey: LocalizationConstants.termsPrivacyUserAccountDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyUseOfPlatformKey,
      descKey: LocalizationConstants.termsPrivacyUseOfPlatformDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyDigitalContentKey,
      descKey: LocalizationConstants.termsPrivacyDigitalContentDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyMarketplaceKey,
      descKey: LocalizationConstants.termsPrivacyMarketplaceDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyAuthorContentKey,
      descKey: LocalizationConstants.termsPrivacyAuthorContentDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyAIFeaturesKey,
      descKey: LocalizationConstants.termsPrivacyAIFeaturesDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyCommunityGuidelinesKey,
      descKey: LocalizationConstants.termsPrivacyCommunityGuidelinesDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyPaymentsKey,
      descKey: LocalizationConstants.termsPrivacyPaymentsDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacySubscriptionsKey,
      descKey: LocalizationConstants.termsPrivacySubscriptionsDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyRefundPolicyKey,
      descKey: LocalizationConstants.termsPrivacyRefundPolicyDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyPrivacyKey,
      descKey: LocalizationConstants.termsPrivacyPrivacyDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyIntellectualPropertyKey,
      descKey: LocalizationConstants.termsPrivacyIntellectualPropertyDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyServiceAvailabilityKey,
      descKey: LocalizationConstants.termsPrivacyServiceAvailabilityDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyAccountSuspensionKey,
      descKey: LocalizationConstants.termsPrivacyAccountSuspensionDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyLimitationOfLiabilityKey,
      descKey: LocalizationConstants.termsPrivacyLimitationOfLiabilityDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyChangesToTermsKey,
      descKey: LocalizationConstants.termsPrivacyChangesToTermsDescKey,
    ),
    _SectionConfig(
      titleKey: LocalizationConstants.termsPrivacyContactUsKey,
      descKey: LocalizationConstants.termsPrivacyContactUsDescKey,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const <double>[0.85, 1.0],
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.radius40),
              topRight: Radius.circular(AppRadius.radius40),
            ),
          ),
          child: CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const BottomSheetDragHandle(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing24,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              LocalizationConstants.termsPrivacyTitleKey.tr(),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.libraryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing8),
                    const Divider(
                      color: AppColors.primary100,
                      indent: AppSpacing.spacing24,
                      endIndent: AppSpacing.spacing24,
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing24,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      const SizedBox(height: AppSpacing.spacing8),
                      Text(
                        LocalizationConstants.termsPrivacyLastUpdatedKey.tr(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing16),
                      Text(
                        LocalizationConstants.termsPrivacyWelcomeKey.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing24),
                      ..._sections.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final _SectionConfig section = entry.value;
                        return _buildSection(
                          context,
                          number: '${index + 1}',
                          title: section.titleKey.tr(),
                          content: section.descKey.tr(),
                        );
                      }),
                      const SizedBox(height: AppSpacing.spacing24 + 24),
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

  Widget _buildSection(
    BuildContext context, {
    required String number,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.forestGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacing12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.libraryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              content,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionConfig {
  const _SectionConfig({required this.titleKey, required this.descKey});

  final String titleKey;
  final String descKey;
}

class TermsPrivacyTextButton extends StatelessWidget {
  const TermsPrivacyTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => TermsPrivacyBottomSheet.show(context),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: LocalizationConstants.termsPrivacyContinueTextPart1Key.tr(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            TextSpan(
              text: LocalizationConstants.termsPrivacyContinueTextPart2Key.tr(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.libraryGreen,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
