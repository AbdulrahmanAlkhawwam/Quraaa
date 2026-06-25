import 'package:flutter/material.dart';

class ExplorerLoadingView extends StatelessWidget {
  const ExplorerLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
