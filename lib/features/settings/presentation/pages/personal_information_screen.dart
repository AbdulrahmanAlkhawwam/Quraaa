import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../domain/entities/personal_information.dart';
import '../widgets/personal_data_card.dart';
import '../widgets/personal_data_section.dart';
import '../widgets/personal_information_header.dart';

/// Screen that displays the user's personal information.
///
/// Data is bound from the backend profile fetched by
/// [ProfileBloc.add] with [ProfileLoadRequested].
class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (BuildContext context, ProfileState profileState) {
        final profile = profileState.profile;

        final PersonalInformation information = PersonalInformation(
          name: profile?.fullName ?? '',
          gender: profile?.genderLabel ?? '',
          birthday: profile?.dateOfBirth ?? '',
          phone: profile?.phoneNumber ?? '',
          avatarUrl: profile?.profileImageUrl,
        );

        return Scaffold(
          backgroundColor: AppColors.card,
          body: CustomScrollView(
            slivers: [
              PersonalInformationHeader(avatarUrl: information.avatarUrl),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
}
