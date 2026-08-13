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
import '../widgets/gender_card.dart';

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
        listener: (context, state) {
          final String? target = state.navigationTarget;
          if (target != null) {
            context.read<OnboardingBloc>().add(
              const OnboardingNavigationCompleted(),
            );
            context.goTo(target);
          }

          final String? message = state.errorMessage;
          if (message != null) {
            context.showErrorSnackBar(
              message: Message(title: '', value: message.tr()),
            );
          }
        },
        child: const _GenderOnboardingView(),
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
            child: AppImage(AppImages.onboardingBackground, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    AppColors.libraryGreen.withAlpha(
                      AppColors.overlayLightAlpha,
                    ),
                    AppColors.libraryGreen.withAlpha(
                      AppColors.overlayMediumAlpha,
                    ),
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
                        color: context.colors.onPrimaryFixed,
                      ),
                    ),
                    title: Text(
                      LocalizationConstants.onboardingGenderTitleKey.tr(),
                      style: AppTextStyles.titleLarge.copyWith(
                        color: context.colors.onPrimaryFixed,
                      ),
                    ),
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
                                      child: GenderCard(
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
                                    const SizedBox(width: AppSpacing.spacing16),
                                    Expanded(
                                      child: GenderCard(
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
                                    LocalizationConstants.onboardingNextKey
                                        .tr(),
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
