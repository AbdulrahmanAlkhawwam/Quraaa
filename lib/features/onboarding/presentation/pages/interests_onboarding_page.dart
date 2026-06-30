import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../auth/data/datasources/local/auth_journey_local_data_source.dart';
import '../../domain/entities/interest_selection.dart';
import '../bloc/onboarding_bloc.dart';

class InterestsOnboardingPage extends StatefulWidget {
  const InterestsOnboardingPage({super.key});

  @override
  State<InterestsOnboardingPage> createState() => _InterestsOnboardingPageState();
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

  Future<void> _goBack() async {
    await _authJourney.saveJourneyStage(
      AuthJourneyStage.onboardingAge,
      previousStage: AuthJourneyStage.onboardingInterests,
    );
    if (!mounted) return;
    context.goTo(RouteNames.onboardingAge);
  }

  Future<void> _skip() async {
    await _authJourney.saveJourneyStage(
      AuthJourneyStage.register,
      previousStage: AuthJourneyStage.onboardingInterests,
    );
    if (!mounted) return;
    context.read<OnboardingBloc>().add(const OnboardingSkipRequested());
  }

  void _onInterestToggled(InterestSelection interest) {
    context.read<OnboardingBloc>().add(OnboardingInterestToggled(interest));
  }

  void _onNext() {
    context.read<OnboardingBloc>().add(const OnboardingInterestsNextRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (_) => sl<OnboardingBloc>()..add(const OnboardingStarted()),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listenWhen: (p, c) =>
            p.navigationTarget != c.navigationTarget && c.navigationTarget != null,
        listener: (context, state) {
          final target = state.navigationTarget;
          if (target != null) context.goTo(target);
        },
        child: BlocListener<OnboardingBloc, OnboardingState>(
          listenWhen: (p, c) => p.errorMessage != c.errorMessage && c.errorMessage != null,
          listener: (context, state) {
            final msg = state.errorMessage;
            if (msg != null) {
              context.showErrorSnackBar(
                message: Message(
                  title: LocalizationConstants.onboardingInterestsTitleKey.tr(),
                  value: msg,
                ),
              );
            }
          },
          child: Builder(
            builder: (context) {
              return BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  return OnboardingScaffold(
                    title: LocalizationConstants.onboardingInterestsTitleKey.tr(),
                    leading: OnboardingBackButton(onPressed: _goBack),
                    actions: [OnboardingSkipButton(onPressed: _skip)],
                    activeIndex: 3,
                    totalSteps: 3,
                    content: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Wrap(
                        spacing: AppSpacing.spacing12,
                        runSpacing: AppSpacing.spacing12,
                        children: InterestSelection.values.map((interest) {
                          final selected = state.selectedInterests.contains(interest);
                          return _InterestChip(
                            label: _interestLabel(interest),
                            selected: selected,
                            onTap: state.isLoading
                                ? null
                                : () => _onInterestToggled(interest),
                          );
                        }).toList(),
                      ),
                    ),
                    bottomButton: OnboardingNextButton(
                      onPressed: state.canContinueInterests ? _onNext : null,
                      isLoading: state.isLoading,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _interestLabel(InterestSelection interest) {
    return switch (interest) {
      InterestSelection.spaceScience =>
          LocalizationConstants.onboardingInterestSpaceScienceKey.tr(),
      InterestSelection.geography =>
          LocalizationConstants.onboardingInterestGeographyKey.tr(),
      InterestSelection.history =>
          LocalizationConstants.onboardingInterestHistoryKey.tr(),
      InterestSelection.encyclopedias =>
          LocalizationConstants.onboardingInterestEncyclopediasKey.tr(),
      InterestSelection.patrols =>
          LocalizationConstants.onboardingInterestPatrolsKey.tr(),
      InterestSelection.culture =>
          LocalizationConstants.onboardingInterestCultureKey.tr(),
      InterestSelection.science =>
          LocalizationConstants.onboardingInterestScienceKey.tr(),
      InterestSelection.novels =>
          LocalizationConstants.onboardingInterestNovelsKey.tr(),
      InterestSelection.policy =>
          LocalizationConstants.onboardingInterestPolicyKey.tr(),
      InterestSelection.dictionary =>
          LocalizationConstants.onboardingInterestDictionaryKey.tr(),
      InterestSelection.education =>
          LocalizationConstants.onboardingInterestEducationKey.tr(),
      InterestSelection.technology =>
          LocalizationConstants.onboardingInterestTechnologyKey.tr(),
      InterestSelection.art =>
          LocalizationConstants.onboardingInterestArtKey.tr(),
      InterestSelection.literature =>
          LocalizationConstants.onboardingInterestLiteratureKey.tr(),
      InterestSelection.other =>
          LocalizationConstants.onboardingInterestOtherKey.tr(),
    };
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
            color: selected ? AppColors.primary50 : AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.radius32),
            border: Border.all(
              color: selected ? AppColors.primary300 : AppColors.surface,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected ? AppColors.primary700 : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
