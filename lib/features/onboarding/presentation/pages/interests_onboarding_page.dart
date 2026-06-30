import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/assets/app_images.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

// import '../../../../shared/widgets/onboarding_progress_indicator.dart';
import '../../../../shared/widgets/onboarding_progress_indicator.dart';
import '../../../auth/data/datasources/local/auth_journey_local_data_source.dart';
import '../../domain/entities/interest_selection.dart';
import '../bloc/onboarding_bloc.dart';

class InterestsOnboardingPage extends StatefulWidget {
  const InterestsOnboardingPage({super.key});

  @override
  State<InterestsOnboardingPage> createState() =>
      _InterestsOnboardingPageState();
}

class _InterestsOnboardingPageState extends State<InterestsOnboardingPage> {
  final AuthJourneyLocalDataSource _authJourney =
      sl<AuthJourneyLocalDataSource>();

  @override
  void initState() {
    super.initState();
    unawaited(
      _authJourney.saveJourneyStage(AuthJourneyStage.onboardingInterests),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (_) => sl<OnboardingBloc>()..add(const OnboardingStarted()),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) =>
            previous.navigationTarget != current.navigationTarget &&
            current.navigationTarget != null,
        listener: (context, state) {
          final String? target = state.navigationTarget;
          if (target != null) {
            context.goTo(target);
          }
        },
        child: const _InterestsOnboardingView(),
      ),
    );
  }
}

class _InterestsOnboardingView extends StatelessWidget {
  const _InterestsOnboardingView();

  Future<void> _goBack(BuildContext context) async {
    await sl<AuthJourneyLocalDataSource>().saveJourneyStage(
      AuthJourneyStage.onboardingAge,
      previousStage: AuthJourneyStage.onboardingInterests,
    );
    if (!context.mounted) {
      return;
    }
    context.goTo(RouteNames.onboardingAge);
  }

  Future<void> _skip(BuildContext context) async {
    await sl<AuthJourneyLocalDataSource>().saveJourneyStage(
      AuthJourneyStage.register,
      previousStage: AuthJourneyStage.onboardingInterests,
    );
    if (!context.mounted) {
      return;
    }
    context.read<OnboardingBloc>().add(const OnboardingSkipRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.onboardingBackground,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    AppColors.libraryGreen.withAlpha(100),
                    AppColors.libraryGreen.withAlpha(120),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  AppBar(
                    leading: IconButton(
                      onPressed: () {
                        unawaited(
                          sl<AuthJourneyLocalDataSource>().saveJourneyStage(
                            AuthJourneyStage.auth,
                            previousStage: AuthJourneyStage.onboarding,
                          ),
                        );
                        context.goTo(RouteNames.auth);
                      },
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      LocalizationConstants.onboardingGenderTitleKey.tr(),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: TextButton(
                          onPressed: () {
                            unawaited(
                              sl<AuthJourneyLocalDataSource>().saveJourneyStage(
                                AuthJourneyStage.register,
                                previousStage: AuthJourneyStage.onboarding,
                              ),
                            );
                            context.read<OnboardingBloc>().add(
                              const OnboardingSkipRequested(),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary50,
                          ),
                          child: Text(
                            LocalizationConstants.onboardingSkipKey.tr(),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.spacing24,
                        AppSpacing.spacing24,
                        AppSpacing.spacing24,
                        AppSpacing.spacing24 + context.bottomPadding,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.radius40),
                          topRight: Radius.circular(AppRadius.radius40),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: BlocBuilder<OnboardingBloc, OnboardingState>(
                                  builder: (context, state) {
                                    return SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: Wrap(
                                          spacing: AppSpacing.spacing12,
                                          runSpacing: AppSpacing.spacing12,
                                          children: InterestSelection.values.map((
                                            interest,
                                          ) {
                                            final bool selected = state
                                                .selectedInterests
                                                .contains(interest);
                                            return _InterestChip(
                                              label: _interestLabel(interest),
                                              selected: selected,
                                              onTap: state.isLoading
                                                  ? null
                                                  : () => context
                                                        .read<OnboardingBloc>()
                                                        .add(
                                                          OnboardingInterestToggled(
                                                            interest,
                                                          ),
                                                        ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.spacing24),
                          const OnboardingProgressIndicator(
                            activeIndex: 3,
                            count: 3,
                          ),
                          const SizedBox(height: AppSpacing.spacing24),
                          BlocBuilder<OnboardingBloc, OnboardingState>(
                            builder: (context, state) {
                              return SizedBox(
                                height: AppDimensions.onboardingButtonHeight,
                                child: FilledButton(
                                  onPressed: state.canContinueInterests
                                      ? () => context.read<OnboardingBloc>().add(
                                          const OnboardingInterestsNextRequested(),
                                        )
                                      : null,
                                  child: Text(
                                    LocalizationConstants.onboardingNextKey
                                        .tr(),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.spacing24),
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

  String _interestLabel(InterestSelection interest) {
    switch (interest) {
      case InterestSelection.spaceScience:
        return LocalizationConstants.onboardingInterestSpaceScienceKey.tr();
      case InterestSelection.geography:
        return LocalizationConstants.onboardingInterestGeographyKey.tr();
      case InterestSelection.history:
        return LocalizationConstants.onboardingInterestHistoryKey.tr();
      case InterestSelection.encyclopedias:
        return LocalizationConstants.onboardingInterestEncyclopediasKey.tr();
      case InterestSelection.patrols:
        return LocalizationConstants.onboardingInterestPatrolsKey.tr();
      case InterestSelection.culture:
        return LocalizationConstants.onboardingInterestCultureKey.tr();
      case InterestSelection.science:
        return LocalizationConstants.onboardingInterestScienceKey.tr();
      case InterestSelection.novels:
        return LocalizationConstants.onboardingInterestNovelsKey.tr();
      case InterestSelection.policy:
        return LocalizationConstants.onboardingInterestPolicyKey.tr();
      case InterestSelection.dictionary:
        return LocalizationConstants.onboardingInterestDictionaryKey.tr();
      case InterestSelection.education:
        return LocalizationConstants.onboardingInterestEducationKey.tr();
      case InterestSelection.technology:
        return LocalizationConstants.onboardingInterestTechnologyKey.tr();
      case InterestSelection.art:
        return LocalizationConstants.onboardingInterestArtKey.tr();
      case InterestSelection.literature:
        return LocalizationConstants.onboardingInterestLiteratureKey.tr();
      case InterestSelection.other:
        return LocalizationConstants.onboardingInterestOtherKey.tr();
    }
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = selected
        ? AppColors.primary50
        : AppColors.card;
    final Color borderColor = selected
        ? AppColors.primary300
        : AppColors.surface;
    final Color textColor = selected
        ? AppColors.primary700
        : AppColors.textPrimary;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing20,
            vertical: AppSpacing.spacing12,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.radius32),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final List<List<dynamic>> icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.spacing48,
      height: AppSpacing.spacing48,
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius16),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: HugeIcon(icon: icon, color: AppColors.textPrimary, size: 18),
          splashRadius: 22,
        ),
      ),
    );
  }
}
