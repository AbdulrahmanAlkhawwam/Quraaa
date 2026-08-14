import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/routes/route_resolver.dart';
import '../../../../core/assets/app_images.dart';
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color background = isDark
        ? AppColors.neutralBackgroundDark
        : AppColors.primary50;
    final Brightness iconBrightness =
        isDark ? Brightness.light : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: background,
        statusBarIconBrightness: iconBrightness,
        systemNavigationBarColor: background,
        systemNavigationBarIconBrightness: iconBrightness,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const _SplashBookMark(),
                const SizedBox(height: 24),
                SvgPicture.asset(
                  AppImages.quraaaWordmark,
                  width: 113.273,
                  height: 33.404,
                  fit: BoxFit.contain,
                  semanticsLabel: LocalizationConstants.appNameKey.tr(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashBookMark extends StatelessWidget {
  const _SplashBookMark();

  static const List<_BookLayer> _layers = <_BookLayer>[
    _BookLayer(width: 63.545, height: 48, color: Color(0xFF89E219), radius: 24),
    _BookLayer(
      width: 77.667,
      height: 34.909,
      color: Color(0xFF58CC02),
      radius: 16,
    ),
    _BookLayer(
      width: 91.788,
      height: 21.818,
      color: Color(0xFF43C000),
      radius: 8,
    ),
    _BookLayer(
      width: 105.909,
      height: 8.727,
      color: Color(0xFFA56644),
      radius: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 183.576,
      height: 48,
      child: Stack(
        alignment: Alignment.topCenter,
        children: _layers
            .map(
              (_BookLayer layer) => Positioned(
                top: 48 - layer.height,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(-1, 1, 1),
                      child: _BookPage(layer: layer),
                    ),
                    _BookPage(layer: layer),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _BookPage extends StatelessWidget {
  const _BookPage({required this.layer});

  final _BookLayer layer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: layer.width,
      height: layer.height,
      decoration: BoxDecoration(
        color: layer.color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(layer.radius),
          bottomRight: Radius.circular(layer.radius),
        ),
      ),
    );
  }
}

class _BookLayer {
  const _BookLayer({
    required this.width,
    required this.height,
    required this.color,
    required this.radius,
  });

  final double width;
  final double height;
  final Color color;
  final double radius;
}
