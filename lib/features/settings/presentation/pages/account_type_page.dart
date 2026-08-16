import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/extensions/app_context.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../cubit/library_registration_cubit.dart';
import '../widgets/account_type_card.dart';
import '../widgets/library_registration_listener.dart';
import '../widgets/settings_palette.dart';

class AccountTypePage extends StatefulWidget {
  const AccountTypePage({super.key});

  @override
  State<AccountTypePage> createState() => _AccountTypePageState();
}

class _AccountTypePageState extends State<AccountTypePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<LibraryRegistrationCubit>().loadProfile();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<LibraryRegistrationCubit>().loadProfile();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SettingsPalette palette = SettingsPalette.of(context);

    return LibraryRegistrationListener(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: palette.background,
          statusBarIconBrightness:
              palette.isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
          systemNavigationBarIconBrightness:
              palette.isDark ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: palette.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 32),
              children: <Widget>[
                _AccountTypeHeader(palette: palette),
                const SizedBox(height: 20),
                AccountTypeCard(
                  minHeight: 108,
                  title: LocalizationConstants
                      .settingsAccountTypePersonalTitleKey
                      .tr(),
                  description: LocalizationConstants
                      .settingsAccountTypePersonalDescriptionKey
                      .tr(),
                  badgeText: LocalizationConstants
                      .settingsAccountTypeCurrentPlanKey
                      .tr(),
                  selected: true,
                  badgeColor: palette.accent,
                  badgeTextColor: palette.onAccent,
                ),
                /*const SizedBox(height: 26),*/
                /*AccountTypeCard(
                minHeight: 108,
                title: LocalizationConstants
                    .settingsAccountTypeFamilyTitleKey
                    .tr(),
                description: LocalizationConstants
                    .settingsAccountTypeFamilyDescriptionKey
                    .tr(),
              ),*/
                /*const SizedBox(height: 26),
              AccountTypeCard(
                minHeight: 90,
                title: LocalizationConstants.settingsAccountTypeProTitleKey
                    .tr(),
                description: LocalizationConstants
                    .settingsAccountTypeProDescriptionKey
                    .tr(),
                badgeText: '\$20/mo',
                badgeGradient: const LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: <Color>[Color(0xFF168068), Color(0xFF5A204F)],
                ),
                badgeTextColor: Colors.white,
              ),*/
                const SizedBox(height: 26),
                AccountTypeCard(
                  minHeight: 170,
                  title: LocalizationConstants
                      .settingsAccountTypeLibraryTitleKey
                      .tr(),
                  description: LocalizationConstants
                      .settingsAccountTypeLibraryDescriptionKey
                      .tr(),
                  footer: BlocBuilder<LibraryRegistrationCubit,
                      LibraryRegistrationState>(
                    builder: (
                      BuildContext context,
                      LibraryRegistrationState state,
                    ) {
                      if (state is LibraryProfileReady) {
                        return _LibraryProfileSummary(
                          name: state.profile.libraryName,
                          location: state.profile.location,
                          email: state.profile.email,
                          palette: palette,
                        );
                      }
                      final bool isLoading =
                          state is LibraryRegistrationLoading ||
                              state is LibraryProfileLoading;
                      return _CreateLibraryButton(
                        palette: palette,
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () => context
                                .read<LibraryRegistrationCubit>()
                                .requestRegistration(),
                      );
                    },
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

class _AccountTypeHeader extends StatelessWidget {
  const _AccountTypeHeader({required this.palette});

  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => context.back(),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 38, height: 38),
            icon: HugeIcon(
              icon: context.isRTL
                  ? HugeIcons.strokeRoundedArrowRight01
                  : HugeIcons.strokeRoundedArrowLeft01,
              color: palette.secondaryText,
              size: 23,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              LocalizationConstants.settingsProfileAccountTypeKey.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h3.copyWith(
                color: palette.text,
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateLibraryButton extends StatelessWidget {
  const _CreateLibraryButton({
    required this.palette,
    required this.isLoading,
    required this.onPressed,
  });

  final SettingsPalette palette;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SizedBox(
        height: 44,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor:
                palette.isDark ? palette.accent : AppColors.primary600,
            foregroundColor: Colors.white,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
            shape: const StadiumBorder(),
          ),
          child: isLoading
              ? const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      LocalizationConstants.settingsAccountTypeLibraryActionKey
                          .tr(),
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedLinkSquare02,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _LibraryProfileSummary extends StatelessWidget {
  const _LibraryProfileSummary({
    required this.name,
    required this.location,
    required this.email,
    required this.palette,
  });

  final String name;
  final String location;
  final String email;
  final SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.store_outlined, color: palette.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            <String>[name, location, email]
                .where((String value) => value.trim().isNotEmpty)
                .join('\n'),
            style: AppTextStyles.bodySmall.copyWith(color: palette.text),
          ),
        ),
      ],
    );
  }
}
