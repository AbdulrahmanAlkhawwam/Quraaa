import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/env/env.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

class AssistantHeader extends StatelessWidget {
  const AssistantHeader({
    required this.scale,
    required this.onMenuPressed,
    super.key,
  });

  final double scale;
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = context.isDark
        ? AppColors.primary300
        : AppColors.libraryGreen;
    final String storedName =
        sl<UserContextProvider>().snapshot.userName?.trim() ?? '';
    final String displayName = storedName.isEmpty
        ? Env.appName
        : storedName.split(RegExp(r'\s+')).first;

    return SizedBox(
      height: 64 * scale,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onMenuPressed,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: 32 * scale,
              height: 32 * scale,
            ),
            icon: Icon(
              Icons.menu,
              color: AppColors.primary900,
              size: 24 * scale,
            ),
          ),
          SizedBox(width: 24 * scale),
          Expanded(
            child: Text(
              LocalizationConstants.assistantGreetingKey.tr(
                namedArgs: <String, String>{'name': displayName},
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h3.copyWith(
                color: titleColor,
                fontSize: 22 * scale,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ),
          Icon(
            Icons.notifications_none,
            color: AppColors.primary900,
            size: 24 * scale,
          ),
        ],
      ),
    );
  }
}
