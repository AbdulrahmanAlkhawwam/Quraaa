//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(AppSpacing.spacing16),
//       child: Material(
//         color: AppColors.card,
//         borderRadius: BorderRadius.circular(AppRadius.radius32),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(AppSpacing.spacing20),
//               child: Row(
//                 children: <Widget>[
//                   HugeIcon(
//                     icon: HugeIcons.strokeRoundedNotification01,
//                     color: AppColors.libraryGreen,
//                     size: 24,
//                   ),
//                   const SizedBox(width: AppSpacing.spacing12),
//                   Expanded(
//                     child: Text(
//                       'Notifications',
//                       style: AppTextStyles.h3.copyWith(
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                   ),
//                   if (notifications.isNotEmpty)
//                     TextButton(
//                       onPressed: () {
//                         onClear();
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text('Clear'),
//                     ),
//                 ],
//               ),
//             ),
//             const Divider(height: 1),
//             if (notifications.isEmpty)
//               const Padding(
//                 padding: EdgeInsets.all(AppSpacing.spacing32),
//                 child: Text(
//                   'No notifications yet',
//                   style: TextStyle(color: AppColors.textSecondary),
//                 ),
//               )
//             else
//               Flexible(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: notifications.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     final RemoteMessage msg = notifications[index];
//                     return ListTile(
//                       leading: Container(
//                         padding: const EdgeInsets.all(AppSpacing.spacing8),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary100,
//                           borderRadius: BorderRadius.circular(AppRadius.radius12),
//                         ),
//                         child: HugeIcon(
//                           icon: HugeIcons.strokeRoundedNotification01,
//                           color: AppColors.primary600,
//                           size: 20,
//                         ),
//                       ),
//                       title: Text(
//                         msg.notification?.title ?? 'Notification',
//                         style: AppTextStyles.bodyLarge.copyWith(
//                           color: AppColors.textPrimary,
//                         ),
//                       ),
//                       subtitle: Text(
//                         msg.notification?.body ?? '',
//                         style: AppTextStyles.bodySmall.copyWith(
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             const SizedBox(height: AppSpacing.spacing16),
//           ],
//         ),
//       ),
//     );
//   }
// }
