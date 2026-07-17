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
import '../../../auth/auth.dart';
import '../../domain/entities/gender_selection.dart';
import '../bloc/onboarding_bloc.dart';

class GenderOnboardingPage extends StatefulWidget {
  const GenderOnboardingPage({super.key});

  @override
  State<GenderOnboardingPage> createState() => _GenderOnboardingPageState();
}

class _GenderOnboardingPageState extends State<GenderOnboardingPage> {
  late final AuthJourneyCubit _journeyCubit = sl<AuthJourneyCubit>();

  @override
  void initState() {
    super.initState();
    unawaited(_journeyCubit.enterOnboarding());
  }

  @override
  void dispose() {
    _journeyCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnboardingBloc>(
          create: (_) => sl<OnboardingBloc>()..add(const OnboardingStarted()),
        ),
        BlocProvider<AuthJourneyCubit>.value(value: _journeyCubit),
      ],
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
                context.showErrorSnackBar(
                  message: Message(title: '', value: msg.tr()),
                );
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
            child: AppImage(
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
                          context
                              .read<AuthJourneyCubit>()
                              .moveFromOnboardingToAuth(),
                        );
                        context.goTo(RouteNames.auth);
                      },
                      icon: HugeIcon(
                        icon: context.isRTL
                            ? HugeIcons.strokeRoundedArrowRight01
                            : HugeIcons.strokeRoundedArrowLeft01,
                        color: AppColors.card,
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
                              context
                                  .read<AuthJourneyCubit>()
                                  .moveFromOnboardingToRegister(),
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
                      padding: EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.spacing24,
                        AppSpacing.spacing24,
                        AppSpacing.spacing24,
                        AppSpacing.spacing24 + context.bottomPadding,
                      ),
                      decoration: BoxDecoration(
                        color: context.appCard,
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
        selected ? context.appSubtleSurface : context.appCard;
    final Color borderColor =
        selected ? AppColors.primary300 : context.appBorder;

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
              AppImage(
                gender == GenderSelection.boy
                    ? AppImages.boyImage
                    : AppImages.girlImage,
                height: AppDimensions.onboardingAvatarSize,
              ),
              const SizedBox(height: AppSpacing.spacing20),
              Text(
                label,
                style: AppTextStyles.titleLarge.copyWith(
                  color: context.appTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

