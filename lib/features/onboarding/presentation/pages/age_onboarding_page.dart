import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../auth/data/datasources/local/auth_journey_local_data_source.dart';
import '../bloc/onboarding_bloc.dart';

class AgeOnboardingPage extends StatefulWidget {
  const AgeOnboardingPage({super.key});

  @override
  State<AgeOnboardingPage> createState() => _AgeOnboardingPageState();
}

class _AgeOnboardingPageState extends State<AgeOnboardingPage> {
  final AuthJourneyLocalDataSource _authJourney =
      sl<AuthJourneyLocalDataSource>();

  @override
  void initState() {
    super.initState();
    unawaited(_authJourney.saveJourneyStage(AuthJourneyStage.onboardingAge));
  }

  Future<void> _goBack() async {
    await _authJourney.saveJourneyStage(
      AuthJourneyStage.onboarding,
      previousStage: AuthJourneyStage.onboardingAge,
    );
    if (!mounted) return;
    context.goTo(RouteNames.onboarding);
  }

  Future<void> _skip() async {
    await _authJourney.saveJourneyStage(
      AuthJourneyStage.register,
      previousStage: AuthJourneyStage.onboardingAge,
    );
    if (!mounted) return;
    context.read<OnboardingBloc>().add(const OnboardingSkipRequested());
  }

  Future<void> _pickBirthDate(OnboardingState state) async {
    final DateTime now = DateTime.now();
    final DateTime initial = state.hasBirthDate
        ? DateTime(state.birthYear!, state.birthMonth!, state.birthDay!)
        : now.subtract(const Duration(days: 365 * 18));

    final DateTime? selected = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      dateFormat: 'yyyy-MM-dd',
      locale: DateTimePickerLocale.en_us,
      titleText: LocalizationConstants.onboardingAgeYearKey.tr(),
      cancelText: LocalizationConstants.onboardingSkipKey.tr(),
      confirmText: LocalizationConstants.onboardingNextKey.tr(),
      textColor: AppColors.libraryGreen,
      itemTextStyle: AppTextStyles.titleLarge,
    );

    if (selected == null || !mounted) return;

    context.read<OnboardingBloc>().add(OnboardingAgeYearChanged(selected.year));
    context.read<OnboardingBloc>().add(OnboardingAgeMonthChanged(selected.month));
    context.read<OnboardingBloc>().add(OnboardingAgeDayChanged(selected.day));
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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

  void _onNext() {
    context.read<OnboardingBloc>().add(const OnboardingAgeNextRequested());
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
          child: Builder(
            builder: (context) {
              return BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  final DateTime? selectedDate = state.hasBirthDate
                      ? DateTime(state.birthYear!, state.birthMonth!, state.birthDay!)
                      : null;
                  final String? dateError = _validateDate(state);

                  return OnboardingScaffold(
                    title: LocalizationConstants.onboardingAgeTitleKey.tr(),
                    leading: OnboardingBackButton(onPressed: _goBack),
                    actions: [OnboardingSkipButton(onPressed: _skip)],
                    activeIndex: 2,
                    totalSteps: 3,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GestureDetector(
                          onTap: state.isLoading ? null : () => _pickBirthDate(state),
                          child: Container(
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
                                Text(
                                  selectedDate == null
                                      ? LocalizationConstants.onboardingAgeRequiredKey.tr()
                                      : _formatDate(selectedDate),
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.textPrimary,
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
                      onPressed: state.canContinueAge ? _onNext : null,
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
}
