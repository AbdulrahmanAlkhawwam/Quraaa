import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

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
      constraints: BoxConstraints(minHeight: 92 * scale),
      padding: EdgeInsets.fromLTRB(
        14 * scale,
        12 * scale,
        14 * scale,
        10 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
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
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedMic01,
                    color: Colors.white,
                    size: 19 * scale,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    TextField(
                      controller: controller,
                      textAlign: TextAlign.right,
                      minLines: 1,
                      maxLines: 2,
                      textInputAction: TextInputAction.send,
                      onSubmitted: onSubmit,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14 * scale,
                        height: 1.2,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        hintText:
                            '\u0627\u0643\u062A\u0628 "/" \u0644\u0631\u0628\u0637 \u0645\u0643\u062A\u0628\u0629 \u0645\u0627 ....',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary.withValues(alpha: 0.62),
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
                      alignment: AlignmentDirectional.centerStart,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20 * scale),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedAdd01,
                                color: AppColors.primary600,
                                size: 18 * scale,
                              ),
                              SizedBox(width: 6 * scale),
                              Flexible(
                                child: Text(
                                  '\u0623\u0636\u0641 \u0643\u062A\u0627\u0628 \u0623\u0648 \u0645\u0643\u062A\u0628\u0629',
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
            ),
          ],
        ),
      ),
    );
  }
}