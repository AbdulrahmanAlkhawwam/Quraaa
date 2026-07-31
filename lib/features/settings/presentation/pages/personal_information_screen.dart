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
