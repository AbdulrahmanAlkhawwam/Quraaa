import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class BooksSearchBar extends StatelessWidget {
  const BooksSearchBar({required this.onChanged, required this.onFilterPressed, super.key});
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterPressed;
  @override
  Widget build(BuildContext context) => Container(height: 56, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary50, borderRadius: BorderRadius.circular(999)), child: Row(children: <Widget>[Expanded(child: TextField(onChanged: onChanged, decoration: const InputDecoration(prefixIcon: Icon(Icons.search, color: AppColors.primary600), hintText: 'Search', border: InputBorder.none))), IconButton(key: const Key('books_filter_button'), onPressed: onFilterPressed, icon: const Icon(Icons.tune_rounded, color: AppColors.primary600))]));
}
