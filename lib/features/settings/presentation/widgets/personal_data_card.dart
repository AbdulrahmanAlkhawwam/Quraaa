import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../domain/entities/personal_information.dart';
import 'personal_data_row.dart';

/// Card that displays the four personal information rows.
class PersonalDataCard extends StatelessWidget {
  const PersonalDataCard({
    super.key,
    required this.information,
  });

  final PersonalInformation information;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.radius32),
        border: Border.all(
          color: AppColors.primary100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildRows(),
      ),
    );
  }

  List<Widget> _buildRows() {
    final List<String> values = <String>[
      information.name,
      information.gender,
      information.birthday,
      information.phone,
    ];

    final List<Widget> rows = <Widget>[];

    for (int index = 0; index < values.length; index++) {
      final bool isLast = index == values.length - 1;

      rows.add(
        PersonalDataRow(value: values[index]),
      );

      if (!isLast) {
        rows.add(
          const Divider(
            height: 1,
            indent: AppSpacing.spacing20,
            endIndent: AppSpacing.spacing20,
            color: AppColors.primary100,
          ),
        );
      }
    }

    return rows;
  }
}
