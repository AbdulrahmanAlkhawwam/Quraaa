import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/widgets/custom_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Hero Image (70% height)
          Expanded(
            flex: 7,
            child: Image.asset(
              'assets/images/onboarding.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
    x        ),
          ),
          // Bottom Sheet (30% height)
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
              decoration: const BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.radius40),
                  topRight: Radius.circular(AppRadius.radius40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomButton.primary(
                    text: "Let's Start",
                    onPressed: () {},
                  ),
                  SizedBox(height: AppSpacing.spacing24),
                  CustomButton.secondary(
                    text: "I Have Already Account",
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
