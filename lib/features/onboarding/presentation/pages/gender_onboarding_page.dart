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
import '../../../../shared/widgets/onboarding_progress_indicator.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/gender_selection.dart';
import '../bloc/onboarding_bloc.dart';

class GenderOnboardingPage extends StatefulWidget {
  const GenderOnboardingPage({super.key});

  @override
  State<GenderOnboardingPage> createState() => _GenderOnboardingPageState();
}

class _GenderOnboardingPageState extends State<GenderOnboardingPage> {
  final AuthLocalDataSource _authJourney = sl<AuthLocalDataSource>();

  @override
  void initState() {
    super.initState();
    unawaited(_authJourney.saveJourneyStage(AuthJourneyStage.onboarding));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (_) => sl<OnboardingBloc>()..add(const OnboardingStarted()),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) => current.navigationTarget != null,
        listener: (context, state) {
          final String? target = state.navigationTarget;
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
            listenWhen: (p, c) =>
                p.errorMessage != c.errorMessage && c.errorMessage != null,
            listener: (context, state) {
              final msg = state.errorMessage;
              if (msg != null) {
                context.showResolvedErrorSnackBar(msg);
              }
            },
            child: const _GenderOnboardingView(),
          ),
        ),
      ),
    );
  }
}

class _GenderOnboardingView extends StatelessWidget {
  const _GenderOnboardingView();

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
                    AppColors.libraryGreen.withAlpha(AppColors.overlayLightAlpha),
                    AppColors.libraryGreen.withAlpha(AppColors.overlayMediumAlpha),
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
                          sl<AuthLocalDataSource>().saveJourneyStage(
                            AuthJourneyStage.auth,
                            previousStage: AuthJourneyStage.onboarding,
                          ),
                        );
                        context.goTo(RouteNames.auth);
                      },
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                      ),
                    ),
                    title: Text(
                      LocalizationConstants.onboardingGenderTitleKey.tr(),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacing24,
                        ),
                        child: TextButton(
                          onPressed: () {
                            unawaited(
                              sl<AuthLocalDataSource>().saveJourneyStage(
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BlocBuilder<OnboardingBloc, OnboardingState>(
                            builder: (context, state) {
                              return SizedBox(
                                height: AppDimensions.onboardingCardHeight,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _GenderCard(
                                        gender: GenderSelection.boy,
                                        label: LocalizationConstants
                                            .onboardingBoyKey
                                            .tr(),
                                        selected:
                                            state.selectedGender ==
                                            GenderSelection.boy,
                                        onTap: state.isLoading
                                            ? null
                                            : () => context
                                                  .read<OnboardingBloc>()
                                                  .add(
                                                    const OnboardingGenderSelected(
                                                      GenderSelection.boy,
                                                    ),
                                                  ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: AppSpacing.spacing16,
                                    ),
                                    Expanded(
                                      child: _GenderCard(
                                        gender: GenderSelection.girl,
                                        label: LocalizationConstants
                                            .onboardingGirlKey
                                            .tr(),
                                        selected:
                                            state.selectedGender ==
                                            GenderSelection.girl,
                                        onTap: state.isLoading
                                            ? null
                                            : () => context
                                                  .read<OnboardingBloc>()
                                                  .add(
                                                    const OnboardingGenderSelected(
                                                      GenderSelection.girl,
                                                    ),
                                                  ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          const OnboardingProgressIndicator(
                            activeIndex: 1,
                            count: 3,
                          ),
                          const SizedBox(height: AppSpacing.spacing24),
                          BlocBuilder<OnboardingBloc, OnboardingState>(
                            builder: (context, state) {
                              return SizedBox(
                                height: AppDimensions.onboardingButtonHeight,
                                child: FilledButton(
                                  onPressed: state.canContinueGender
                                      ? () =>
                                            context.read<OnboardingBloc>().add(
                                              const OnboardingNextRequested(),
                                            )
                                      : null,
                                  child: Text(
                                    LocalizationConstants.onboardingNextKey.tr(),
                                  ),
                                ),
                              );
                            },
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
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.gender,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final GenderSelection gender;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        selected ? AppColors.primary50 : AppColors.card;
    final Color borderColor =
        selected ? AppColors.primary300 : AppColors.surface;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.spacing20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.radius32),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GenderAvatar(gender: gender, selected: selected),
              const SizedBox(height: AppSpacing.spacing20),
              Text(
                label,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderAvatar extends StatelessWidget {
  const _GenderAvatar({required this.gender, required this.selected});

  final GenderSelection gender;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = gender == GenderSelection.boy
        ? AppColors.primary300
        : AppColors.primary200;
    final Color accentColor = gender == GenderSelection.boy
        ? AppColors.primary700
        : AppColors.warning500;
    final List<List<dynamic>> icon = gender == GenderSelection.boy
        ? HugeIcons.strokeRoundedUser
        : HugeIcons.strokeRoundedUser02;

    return Container(
      width: AppDimensions.onboardingAvatarSize,
      height: AppDimensions.onboardingAvatarSize,
      decoration: BoxDecoration(
        color: selected ? AppColors.card : AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: AppDimensions.onboardingAvatarSize * 0.78,
          height: AppDimensions.onboardingAvatarSize * 0.78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [baseColor.withAlpha(220), accentColor.withAlpha(220)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: AppShadows.avatarGlow(baseColor),
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                HugeIcon(
                  icon: icon,
                  size: AppDimensions.onboardingAvatarSize * 0.42,
                  color: AppColors.card,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: AppDimensions.onboardingAvatarSize * 0.42,
                    height: AppDimensions.onboardingAvatarSize * 0.42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.card.withAlpha(60),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
