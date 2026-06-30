import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../shared/theme/styles/text_styles.dart';
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

  static const Color _backgroundColor = Color(0xFFF7F7F5);
  static const Color _titleColor = Color(0xFF243B18);
  static const Color _sectionTitleColor = Color(0xFF2D3A27);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileBloc(),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: BlocBuilder<EditProfileBloc, EditProfileState>(
                    builder: (BuildContext context, EditProfileState state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProfilePreviewCard(
                            backgroundColor: state.selectedBackgroundColor,
                          ),
                          const SizedBox(height: 18),
                          AvatarCustomizationTabs(
                            selectedTab: state.selectedTab,
                            onTabSelected: (int index) => context
                                .read<EditProfileBloc>()
                                .add(EditProfileTabSelected(index)),
                          ),
                          const SizedBox(height: 18),
                          ColorPalette(
                            selectedColor: state.selectedBackgroundColor,
                            onColorSelected: (Color color) => context
                                .read<EditProfileBloc>()
                                .add(EditProfileBackgroundColorSelected(color)),
                          ),
                          const SizedBox(height: 26),
                          Text(
                            'Personal Data',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: _sectionTitleColor,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ProfileTextField(
                            label: 'Full Name',
                            initialValue: state.name,
                            onChanged: (String value) => context
                                .read<EditProfileBloc>()
                                .add(EditProfileNameChanged(value)),
                          ),
                          const SizedBox(height: 18),
                          GenderDropdown(
                            value: state.gender,
                            onChanged: (String value) => context
                                .read<EditProfileBloc>()
                                .add(EditProfileGenderChanged(value)),
                          ),
                          const SizedBox(height: 18),
                          ProfileTextField(
                            label: 'Birth Date',
                            hintText: '2005/04/21',
                            initialValue: state.birthDate,
                            onChanged: (String value) => context
                                .read<EditProfileBloc>()
                                .add(EditProfileBirthDateChanged(value)),
                          ),
                          const SizedBox(height: 18),
                          PhoneNumberField(
                            countryCode: '+971',
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: const Icon(
              CupertinoIcons.back,
              color: Color(0xFF243B18),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Edit Profile',
              style: AppTextStyles.h3.copyWith(
                color: _titleColor,
              ),
            ),
          ),
          InkWell(
            onTap: () => _onSave(context),
            borderRadius: BorderRadius.circular(12),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedSave,
              color: Color(0xFF243B18),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  void _onSave(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved - Coming Soon'),
      ),
    );
  }
}
