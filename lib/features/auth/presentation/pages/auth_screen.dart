import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/assets/app_images.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/datasources/local/auth_journey_local_data_source.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthJourneyLocalDataSource _authJourney =
      sl<AuthJourneyLocalDataSource>();

  @override
  void initState() {
    super.initState();
    unawaited(_authJourney.markAuthSeen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.onboardingBackground,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    AppColors.libraryGreen.withAlpha(100),
                    AppColors.libraryGreen.withAlpha(120),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.spacing24,
                  AppSpacing.spacing24,
                  AppSpacing.spacing24,
                  AppSpacing.spacing24 + context.bottomPadding,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.radius40),
                    topRight: Radius.circular(AppRadius.radius40),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      onPressed: () {
                        unawaited(
                          _authJourney.saveJourneyStage(
                            AuthJourneyStage.onboarding,
                            previousStage: AuthJourneyStage.auth,
                          ),
                        );
                        context.goTo(RouteNames.onboarding);
                      },
                      child: Text(LocalizationConstants.authStartKey.tr()),
                    ),
                    const SizedBox(height: AppSpacing.spacing24),
                    OutlinedButton(
                      onPressed: () {
                        unawaited(
                          _authJourney.saveJourneyStage(
                            AuthJourneyStage.login,
                            previousStage: AuthJourneyStage.auth,
                          ),
                        );
                        context.goTo(RouteNames.login);
                      },
                      child: Text(
                        LocalizationConstants.authAlreadyHaveAccountKey.tr(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
