import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/assistant_response.dart';

class AssistantAnswerCard extends StatelessWidget {
  const AssistantAnswerCard({
    required this.response,
    required this.scale,
    super.key,
  });

  final AssistantResponse response;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: context.appSubtleSurface,
        borderRadius: BorderRadius.circular(22 * scale),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            response.question,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.appTextPrimary,
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            response.answer,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.appTextSecondary,
              fontSize: 14 * scale,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
