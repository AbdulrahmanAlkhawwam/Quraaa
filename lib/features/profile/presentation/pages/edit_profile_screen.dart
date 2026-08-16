import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/update_profile_input.dart';
import '../cubit/profile_edit_cubit.dart';
import '../widgets/avatar_customization_tabs.dart';
import '../widgets/color_palette.dart';
import '../widgets/profile_preview_card.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({required this.profile, super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileEditCubit>(
      create: (_) => sl<ProfileEditCubit>(param1: profile),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _birthDateController;
  late final String _phoneNumber;
  late int _gender;
  Color _selectedBackgroundColor = AppColors.avatarDefaultBackground;

  @override
  void initState() {
    super.initState();
    final Profile profile = context.read<ProfileEditCubit>().state.profile;
    _fullNameController = TextEditingController(text: profile.fullName);
    _birthDateController = TextEditingController(
      text: _formatDateForDisplay(profile.dateOfBirth),
    );
    _phoneNumber = profile.phoneNumber?.trim() ?? '';
    _gender = ProfileGenderValue.normalize(profile.gender);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileEditCubit, ProfileEditState>(
      listenWhen: (ProfileEditState previous, ProfileEditState current) =>
          previous.error != current.error || previous.saved != current.saved,
      listener: (BuildContext context, ProfileEditState state) {
        if (state.error != null) {
          context.showResolvedErrorSnackBar(state.error);
        }
        if (state.saved) {
          Navigator.of(context).pop<Profile>(state.profile);
        }
      },
      builder: (BuildContext context, ProfileEditState state) {
        return Scaffold(
          backgroundColor: AppColors.editProfileBackground,
          appBar: _buildAppBar(context, state),
          body: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.spacing26,
                      AppSpacing.spacing6,
                      AppSpacing.spacing26,
                      AppSpacing.spacing32,
                    ),
                    children: <Widget>[
                      ProfilePreviewCard(
                        backgroundColor: _selectedBackgroundColor,
                      ),
                      const SizedBox(height: AppSpacing.spacing28),
                      AvatarCustomizationTabs(
                        selectedTab: 0,
                        onTabSelected: (_) {},
                      ),
                      const SizedBox(height: AppSpacing.spacing26),
                      ColorPalette(
                        selectedColor: _selectedBackgroundColor,
                        onColorSelected: (Color color) {
                          setState(() => _selectedBackgroundColor = color);
                        },
                      ),
                      const SizedBox(height: AppSpacing.spacing14),
                      Text(
                        LocalizationConstants.profileEditPersonalDataKey.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.editProfileSectionTitle,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing10),
                      _ProfileOutlinedField(
                        controller: _fullNameController,
                        hintText:
                            LocalizationConstants.profileEditFullNameKey.tr(),
                        textInputAction: TextInputAction.next,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: AppSpacing.spacing10),
                      _GenderField(
                        value: _gender,
                        enabled: !state.saving,
                        onChanged: (int value) {
                          setState(() => _gender = value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.spacing10),
                      _ProfileOutlinedField(
                        controller: _birthDateController,
                        hintText: LocalizationConstants
                            .profileEditBirthDateHintKey
                            .tr(),
                        readOnly: true,
                        enabled: !state.saving,
                        onTap: _pickBirthDate,
                      ),
                      const SizedBox(height: AppSpacing.spacing10),
                      _PhoneDisplayField(phoneNumber: _phoneNumber),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ProfileEditState state,
  ) {
    const Color foreground = AppColors.editProfileTitle;
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 72,
      backgroundColor: AppColors.editProfileBackground,
      titleSpacing: AppSpacing.spacing10,
      leadingWidth: 72,
      leading: Center(
        child: IconButton(
          onPressed: state.saving ? null : () => Navigator.of(context).pop(),
          icon: HugeIcon(
            icon: context.isRTL
                ? HugeIcons.strokeRoundedArrowRight01
                : HugeIcons.strokeRoundedArrowLeft01,
            color: foreground,
            size: 24,
          ),
        ),
      ),
      title: Text(
        LocalizationConstants.profileEditTitleKey.tr(),
        style: AppTextStyles.h4.copyWith(
          color: foreground,
          fontSize: 27,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(end: AppSpacing.spacing18),
          child: IconButton(
            tooltip: LocalizationConstants.commonSaveKey.tr(),
            onPressed: state.saving ? null : _save,
            icon: state.saving
                ? const SizedBox.square(
                    dimension: 21,
                    child: CircularProgressIndicator(
                      color: foreground,
                      strokeWidth: 2,
                    ),
                  )
                : const HugeIcon(
                    icon: HugeIcons.strokeRoundedSave,
                    color: foreground,
                    size: 25,
                  ),
          ),
        ),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocalizationConstants.profileEditRequiredKey.tr();
    }
    return null;
  }

  Future<void> _pickBirthDate() async {
    final DateTime initial =
        DateTime.tryParse(_birthDateController.text.replaceAll('/', '-')) ??
            DateTime(2005, 4, 21);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      _birthDateController.text = '${selected.year.toString().padLeft(4, '0')}/'
          '${selected.month.toString().padLeft(2, '0')}/'
          '${selected.day.toString().padLeft(2, '0')}';
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final Profile profile = context.read<ProfileEditCubit>().state.profile;
    final ({String firstName, String lastName}) name = _splitFullName(
      _fullNameController.text,
      profile,
    );

    context.read<ProfileEditCubit>().save(
          UpdateProfileInput(
            firstName: name.firstName,
            lastName: name.lastName,
            gender: _gender,
            dateOfBirth: _birthDateController.text.replaceAll('/', '-'),
            profileImageUrl: profile.profileImageUrl,
            interestIds: profile.interests
                .map((ProfileInterest interest) => interest.id)
                .toList(growable: false),
          ),
        );
  }

  ({String firstName, String lastName}) _splitFullName(
    String value,
    Profile profile,
  ) {
    final String normalized = value
        .trim()
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .join(' ');
    if (normalized == profile.fullName.trim()) {
      return (
        firstName: profile.firstName ?? '',
        lastName: profile.lastName ?? '',
      );
    }

    final List<String> parts = normalized.split(' ');
    return (
      firstName: parts.first,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
    );
  }

  String _formatDateForDisplay(String? value) {
    final String date = value?.trim() ?? '';
    return date.replaceAll('-', '/');
  }
}

class _ProfileOutlinedField extends StatelessWidget {
  const _ProfileOutlinedField({
    required this.controller,
    required this.hintText,
    this.textInputAction,
    this.validator,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.profileFieldHeight,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        textInputAction: textInputAction,
        validator: validator,
        style: _fieldTextStyle,
        decoration: _fieldDecoration(hintText),
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.profileFieldHeight,
      child: DropdownButtonFormField<int>(
        initialValue: value,
        isExpanded: true,
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedArrowDown01,
          color: AppColors.primary600,
          size: 20,
        ),
        style: _fieldTextStyle,
        dropdownColor: Colors.white,
        decoration: _fieldDecoration(
          LocalizationConstants.profileEditGenderKey.tr(),
        ),
        items: <DropdownMenuItem<int>>[
          DropdownMenuItem<int>(
            value: ProfileGenderValue.male,
            child: Text(
              LocalizationConstants.profileEditGenderMaleKey.tr(),
            ),
          ),
          DropdownMenuItem<int>(
            value: ProfileGenderValue.female,
            child: Text(
              LocalizationConstants.profileEditGenderFemaleKey.tr(),
            ),
          ),
        ],
        onChanged: enabled
            ? (int? selected) {
                if (selected != null) onChanged(selected);
              }
            : null,
      ),
    );
  }
}

class _PhoneDisplayField extends StatelessWidget {
  const _PhoneDisplayField({required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.profileFieldHeight,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.spacing14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.radius10),
        border: Border.all(color: AppColors.editProfileBorder),
      ),
      alignment: AlignmentDirectional.centerStart,
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Row(
          children: <Widget>[
            const Text('\u{1F1E6}\u{1F1EA}', style: TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpacing.spacing8),
            Expanded(
              child: Text(
                phoneNumber,
                style: _fieldTextStyle,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const TextStyle _fieldTextStyle = TextStyle(
  fontFamily: AppTextStyles.sansFont,
  color: AppColors.textSecondary,
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

InputDecoration _fieldDecoration(String hintText) {
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.radius10),
    borderSide: const BorderSide(color: AppColors.editProfileBorder),
  );
  return InputDecoration(
    hintText: hintText,
    hintStyle: _fieldTextStyle.copyWith(color: const Color(0xFFAEB4AA)),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsetsDirectional.symmetric(
      horizontal: AppSpacing.spacing18,
      vertical: AppSpacing.spacing16,
    ),
    border: border,
    enabledBorder: border,
    disabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.primary600, width: 1.2),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.error500),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.error500, width: 1.2),
    ),
  );
}
