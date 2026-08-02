import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../profile/profile.dart';
import '../../../profile/presentation/extensions/profile_model_ui_extensions.dart';
import '../../domain/entities/personal_information.dart';
import '../widgets/personal_data_card.dart';
import '../widgets/personal_data_section.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (BuildContext context, ProfileState profileState) {
        final Profile? profile = profileState.profile;
        if (profileState.loading && profile == null) {
          return Scaffold(
            backgroundColor: context.appBackground,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (profile == null) {
          return Scaffold(
            backgroundColor: context.appBackground,
            appBar: AppBar(backgroundColor: context.appBackground),
            body: Center(
              child: Icon(
                Icons.person_off_outlined,
                size: 64,
                color: context.appTextSecondary,
              ),
            ),
          );
        }

        final PersonalInformation information = PersonalInformation(
          name: profile.fullName,
          gender: profile.localizedGenderLabel,
          birthday: _displayDate(profile.dateOfBirth),
          phone: profile.phoneNumber ?? '',
          avatarUrl: profile.profileImageUrl,
        );

        return Scaffold(
          backgroundColor: context.appBackground,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                _PersonalInformationAppBar(
                  onEdit: () => _openEditor(context, profile),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      28,
                      6,
                      28,
                      32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _ProfileBanner(avatarUrl: information.avatarUrl),
                        const SizedBox(height: 27),
                        const PersonalDataSection(),
                        const SizedBox(height: 10),
                        PersonalDataCard(information: information),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _displayDate(String? raw) {
    final DateTime? date = DateTime.tryParse(raw ?? '');
    if (date == null) return raw ?? '';
    return '${date.year.toString().padLeft(4, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _openEditor(BuildContext context, Profile profile) async {
    final Profile? updated = await Navigator.of(context).push<Profile>(
      MaterialPageRoute<Profile>(
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );
    if (updated != null && context.mounted) {
      context.read<ProfileBloc>().add(ProfileReplaced(updated));
    }
  }
}

class _PersonalInformationAppBar extends StatelessWidget {
  const _PersonalInformationAppBar({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final Color foreground = context.isDark
        ? AppColors.primary300
        : AppColors.libraryGreen;
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: HugeIcon(
                icon: context.isRTL
                    ? HugeIcons.strokeRoundedArrowRight01
                    : HugeIcons.strokeRoundedArrowLeft01,
                color: foreground,
                size: 24,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                LocalizationConstants.profilePersonalTitleKey.tr(),
                style: AppTextStyles.h3.copyWith(
                  color: foreground,
                  fontSize: 29,
                ),
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedEdit03,
                color: foreground,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final String url = avatarUrl?.trim() ?? '';
    return Container(
      height: 244,
      decoration: BoxDecoration(
        color: const Color(0xFF78D8E9),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsetsDirectional.only(top: 18),
      child: url.isEmpty
          ? SvgPicture.asset(
              AppIcons.man,
              height: 190,
              alignment: Alignment.bottomCenter,
            )
          : AppImage(
              url,
              fit: BoxFit.contain,
              isFile: false,
              errorWidget: SvgPicture.asset(AppIcons.man, height: 190),
            ),
    );
  }
}
