import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../bloc/onboarding_bloc.dart';

class AgeOnboardingPage extends StatefulWidget {
  const AgeOnboardingPage({super.key});

  @override
  State<AgeOnboardingPage> createState() => _AgeOnboardingPageState();
}

class _AgeOnboardingPageState extends State<AgeOnboardingPage> {
  final AuthLocalDataSource _authJourney = sl<AuthLocalDataSource>();

  @override
  void initState() {
    super.initState();
    unawaited(_authJourney.saveJourneyStage(AuthJourneyStage.onboardingAge));
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
                  title: LocalizationConstants.onboardingAgeTitleKey.tr(),
                  value: msg,
                ),
              );
            }
          },
          child: const _AgeOnboardingView(),
        ),
      ),
    );
  }
}

class _AgeOnboardingView extends StatelessWidget {
  const _AgeOnboardingView();

  String? _validateDate(OnboardingState state) {
    if (!state.hasBirthDate) return null;
    final DateTime parsed = DateTime(
      state.birthYear!,
      state.birthMonth!,
      state.birthDay!,
    );
    if (parsed.year != state.birthYear! ||
        parsed.month != state.birthMonth! ||
        parsed.day != state.birthDay!) {
      return LocalizationConstants.onboardingAgeInvalidDateKey.tr();
    }
    if (parsed.isAfter(DateTime.now())) {
      return LocalizationConstants.onboardingAgeInvalidDateKey.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final DateTime? selectedDate = state.hasBirthDate
            ? DateTime(state.birthYear!, state.birthMonth!, state.birthDay!)
            : null;
        final DateTime now = DateTime.now();
        final DateTime initialDate = selectedDate ??
            now.subtract(const Duration(days: 365 * 18));
        final String? dateError = _validateDate(state);

        const double pickerHeight = 220;
        const double itemHeight = 48;
        const double highlightPadding = 8;
        const double highlightTop =
            (pickerHeight / 2) - (itemHeight / 2) - (highlightPadding / 2);

        return OnboardingScaffold(
          title: LocalizationConstants.onboardingAgeTitleKey.tr(),
          leading: OnboardingBackButton(
            onPressed: () async {
              await sl<AuthLocalDataSource>().saveJourneyStage(
                AuthJourneyStage.onboarding,
                previousStage: AuthJourneyStage.onboardingAge,
              );
              if (context.mounted) context.goTo(RouteNames.onboarding);
            },
          ),
          actions: [
            OnboardingSkipButton(
              onPressed: () async {
                await sl<AuthLocalDataSource>().saveJourneyStage(
                  AuthJourneyStage.register,
                  previousStage: AuthJourneyStage.onboardingAge,
                );
                if (context.mounted) {
                  context.read<OnboardingBloc>().add(
                    const OnboardingSkipRequested(),
                  );
                }
              },
            ),
          ],
          activeIndex: 2,
          totalSteps: 3,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacing24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.radius32),
                  border: Border.all(color: AppColors.primary100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationConstants.onboardingAgeYearKey.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.libraryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing12),
                    SizedBox(
                      height: pickerHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: highlightTop,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: itemHeight + highlightPadding,
                              decoration: BoxDecoration(
                                color: AppColors.primary100,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.radius16,
                                ),
                              ),
                            ),
                          ),
                          DatePickerWidget(
                            initialDate: initialDate,
                            firstDate: DateTime(1900),
                            lastDate: now,
                            dateFormat: 'yyyy-MM-dd',
                            locale: DateTimePickerLocale.en_us,
                            looping: false,
                            pickerTheme: DateTimePickerTheme(
                              backgroundColor: Colors.transparent,
                              itemHeight: itemHeight,
                              pickerHeight: pickerHeight,
                              itemTextStyle: const TextStyle(
                                color: AppColors.libraryGreen,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              dividerColor: Colors.transparent,
                              dividerHeight: 0,
                              dividerThickness: 0,
                            ),
                            onChange: (dateTime, _) {
                              context.read<OnboardingBloc>().add(
                                OnboardingAgeYearChanged(dateTime.year),
                              );
                              context.read<OnboardingBloc>().add(
                                OnboardingAgeMonthChanged(dateTime.month),
                              );
                              context.read<OnboardingBloc>().add(
                                OnboardingAgeDayChanged(dateTime.day),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing8),
                    Text(
                      LocalizationConstants.onboardingAgeYearRangeKey.tr(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (dateError != null) ...[
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  dateError,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error500,
                  ),
                ),
              ],
            ],
          ),
          bottomButton: OnboardingNextButton(
            onPressed: state.canContinueAge
                ? () => context.read<OnboardingBloc>().add(
                      const OnboardingAgeNextRequested(),
                    )
                : null,
            isLoading: state.isLoading,
          ),
        );
      },
    );
  }
}
