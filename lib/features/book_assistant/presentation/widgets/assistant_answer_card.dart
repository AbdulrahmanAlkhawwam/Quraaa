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
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 72 * scale,
                  height: 96 * scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4 * scale),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=220&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Text(
                    'Global English\nCoursebook 10',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary900,
                      fontSize: 22 * scale,
                      height: 1.1,
                    ),
                  ),
                ),
                Icon(Icons.bookmark_border, color: AppColors.primary900, size: 16 * scale),
              ],
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            response.answer,
            textAlign: TextAlign.end,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary900,
              fontSize: 14 * scale,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
