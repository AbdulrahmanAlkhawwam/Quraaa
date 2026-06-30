import 'package:flutter/material.dart';
import '../../core/localization/localization_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/styles/text_styles.dart';

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
                    const SizedBox(height: AppSpacing.spacing12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withAlpha(76),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing16),
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
                      _buildSection(
                        context,
                        number: '1',
                        title: LocalizationConstants.termsPrivacyAcceptanceKey.tr(),
                        content: LocalizationConstants.termsPrivacyAcceptanceDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '2',
                        title: LocalizationConstants.termsPrivacyEligibilityKey.tr(),
                        content: LocalizationConstants.termsPrivacyEligibilityDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '3',
                        title: LocalizationConstants.termsPrivacyUserAccountKey.tr(),
                        content: LocalizationConstants.termsPrivacyUserAccountDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '4',
                        title: LocalizationConstants.termsPrivacyUseOfPlatformKey.tr(),
                        content: LocalizationConstants.termsPrivacyUseOfPlatformDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '5',
                        title: LocalizationConstants.termsPrivacyDigitalContentKey.tr(),
                        content: LocalizationConstants.termsPrivacyDigitalContentDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '6',
                        title: LocalizationConstants.termsPrivacyMarketplaceKey.tr(),
                        content: LocalizationConstants.termsPrivacyMarketplaceDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '7',
                        title: LocalizationConstants.termsPrivacyAuthorContentKey.tr(),
                        content: LocalizationConstants.termsPrivacyAuthorContentDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '8',
                        title: LocalizationConstants.termsPrivacyAIFeaturesKey.tr(),
                        content: LocalizationConstants.termsPrivacyAIFeaturesDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '9',
                        title: LocalizationConstants.termsPrivacyCommunityGuidelinesKey.tr(),
                        content: LocalizationConstants.termsPrivacyCommunityGuidelinesDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '10',
                        title: LocalizationConstants.termsPrivacyPaymentsKey.tr(),
                        content: LocalizationConstants.termsPrivacyPaymentsDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '11',
                        title: LocalizationConstants.termsPrivacySubscriptionsKey.tr(),
                        content: LocalizationConstants.termsPrivacySubscriptionsDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '12',
                        title: LocalizationConstants.termsPrivacyRefundPolicyKey.tr(),
                        content: LocalizationConstants.termsPrivacyRefundPolicyDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '13',
                        title: LocalizationConstants.termsPrivacyPrivacyKey.tr(),
                        content: LocalizationConstants.termsPrivacyPrivacyDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '14',
                        title: LocalizationConstants.termsPrivacyIntellectualPropertyKey.tr(),
                        content: LocalizationConstants.termsPrivacyIntellectualPropertyDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '15',
                        title: LocalizationConstants.termsPrivacyServiceAvailabilityKey.tr(),
                        content: LocalizationConstants.termsPrivacyServiceAvailabilityDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '16',
                        title: LocalizationConstants.termsPrivacyAccountSuspensionKey.tr(),
                        content: LocalizationConstants.termsPrivacyAccountSuspensionDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '17',
                        title: LocalizationConstants.termsPrivacyLimitationOfLiabilityKey.tr(),
                        content: LocalizationConstants.termsPrivacyLimitationOfLiabilityDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '18',
                        title: LocalizationConstants.termsPrivacyChangesToTermsKey.tr(),
                        content: LocalizationConstants.termsPrivacyChangesToTermsDescKey.tr(),
                      ),
                      _buildSection(
                        context,
                        number: '19',
                        title: LocalizationConstants.termsPrivacyContactUsKey.tr(),
                        content: LocalizationConstants.termsPrivacyContactUsDescKey.tr(),
                      ),
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
                decoration: BoxDecoration(
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
