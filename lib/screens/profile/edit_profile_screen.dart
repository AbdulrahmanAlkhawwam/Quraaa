import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/di/injection_container.dart';
import '../../core/localization/localization_constants.dart';
import '../../shared/shared.dart';
import 'bloc/edit_profile_bloc.dart';
import 'bloc/edit_profile_event.dart';
import 'bloc/edit_profile_state.dart';
import 'widgets/avatar_customization_tabs.dart';
import 'widgets/color_palette.dart';
import 'widgets/gender_dropdown.dart';
import 'widgets/phone_number_field.dart';
import 'widgets/profile_preview_card.dart';
import 'widgets/profile_text_field.dart';

/// Pixel-perfect Edit Profile screen.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EditProfileBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.editProfileBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _EditProfileHeader(),
                const SizedBox(height: AppSpacing.spacing24),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing24,
                  ),
                  child: BlocBuilder<EditProfileBloc, EditProfileState>(
                    builder: (
                      BuildContext context,
                      EditProfileState state,
                    ) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfilePreviewCard(
                            backgroundColor: state.selectedBackgroundColor,
                          ),
                          const SizedBox(height: AppSpacing.spacing18),
                          AvatarCustomizationTabs(
                            selectedTab: state.selectedTab,
                            onTabSelected: (int index) => context
                                .read<EditProfileBloc>()
                                .add(EditProfileTabSelected(index)),
                          ),
                          const SizedBox(height: AppSpacing.spacing18),
                          ColorPalette(
                            selectedColor: state.selectedBackgroundColor,
                            onColorSelected: (Color color) => context
                                .read<EditProfileBloc>()
                                .add(EditProfileBackgroundColorSelected(color)),
                          ),
                          const SizedBox(height: AppSpacing.spacing26),
                          Text(
                            LocalizationConstants
                                .profileEditPersonalDataKey
                                .tr(),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.editProfileSectionTitle,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacing18),
                          ProfileTextField(
                            label: LocalizationConstants
                                .profileEditFullNameKey
                                .tr(),
                            initialValue: state.name,
                            onChanged: (String value) => context
                                .read<EditProfileBloc>()
                                .add(EditProfileNameChanged(value)),
                          ),
                          const SizedBox(height: AppSpacing.spacing18),
                          GenderDropdown(
                            value: state.gender,
                            onChanged: (String value) => context
                                .read<EditProfileBloc>()
                                .add(EditProfileGenderChanged(value)),
                          ),
                          const SizedBox(height: AppSpacing.spacing18),
                          ProfileTextField(
                            label: LocalizationConstants
                                .profileEditBirthDateKey
                                .tr(),
                            hintText: LocalizationConstants
                                .profileEditBirthDateHintKey
                                .tr(),
                            initialValue: state.birthDate,
                            onChanged: (String value) => context
                                .read<EditProfileBloc>()
                                .add(EditProfileBirthDateChanged(value)),
                          ),
                          const SizedBox(height: AppSpacing.spacing18),
                          PhoneNumberField(
                            countryCode: LocalizationConstants
                                .profileEditCountryCodeKey
                                .tr(),
                            phoneNumber: state.phoneNumber,
                            onPhoneNumberChanged: (String value) => context
                                .read<EditProfileBloc>()
                                .add(EditProfilePhoneNumberChanged(value)),
                          ),
                        ],
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

class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing24,
        vertical: AppSpacing.spacing12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(AppRadius.radius12),
            child: Icon(
              CupertinoIcons.back,
              color: AppColors.editProfileTitle,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.spacing16),
          Expanded(
            child: Text(
              LocalizationConstants.profileEditTitleKey.tr(),
              style: AppTextStyles.h3.copyWith(
                color: AppColors.editProfileTitle,
              ),
            ),
          ),
          InkWell(
            onTap: () => _onSave(context),
            borderRadius: BorderRadius.circular(AppRadius.radius12),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedSave,
              color: AppColors.editProfileTitle,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  void _onSave(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LocalizationConstants.profileEditSaveComingSoonKey.tr(),
        ),
      ),
    );
  }
}
