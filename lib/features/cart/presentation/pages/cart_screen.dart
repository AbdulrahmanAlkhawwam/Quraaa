import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../orders/orders.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/cart_view.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.openCheckoutOnLoad = false});

  final bool openCheckoutOnLoad;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CartBloc>(
          create: (_) => sl<CartBloc>()..add(const CartStarted()),
        ),
        BlocProvider<CheckoutCubit>(create: (_) => sl<CheckoutCubit>()),
      ],
      child: CartView(openCheckoutOnLoad: openCheckoutOnLoad),
    );
  }
}
