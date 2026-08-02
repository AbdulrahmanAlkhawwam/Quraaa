import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';

import '../../../../shared/theme/styles/text_styles.dart';

/// A single read-only row inside [PersonalDataCard].
///
/// The text is vertically centered and left aligned, matching the row style
/// used throughout the Settings screen.
class PersonalDataRow extends StatelessWidget {
  const PersonalDataRow({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 15, 18, 15),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: context.appTextSecondary,
          ),
        ),
      ),
    );
  }
}
