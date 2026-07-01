import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/routes/route_resolver.dart';
import '../../../../shared/shared.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_redirectToStartupRoute());
  }

  Future<void> _redirectToStartupRoute() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final String targetRoute = await resolveStartupRoute();
    if (!mounted) {
      return;
    }

    if (targetRoute == RouteNames.splash) {
      context.goTo(RouteNames.auth);
      return;
    }

    context.goTo(targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              AppColors.libraryGreen,
              AppColors.primary900,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlutterLogo(size: 84),
              SizedBox(height: 20),
              Text(
                'Quraaa',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
