import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

class AssistantComposer extends StatelessWidget {
  const AssistantComposer({
    required this.controller,
    required this.scale,
    required this.onSubmit,
    required this.onPickBooks,
    super.key,
  });

  final TextEditingController controller;
  final double scale;
  final ValueChanged<String> onSubmit;
  final VoidCallback onPickBooks;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 100 * scale),
      padding: EdgeInsetsDirectional.fromSTEB(
        16 * scale,
        12 * scale,
        16 * scale,
        10 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
            onTap: () => onSubmit(controller.text),
            child: Container(
              width: 36 * scale,
              height: 36 * scale,
              decoration: const BoxDecoration(
                color: AppColors.primary600,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.send_rounded,
                  color: AppColors.card,
                  size: 19 * scale,
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: controller,
                    textAlign: TextAlign.end,
                  minLines: 1,
                  maxLines: 2,
                  textInputAction: TextInputAction.send,
                  onSubmitted: onSubmit,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.appTextPrimary,
                    fontSize: 14 * scale,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: 'اكتب “/” لربط مكتبة ما ....',
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary900.withValues(alpha: 0.4),
                      fontSize: 14 * scale,
                      height: 1.2,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
                SizedBox(height: 10 * scale),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: InkWell(
                    onTap: onPickBooks,
                    borderRadius: BorderRadius.circular(20 * scale),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 170 * scale),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale,
                        vertical: 6 * scale,
                      ),
                      decoration: BoxDecoration(
                      color: AppColors.card,
                        borderRadius: BorderRadius.circular(20 * scale),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.bookmark_add_outlined,
                            color: AppColors.primary300,
                            size: 18 * scale,
                          ),
                          SizedBox(width: 6 * scale),
                          Flexible(
                            child: Text(
                              LocalizationConstants.assistantComposerAddBookKey.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary300,
                                fontSize: 13 * scale,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
