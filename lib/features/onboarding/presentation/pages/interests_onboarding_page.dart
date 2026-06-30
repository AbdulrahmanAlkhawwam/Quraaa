import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/widgets/onboarding_scaffold.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/category.dart';
import '../bloc/onboarding_bloc.dart';

class InterestsOnboardingPage extends StatefulWidget {
  const InterestsOnboardingPage({super.key});

  @override
  State<InterestsOnboardingPage> createState() => _InterestsOnboardingPageState();
}

class _InterestsOnboardingPageState extends State<InterestsOnboardingPage> {
  final AuthLocalDataSource _authJourney = sl<AuthLocalDataSource>();

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
        listenWhen: (previous, current) => current.navigationTarget != null,
        listener: (context, state) {
          final target = state.navigationTarget;
          if (target != null) {
            context.read<OnboardingBloc>().add(
              const OnboardingNavigationCompleted(),
            );
            context.goTo(target);
          }
        },
        child: BlocListener<OnboardingBloc, OnboardingState>(
          listenWhen: (previous, current) =>
              current.isCompleted && !previous.isCompleted,
          listener: (context, state) {
            if (state.isCompleted) {
              context.goTo(RouteNames.register);
            }
          },
          child: BlocListener<OnboardingBloc, OnboardingState>(
            listenWhen: (p, c) => p.errorMessage != c.errorMessage && c.errorMessage != null,
            listener: (context, state) {
              final msg = state.errorMessage;
              if (msg != null) {
                context.showResolvedErrorSnackBar(msg);
              }
            },
            child: const _InterestsOnboardingView(),
          ),
        ),
      ),
    );
  }
}

class _InterestsOnboardingView extends StatelessWidget {
  const _InterestsOnboardingView();

  Future<void> _goBack(BuildContext context) async {
    await sl<AuthLocalDataSource>().saveJourneyStage(
      AuthJourneyStage.onboardingAge,
      previousStage: AuthJourneyStage.onboardingInterests,
    );
    if (context.mounted) context.goTo(RouteNames.onboardingAge);
  }

  Future<void> _skip(BuildContext context) async {
    await sl<AuthLocalDataSource>().saveJourneyStage(
      AuthJourneyStage.register,
      previousStage: AuthJourneyStage.onboardingInterests,
    );
    if (context.mounted) {
      context.read<OnboardingBloc>().add(const OnboardingSkipRequested());
    }
  }

  void _onCategorySelected(BuildContext context, String categoryId) {
    context.read<OnboardingBloc>().add(OnboardingCategorySelected(categoryId));
  }

  void _onNext(BuildContext context) {
    context.read<OnboardingBloc>().add(const OnboardingInterestsNextRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return OnboardingScaffold(
          title: LocalizationConstants.onboardingInterestsTitleKey.tr(),
          leading: OnboardingBackButton(onPressed: () => _goBack(context)),
          actions: [OnboardingSkipButton(onPressed: () => _skip(context))],
          activeIndex: 3,
          totalSteps: 3,
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: state.categories.isEmpty
                ? state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const Center(child: Text('No categories available'))
                : Wrap(
                    spacing: AppSpacing.spacing12,
                    runSpacing: AppSpacing.spacing12,
                    children: state.categories.map((category) {
                      final selected = state.selectedCategoryId == category.id;
                      return _InterestChip(
                        label: context.locale.languageCode == 'ar'
                            ? category.nameAr
                            : category.nameEn,
                        selected: selected,
                        onTap: state.isLoading
                            ? null
                            : () => _onCategorySelected(context, category.id),
                      );
                    }).toList(),
                  ),
          ),
          bottomButton: OnboardingNextButton(
            onPressed: state.canContinueCategory
                ? () => _onNext(context)
                : null,
            isLoading: state.isLoading,
          ),
        );
      },
    );
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
