// import 'dart:ui';
//
// import 'package:flutter/material.dart';
//
// import '../theme/app_colors.dart';
// import '../theme/app_spacing.dart';
//
// class QuraaaAppBar extends StatelessWidget implements PreferredSizeWidget {
//   const QuraaaAppBar({
//     super.key,
//     required this.title,
//     this.leading,
//     this.actions,
//     this.height = 64,
//     this.blurSigma = 8,
//   });
//
//   final Widget title;
//   final Widget? leading;
//   final List<Widget>? actions;
//   final double height;
//   final double blurSigma;
//
//   @override
//   Size get preferredSize => Size.fromHeight(height);
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       automaticallyImplyLeading: false,
//       toolbarHeight: height,
//       backgroundColor: Colors.transparent,
//       surfaceTintColor: Colors.transparent,
//       shadowColor: Colors.transparent,
//       elevation: 0,
//       centerTitle: true,
//       titleSpacing: 0,
//       flexibleSpace: ClipRect(
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
//           child: Container(
//             color: Colors.transparent,
//           ),
//         ),
//       ),
//       leadingWidth: 72,
//       leading: Padding(
//         padding: const EdgeInsetsDirectional.only(start: AppSpacing.spacing24),
//         child: Align(
//           alignment: AlignmentDirectional.centerStart,
//           child: leading,
//         ),
//       ),
//       title: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
//         child: DefaultTextStyle.merge(
//           style: Theme.of(context).appBarTheme.titleTextStyle ??
//               Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: AppColors.primary50,
//                   ) ??
//               const TextStyle(color: AppColors.primary50),
//           child: title,
//         ),
//       ),
//       actions: actions == null
//           ? null
//           : <Widget>[
//               Padding(
//                 padding: const EdgeInsetsDirectional.only(
//                   end: AppSpacing.spacing24,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: actions!,
//                 ),
//               ),
//             ],
//     );
//   }
// }
