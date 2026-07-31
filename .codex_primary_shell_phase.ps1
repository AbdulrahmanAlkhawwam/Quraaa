$ErrorActionPreference = 'Stop'

$assistantPath = 'lib\features\book_assistant\presentation\pages\book_assistant_screen.dart'
$assistant = @'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/shared.dart';
import '../bloc/book_assistant_bloc.dart';
import '../widgets/book_assistant_view.dart';

class BookAssistantScreen extends StatelessWidget {
  const BookAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double navExtent = 94 + MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: context.appBackground,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            bottom: navExtent,
            child: BlocProvider<BookAssistantBloc>(
              create: (_) =>
                  sl<BookAssistantBloc>()..add(const BookAssistantStarted()),
              child: const BookAssistantView(),
            ),
          ),
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: HomeBottomNav(
              currentIndex: 3,
              isGuest: false,
              onTap: (int index, String route) {
                if (route != RouteNames.bookAssistant) {
                  context.goTo(route);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
'@
Set-Content -LiteralPath $assistantPath -Value $assistant -NoNewline

$settingsPath = 'lib\features\settings\presentation\pages\settings_screen.dart'
$settings = @'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/shared.dart';
import '../../../auth/auth.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/settings_view.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Future<bool> _guestSession = sl<AuthLocalDataSource>()
      .isAuthenticatedSession()
      .then((bool isAuthenticated) => !isAuthenticated);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _guestSession,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isGuest = snapshot.data!;
        final Widget settings = BlocProvider<SettingsBloc>(
          create: (_) => sl<SettingsBloc>()..add(const SettingsStarted()),
          child: SettingsView(isGuest: isGuest),
        );

        if (!isGuest) {
          return settings;
        }

        final double navExtent = 94 + MediaQuery.paddingOf(context).bottom;
        return Scaffold(
          extendBody: true,
          backgroundColor: context.appBackground,
          body: Stack(
            children: <Widget>[
              Positioned.fill(bottom: navExtent, child: settings),
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                child: HomeBottomNav(
                  currentIndex: 3,
                  isGuest: true,
                  onTap: (int index, String route) {
                    if (route != RouteNames.settings) {
                      context.goTo(route);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
'@
Set-Content -LiteralPath $settingsPath -Value $settings -NoNewline

$routerPath = 'lib\config\routes\app_router.dart'
$router = Get-Content -Raw -LiteralPath $routerPath
$router = $router.Replace("      GoRoute(`r`n        name: RouteNames.bookAssistant,`r`n        path: RouteNames.bookAssistant,`r`n        builder: (context, state) => const BookAssistantScreen(),`r`n      ),", "      GoRoute(`r`n        name: RouteNames.bookAssistant,`r`n        path: RouteNames.bookAssistant,`r`n        pageBuilder: (context, state) => _buildTabTransitionPage(`r`n          state: state,`r`n          tabIndex: 3,`r`n          child: const BookAssistantScreen(),`r`n        ),`r`n      ),")
$router = $router.Replace("      GoRoute(`r`n        name: RouteNames.settings,`r`n        path: RouteNames.settings,`r`n        builder: (context, state) => const SettingsScreen(),`r`n      ),", "      GoRoute(`r`n        name: RouteNames.settings,`r`n        path: RouteNames.settings,`r`n        pageBuilder: (context, state) => _buildTabTransitionPage(`r`n          state: state,`r`n          tabIndex: 3,`r`n          child: const SettingsScreen(),`r`n        ),`r`n      ),")
Set-Content -LiteralPath $routerPath -Value $router -NoNewline
