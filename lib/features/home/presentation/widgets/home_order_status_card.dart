import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';

enum HomeOrderStatus { pending, processing, onDelivery, onDoor }

class HomeOrderStatusCard extends StatelessWidget {
  const HomeOrderStatusCard({
    super.key,
    this.orderNumber = '12425',
    this.status = HomeOrderStatus.onDoor,
    this.onPressed,
  });

  final String orderNumber;
  final HomeOrderStatus status;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color cardColor = context.isDark
        ? AppColors.settingsCardBackgroundDark
        : AppColors.settingsCardBackground;

    return Container(
      key: const ValueKey<String>('home-order-status-card'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.radius20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            LocalizationConstants.homeOrderNumberKey.tr(
              namedArgs: <String, String>{'number': orderNumber},
            ),
            style: AppTextStyles.titleLarge.copyWith(
              color: context.appTextPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing10),
          _OrderProgress(status: status),
          const SizedBox(height: AppSpacing.spacing12),
          _OrderActionButton(
            label: (status == HomeOrderStatus.onDoor
                    ? LocalizationConstants.homeOrderDeliveryArrivedKey
                    : LocalizationConstants.homeOrderViewPurchaseKey)
                .tr(),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _OrderProgress extends StatelessWidget {
  const _OrderProgress({required this.status});

  final HomeOrderStatus status;

  static const List<IconData> _icons = <IconData>[
    Icons.pending_actions_outlined,
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.door_front_door_outlined,
  ];

  static const List<String> _labelKeys = <String>[
    LocalizationConstants.homeOrderPendingKey,
    LocalizationConstants.homeOrderProcessingKey,
    LocalizationConstants.homeOrderOnDeliveryKey,
    LocalizationConstants.homeOrderOnDoorKey,
  ];

  @override
  Widget build(BuildContext context) {
    final int currentIndex = status.index;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int index = 0;
                index < HomeOrderStatus.values.length;
                index++) ...<Widget>[
              _StatusCircle(
                icon: _icons[index],
                isCompleted: index < currentIndex,
                isCurrent: index == currentIndex,
              ),
              if (index < HomeOrderStatus.values.length - 1)
                Expanded(
                  child: Container(
                    height: 3,
                    color: index < currentIndex
                        ? AppColors.primary600
                        : context.isDark
                            ? AppColors.primary800
                            : Colors.white.withValues(alpha: 0.72),
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.spacing6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int index = 0; index < _labelKeys.length; index++)
              Expanded(
                child: Text(
                  _labelKeys[index].tr(),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: _labelColor(context, index, currentIndex),
                    fontSize: 11,
                    height: 1.15,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Color _labelColor(BuildContext context, int index, int currentIndex) {
    if (index < currentIndex) return AppColors.primary500;
    if (index == currentIndex) return context.appTextSecondary;
    return context.isDark
        ? AppColors.primary800
        : AppColors.primary200.withValues(alpha: 0.62);
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
  });

  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isCompleted
        ? AppColors.primary600
        : isCurrent
            ? context.appCard
            : context.isDark
                ? AppColors.settingsCardBackgroundDark
                : Colors.white.withValues(alpha: 0.42);
    final Color iconColor = isCompleted
        ? Colors.white
        : isCurrent
            ? AppColors.primary600
            : context.isDark
                ? AppColors.primary800
                : AppColors.primary200.withValues(alpha: 0.64);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

class _OrderActionButton extends StatelessWidget {
  const _OrderActionButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appCard,
      shape: StadiumBorder(
        side: BorderSide(
          color: context.isDark ? AppColors.primary800 : AppColors.primary200,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          height: 46,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.buttonLarge.copyWith(
                color: context.appTextPrimary,
                fontSize: 19,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
