import 'dart:async';

import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/widgets/onboarding_progress_indicator.dart';
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

  Future<void> _goBack(BuildContext blocContext) async {
    await _authJourney.saveJourneyStage(
      AuthJourneyStage.onboarding,
      previousStage: AuthJourneyStage.onboardingAge,
    );
    if (!blocContext.mounted) {
      return;
    }
    blocContext.goTo(RouteNames.onboarding);
  }

  Future<void> _skip(BuildContext blocContext) async {
    await _authJourney.saveJourneyStage(
      AuthJourneyStage.register,
      previousStage: AuthJourneyStage.onboardingAge,
    );
    if (!blocContext.mounted) {
      return;
    }
    blocContext.read<OnboardingBloc>().add(const OnboardingSkipRequested());
  }

  String? _validateCombinedDate(OnboardingState state) {
    if (!state.hasBirthDate) {
      return LocalizationConstants.onboardingAgeRequiredKey.tr();
    }

    final int year = state.birthYear!;
    final int month = state.birthMonth!;
    final int day = state.birthDay!;
    final DateTime parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return LocalizationConstants.onboardingAgeInvalidDateKey.tr();
    }
    if (parsed.isAfter(DateTime.now())) {
      return LocalizationConstants.onboardingAgeInvalidDateKey.tr();
    }

    return null;
  }

  DateTime _initialPickerDate(OnboardingState state) {
    final DateTime now = DateTime.now();
    if (!state.hasBirthDate) {
      return now.subtract(const Duration(days: 365 * 18));
    }

    final DateTime selected =
        DateTime(state.birthYear!, state.birthMonth!, state.birthDay!);
    if (selected.isAfter(now)) {
      return now.subtract(const Duration(days: 365 * 18));
    }

    return selected;
  }

  Future<void> _pickBirthDate(
    BuildContext context,
    OnboardingState state,
  ) async {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final DateTime now = DateTime.now();
    final DateTime? selected = await showCupertinoCalendarPicker(
      context,
      widgetRenderBox: renderBox,
      minimumDateTime: DateTime(1900),
      maximumDateTime: now,
      initialDateTime: _initialPickerDate(state),
      currentDateTime: now,
      mode: CupertinoCalendarMode.date,
    );

    if (selected == null || !mounted) {
      return;
    }

    context.read<OnboardingBloc>().add(OnboardingAgeYearChanged(selected.year));
    context
        .read<OnboardingBloc>()
        .add(OnboardingAgeMonthChanged(selected.month));
    context.read<OnboardingBloc>().add(OnboardingAgeDayChanged(selected.day));
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (_) => sl<OnboardingBloc>()..add(const OnboardingStarted()),
      child: Builder(
        builder: (blocContext) {
          return BlocListener<OnboardingBloc, OnboardingState>(
            listenWhen: (previous, current) =>
                previous.navigationTarget != current.navigationTarget &&
                current.navigationTarget != null,
            listener: (context, state) {
              final String? target = state.navigationTarget;
              if (target != null) {
                context.goTo(target);
              }
            },
            child: Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing24,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.spacing8),
                      Row(
                        children: [
                          if (context.isRTL) ...<Widget>[
                            TextButton(
                              onPressed: () => _skip(blocContext),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                LocalizationConstants.onboardingSkipKey.tr(),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            _RoundIconButton(
                              icon: HugeIcons.strokeRoundedArrowLeft01,
                              onPressed: () => _goBack(blocContext),
                            ),
                          ] else ...<Widget>[
                            _RoundIconButton(
                              icon: HugeIcons.strokeRoundedArrowLeft01,
                              onPressed: () => _goBack(blocContext),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => _skip(blocContext),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                LocalizationConstants.onboardingSkipKey.tr(),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spacing24),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          LocalizationConstants.onboardingAgeTitleKey.tr(),
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing32),
                      Expanded(
                        child: BlocBuilder<OnboardingBloc, OnboardingState>(
                          builder: (context, state) {
                            final String? dateError =
                                _validateCombinedDate(state);
                            final DateTime? selectedDate = state.hasBirthDate
                                ? DateTime(
                                    state.birthYear!,
                                    state.birthMonth!,
                                    state.birthDay!,
                                  )
                                : null;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                GestureDetector(
                                  onTap: state.isLoading
                                      ? null
                                      : () => _pickBirthDate(context, state),
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.spacing24,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.radius32,
                                      ),
                                      border: Border.all(
                                        color: AppColors.primary100,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          LocalizationConstants
                                              .onboardingAgeYearKey
                                              .tr(),
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.libraryGreen,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppSpacing.spacing12,
                                        ),
                                        Text(
                                          selectedDate == null
                                              ? LocalizationConstants
                                                  .onboardingAgeRequiredKey
                                                  .tr()
                                              : _formatDate(selectedDate),
                                          style: AppTextStyles.titleLarge
                                              .copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: AppSpacing.spacing8,
                                        ),
                                        Text(
                                          LocalizationConstants
                                              .onboardingAgeYearRangeKey
                                              .tr(),
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
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
                            );
                          },
                        ),
                      ),
                      const OnboardingProgressIndicator(
                        activeIndex: 2,
                        count: 3,
                      ),
                      const SizedBox(height: AppSpacing.spacing24),
                      BlocBuilder<OnboardingBloc, OnboardingState>(
                        builder: (context, state) {
                          return SizedBox(
                            height: AppDimensions.onboardingButtonHeight,
                            child: FilledButton(
                              onPressed: state.canContinueAge
                                  ? () => context.read<OnboardingBloc>().add(
                                        const OnboardingAgeNextRequested(),
                                      )
                                  : null,
                              child: Text(
                                LocalizationConstants.onboardingNextKey.tr(),
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
            ),
          );
        },
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
  });

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
