import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../bloc/auth_bloc.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(AuthStarted()),
      child: const _LandingPageView(),
    );
  }
}

class _LandingPageView extends StatelessWidget {
  const _LandingPageView();

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
            children: [
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
        context.goTo(RouteNames.onboarding);
      case AuthStatus.navigateToLogin:
        context.goTo(RouteNames.login);
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
