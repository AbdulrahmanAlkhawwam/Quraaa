import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../widgets/auth_scaffold.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthLocalDataSource _authJourney = sl<AuthLocalDataSource>();

  @override
  void initState() {
    super.initState();
    unawaited(_authJourney.markAuthSeen());
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spacing24,
        AppSpacing.spacing24,
        AppSpacing.spacing24,
        AppSpacing.spacing24,
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
    );
  }
}
