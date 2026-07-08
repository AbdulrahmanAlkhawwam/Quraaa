import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

class AssistantPromptChips extends StatelessWidget {
  const AssistantPromptChips({
    required this.scale,
    required this.onPromptSelected,
    super.key,
  });

  final double scale;
  final ValueChanged<String> onPromptSelected;

  static const List<String> _prompts = <String>[
    '\u0644\u0645\u062D\u0629 \u0639\u0646 \u0627\u0644\u0643\u0627\u062A\u0628',
    '\u062F\u0644\u0646\u064A \u0639\u0644\u0649 \u0645\u0627 \u0623\u0631\u064A\u062F',
    '\u0644\u062E\u0635 \u064A\u0627 \u0643\u062A\u0627\u0628',
    '\u0627\u0644\u0639\u0646\u0627\u0648\u064A\u0646 \u0627\u0644\u0631\u0626\u064A\u0633\u064A\u0629',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10 * scale,
        runSpacing: 10 * scale,
        children: _prompts.map((String prompt) {
          return _PromptChip(
            label: prompt,
            scale: scale,
            onTap: () => onPromptSelected(prompt),
          );
        }).toList(),
      ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(22 * scale),
          border: Border.all(color: AppColors.primary200, width: 1.1),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary600,
              fontSize: 17 * scale,
              height: 1.05,
            ),
          ),
        ),
      ),
    );
  }
}