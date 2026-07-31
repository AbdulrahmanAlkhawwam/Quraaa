$ErrorActionPreference = 'Stop'

$editPath = 'lib\features\profile\presentation\pages\edit_profile_screen.dart'
$edit = @'
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/update_profile_input.dart';
import '../cubit/profile_edit_cubit.dart';

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
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _phoneController;
  late int _gender;

  @override
  void initState() {
    super.initState();
    final Profile profile = context.read<ProfileEditCubit>().state.profile;
    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);
    _birthDateController = TextEditingController(text: profile.dateOfBirth);
    _phoneController = TextEditingController(text: profile.phoneNumber);
    _gender = profile.gender ?? 0;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileEditCubit, ProfileEditState>(
      listenWhen: (previous, current) =>
          previous.error != current.error || previous.saved != current.saved,
      listener: (context, state) {
        if (state.error != null) {
          context.showResolvedErrorSnackBar(state.error);
        }
        if (state.saved) {
          Navigator.of(context).pop<Profile>(state.profile);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.appBackground,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: context.appBackground,
            foregroundColor: context.isDark
                ? AppColors.primary300
                : AppColors.libraryGreen,
            title: Text(LocalizationConstants.profileEditTitleKey.tr()),
            actions: <Widget>[
              TextButton(
                onPressed: state.saving ? null : _save,
                child: state.saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(LocalizationConstants.commonSaveKey.tr()),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.spacing24),
              children: <Widget>[
                _ProfileImagePreview(url: state.profile.profileImageUrl),
                const SizedBox(height: AppSpacing.spacing24),
                TextFormField(
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: LocalizationConstants.profileEditFirstNameKey.tr(),
                  ),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: AppSpacing.spacing16),
                TextFormField(
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: LocalizationConstants.profileEditLastNameKey.tr(),
                  ),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: AppSpacing.spacing16),
                DropdownButtonFormField<int>(
                  initialValue: _gender,
                  decoration: InputDecoration(
                    labelText: LocalizationConstants.profileEditGenderKey.tr(),
                  ),
                  items: <DropdownMenuItem<int>>[
                    DropdownMenuItem<int>(
                      value: 0,
                      child: Text(
                        LocalizationConstants.profileEditGenderMaleKey.tr(),
                      ),
                    ),
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text(
                        LocalizationConstants.profileEditGenderFemaleKey.tr(),
                      ),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text(
                        LocalizationConstants.userDataGenderPreferNotToSayKey.tr(),
                      ),
                    ),
                  ],
                  onChanged: state.saving
                      ? null
                      : (int? value) => _gender = value ?? _gender,
                ),
                const SizedBox(height: AppSpacing.spacing16),
                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  onTap: state.saving ? null : _pickBirthDate,
                  decoration: InputDecoration(
                    labelText: LocalizationConstants.profileEditBirthDateKey.tr(),
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: AppSpacing.spacing16),
                TextFormField(
                  controller: _phoneController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: LocalizationConstants.profileEditPhoneNumberKey.tr(),
                    helperText: LocalizationConstants.profileEditPhoneReadOnlyKey.tr(),
                  ),
                ),
                if (state.profile.interests.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.spacing24),
                  Text(
                    LocalizationConstants.profileEditInterestsKey.tr(),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: context.appTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing8),
                  Wrap(
                    spacing: AppSpacing.spacing8,
                    runSpacing: AppSpacing.spacing8,
                    children: state.profile.interests
                        .map(
                          (interest) => Chip(
                            label: Text(
                              context.locale.languageCode == 'ar'
                                  ? interest.nameAr
                                  : interest.nameEn,
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
        DateTime.tryParse(_birthDateController.text) ?? DateTime(2000);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      _birthDateController.text =
          '${selected.year.toString().padLeft(4, '0')}-'
          '${selected.month.toString().padLeft(2, '0')}-'
          '${selected.day.toString().padLeft(2, '0')}';
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final Profile profile = context.read<ProfileEditCubit>().state.profile;
    context.read<ProfileEditCubit>().save(
      UpdateProfileInput(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _gender,
        dateOfBirth: _birthDateController.text,
        profileImageUrl: profile.profileImageUrl,
        interestIds: profile.interests
            .map((interest) => interest.id)
            .toList(growable: false),
      ),
    );
  }
}

class _ProfileImagePreview extends StatelessWidget {
  const _ProfileImagePreview({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 54,
        backgroundColor: context.appSubtleSurface,
        backgroundImage: url != null && url!.trim().isNotEmpty
            ? NetworkImage(url!)
            : null,
        child: url == null || url!.trim().isEmpty
            ? const Icon(Icons.person_outline_rounded, size: 52)
            : null,
      ),
    );
  }
}
'@
Set-Content -LiteralPath $editPath -Value $edit -NoNewline

$headerPath = 'lib\features\settings\presentation\widgets\personal_information_header.dart'
$header = Get-Content -Raw -LiteralPath $headerPath
$header = $header.Replace("import '../../../profile/presentation/pages/edit_profile_screen.dart';`r`n", '')
$header = $header.Replace('  const PersonalInformationHeader({super.key, this.avatarUrl});', '  const PersonalInformationHeader({super.key, this.avatarUrl, this.onEdit});')
$header = $header.Replace('  final String? avatarUrl;', "  final String? avatarUrl;`r`n  final VoidCallback? onEdit;")
$header = $header.Replace('          onPressed: () => _openEditProfile(context),', '          onPressed: onEdit,')
$openMethod = @'

  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const EditProfileScreen(),
      ),
    );
  }
'@
$header = $header.Replace($openMethod, '')
Set-Content -LiteralPath $headerPath -Value $header -NoNewline

$personalPath = 'lib\features\settings\presentation\pages\personal_information_screen.dart'
$personal = @'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/shared.dart';
import '../../../profile/profile.dart';
import '../../../profile/presentation/extensions/profile_model_ui_extensions.dart';
import '../../domain/entities/personal_information.dart';
import '../widgets/personal_data_card.dart';
import '../widgets/personal_data_section.dart';
import '../widgets/personal_information_header.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (BuildContext context, ProfileState profileState) {
        final Profile? profile = profileState.profile;
        if (profileState.loading && profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (profile == null) {
          return Scaffold(
            backgroundColor: context.appBackground,
            appBar: AppBar(),
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
          birthday: profile.dateOfBirth ?? '',
          phone: profile.phoneNumber ?? '',
          avatarUrl: profile.profileImageUrl,
        );

        return Scaffold(
          backgroundColor: context.appBackground,
          body: CustomScrollView(
            slivers: <Widget>[
              PersonalInformationHeader(
                avatarUrl: information.avatarUrl,
                onEdit: () => _openEditor(context, profile),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.spacing16),
                      const PersonalDataSection(),
                      const SizedBox(height: AppSpacing.spacing16),
                      PersonalDataCard(information: information),
                      const SizedBox(height: AppSpacing.spacing32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
'@
Set-Content -LiteralPath $personalPath -Value $personal -NoNewline

$extensionPath = 'lib\features\profile\presentation\extensions\profile_model_ui_extensions.dart'
$extension = Get-Content -Raw -LiteralPath $extensionPath
$extension = $extension.Replace("import '../../data/models/profile_model.dart';", "import '../../domain/entities/profile.dart';")
$extension = $extension.Replace('ProfileModelUiExtension on ProfileModel', 'ProfileModelUiExtension on Profile')
$extension = $extension.Replace('[ProfileModel]', '[Profile]')
Set-Content -LiteralPath $extensionPath -Value $extension -NoNewline
