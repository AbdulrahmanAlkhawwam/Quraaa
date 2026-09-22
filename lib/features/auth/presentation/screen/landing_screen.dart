import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../core/shared.dart';
import '../logic/auth_bloc.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>()..add(AuthStarted()),
      child: const _LandingScreenView(),
    );
  }
}

class _LandingScreenView extends StatelessWidget {
  const _LandingScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _handleAuthState,
      builder: (BuildContext context, AuthState state) {
        return AppLayout(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FilledButton(
                onPressed: state.status == AuthStatus.navigationLoading &&
                        state.destination ==
                            AuthNavigationDestination.onboarding
                    ? null
                    : () => _goToOnboarding(context),
                child: state.status == AuthStatus.navigationLoading &&
                        state.destination ==
                            AuthNavigationDestination.onboarding
                    ? const CircularProgressIndicator(strokeWidth: 2.5)
                    : Text(LocalizationConstants.authStartKey.tr()),
              ),
              const SizedBox(height: AppSpacing.spacing24),
              OutlinedButton(
                onPressed: state.status == AuthStatus.navigationLoading &&
                        state.destination == AuthNavigationDestination.login
                    ? null
                    : () => _goToLogin(context),
                child: state.status == AuthStatus.navigationLoading &&
                        state.destination == AuthNavigationDestination.login
                    ? const CircularProgressIndicator(strokeWidth: 2.5)
                    : Text(
                        LocalizationConstants.authAlreadyHaveAccountKey.tr(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    switch (state.status) {
      case AuthStatus.navigateToOnboarding:
        context.goTo(AppRoutes.onboarding);
      case AuthStatus.navigateToLogin:
        context.goTo(AppRoutes.login);
      case _:
        break;
    }
  }

  void _goToOnboarding(BuildContext context) {
    context.read<AuthBloc>().add(AuthOnboardingRequested());
  }

  void _goToLogin(BuildContext context) {
    context.read<AuthBloc>().add(AuthLoginRequestedFromAuth());
  }
}
