import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/shared.dart';
import '../widgets/home_feature_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeFeatureScreen(
      title: 'Cart',
      subtitle: 'Ready for checkout',
      description:
          'Review selected items, update quantities, and move to checkout when you are ready to continue reading.',
      icon: HugeIcons.strokeRoundedShoppingCart01,
      accentColor: AppColors.success500,
    );
  }
}
