import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

class AssistantPromptChips extends StatelessWidget {
  const AssistantPromptChips({
    required this.scale,
    required this.onPromptSelected,
    super.key,
  });

  final double scale;
  final ValueChanged<String> onPromptSelected;

  static const List<String> _promptKeys = <String>[
    LocalizationConstants.assistantPromptAuthorOverviewKey,
    LocalizationConstants.assistantPromptFindBookKey,
    LocalizationConstants.assistantPromptSummarizeKey,
    LocalizationConstants.assistantPromptMainTitlesKey,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10 * scale,
      runSpacing: 10 * scale,
      children: _promptKeys.map((String promptKey) {
        final String prompt = promptKey.tr();
        return _PromptChip(
          label: prompt,
          scale: scale,
          onTap: () => onPromptSelected(prompt),
        );
      }).toList(),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({
    required this.label,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22 * scale),
      child: Container(
        constraints: BoxConstraints(minWidth: 122 * scale),
        padding: EdgeInsets.symmetric(
          horizontal: 15 * scale,
          vertical: 8 * scale,
        ),
        decoration: BoxDecoration(
          color: context.appCard,
          borderRadius: BorderRadius.circular(22 * scale),
          border: Border.all(color: context.appBorder, width: 1.1),
        ),
        child: Text(
          label,
          maxLines: 1,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.isDark ? AppColors.primary300 : AppColors.primary600,
            fontSize: 17 * scale,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}
