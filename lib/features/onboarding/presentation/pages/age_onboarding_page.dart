import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/widgets/onboarding_scaffold.dart';
import '../../../auth/auth.dart';
import '../bloc/onboarding_bloc.dart';

class AgeOnboardingPage extends StatefulWidget {
  const AgeOnboardingPage({super.key});

  @override
  State<AgeOnboardingPage> createState() => _AgeOnboardingPageState();
}

class _AgeOnboardingPageState extends State<AgeOnboardingPage> {
  late final AuthJourneyCubit _journeyCubit = sl<AuthJourneyCubit>();

  @override
  void initState() {
    super.initState();
    unawaited(_journeyCubit.enterOnboardingAge());
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
        listenWhen: (previous, current) =>
            previous.navigationTarget != current.navigationTarget &&
            current.navigationTarget != null,
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
              current.errorMessage != null &&
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            final msg = state.errorMessage;
            if (msg != null) {
              context.showErrorSnackBar(
                  message: Message(title: '', value: msg.tr()),
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
        final DateTime now = DateTime.now();
        final DateTime initialDate = state.hasBirthDate
            ? DateTime(state.birthYear!, state.birthMonth!, state.birthDay!)
            : now.subtract(const Duration(days: 365 * 18));

        final String? dateError = _validateDate(state);

        return OnboardingScaffold(
          title: LocalizationConstants.onboardingAgeTitleKey.tr(),
          leading: OnboardingBackButton(
            onPressed: () async {
              await context.read<AuthJourneyCubit>().moveFromAgeToOnboarding();
              if (context.mounted) context.goTo(RouteNames.onboarding);
            },
          ),
          actions: [
            OnboardingSkipButton(
              onPressed: () async {
                await context.read<AuthJourneyCubit>().moveFromAgeToRegister();
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
              Expanded(
                child: _DateWheelPicker(
                  initialYear: initialDate.year,
                  initialMonth: initialDate.month,
                  initialDay: initialDate.day,
                  onChanged: (date) {
                    context.read<OnboardingBloc>().add(
                      OnboardingAgeYearChanged(date.year),
                    );
                    context.read<OnboardingBloc>().add(
                      OnboardingAgeMonthChanged(date.month),
                    );
                    context.read<OnboardingBloc>().add(
                      OnboardingAgeDayChanged(date.day),
                    );
                  },
                ),
              ),
              if (dateError != null) ...[
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  dateError,
                  textAlign: TextAlign.center,
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

class _DateWheelPicker extends StatefulWidget {
  const _DateWheelPicker({
    required this.initialYear,
    required this.initialMonth,
    required this.initialDay,
    required this.onChanged,
  });

  final int initialYear;
  final int initialMonth;
  final int initialDay;
  final ValueChanged<DateTime> onChanged;

  @override
  State<_DateWheelPicker> createState() => _DateWheelPickerState();
}

class _DateWheelPickerState extends State<_DateWheelPicker> {
  late final FixedExtentScrollController _yearController;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _dayController;

  late final List<int> _years;
  late final List<int> _months;
  late List<int> _days;

  static const double _itemHeight = 56;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    _years = List<int>.generate(now.year - 1899, (i) => 1900 + i);
    _months = List<int>.generate(12, (i) => i + 1);
    _days = _generateDays(widget.initialYear, widget.initialMonth);

    final yearIndex = _years.indexOf(widget.initialYear);
    final monthIndex = _months.indexOf(widget.initialMonth);
    final dayIndex = _days.indexOf(widget.initialDay);

    assert(yearIndex >= 0, 'Initial year ${widget.initialYear} not in range');
    assert(monthIndex >= 0, 'Initial month ${widget.initialMonth} not in range');
    assert(dayIndex >= 0, 'Initial day ${widget.initialDay} not in month');

    _yearController = FixedExtentScrollController(
      initialItem: yearIndex.clamp(0, _years.length - 1),
    );
    _monthController = FixedExtentScrollController(
      initialItem: monthIndex.clamp(0, _months.length - 1),
    );
    _dayController = FixedExtentScrollController(
      initialItem: dayIndex.clamp(0, _days.length - 1),
    );
  }

  List<int> _generateDays(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List<int>.generate(daysInMonth, (i) => i + 1);
  }

  void _updateDays() {
    final year = _years[_yearController.selectedItem];
    final month = _months[_monthController.selectedItem];
    final newDays = _generateDays(year, month);

    if (!listEquals(_days, newDays)) {
      _days = newDays;

      if (_dayController.selectedItem >= newDays.length) {
        _dayController.jumpToItem(newDays.length - 1);
      }

      setState(() {});
    }
  }

  void _notifyChange() {
    final year = _years[_yearController.selectedItem];
    final month = _months[_monthController.selectedItem];
    final day = _days[_dayController.selectedItem];
    widget.onChanged(DateTime(year, month, day));
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Column labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  LocalizationConstants.onboardingAgeYearKey.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: context.appTextPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  LocalizationConstants.onboardingAgeMonthKey.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: context.appTextPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  LocalizationConstants.onboardingAgeDayKey.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: context.appTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spacing16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _WheelColumn(
                  controller: _yearController,
                  items: _years,
                  onChanged: (_) {
                    _updateDays();
                    _notifyChange();
                  },
                  itemHeight: _itemHeight,
                ),
              ),
              Expanded(
                child: _WheelColumn(
                  controller: _monthController,
                  items: _months,
                  onChanged: (_) {
                    _updateDays();
                    _notifyChange();
                  },
                  itemHeight: _itemHeight,
                ),
              ),
              Expanded(
                child: _WheelColumn(
                  controller: _dayController,
                  items: _days,
                  onChanged: (_) => _notifyChange(),
                  itemHeight: _itemHeight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WheelColumn extends StatelessWidget {
  const _WheelColumn({
    required this.controller,
    required this.items,
    required this.onChanged,
    required this.itemHeight,
  });

  final FixedExtentScrollController controller;
  final List<int> items;
  final ValueChanged<int> onChanged;
  final double itemHeight;


  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Selected item highlight
        Container(
          height: itemHeight + 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: context.appSubtleSurface,
            borderRadius: BorderRadius.circular(AppRadius.radius12),
          ),
        ),
        // Wheel
        ListWheelScrollView(
          controller: controller,
          itemExtent: itemHeight,
          physics: const FixedExtentScrollPhysics(),
          perspective: 0.003,
          diameterRatio: 2.0,
          overAndUnderCenterOpacity: 0.25,
          onSelectedItemChanged: onChanged,
          children: items.map((item) {
            return Center(
              child: Text(
                item.toString(),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: context.isDark ? AppColors.primary300 : AppColors.libraryGreen,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
