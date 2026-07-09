import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/routes/route_resolver.dart';
import '../../../../core/localization/localization_constants.dart';
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FlutterLogo(size: 84),
              const SizedBox(height: 20),
              Text(
                LocalizationConstants.appNameKey.tr(),
                style: const TextStyle(
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
