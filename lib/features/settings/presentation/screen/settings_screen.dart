import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared.dart';
import '../../../auth/auth.dart';
import '../../../home/presentation/widget/home_app_bar.dart';
import '../logic/settings_bloc.dart';
import '../logic/library_registration_cubit.dart';
import '../widget/library_registration_listener.dart';
import '../widget/settings_view.dart';

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
        final Widget guestSettings = Scaffold(
          extendBody: true,
          backgroundColor: context.appBackground,
          appBar: const HomeAppBar(isGuest: true),
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
                    if (route != AppRoutes.settings) {
                      context.goTo(route);
                    }
                  },
                ),
              ),
            ],
          ),
        );
        if (!sl.isRegistered<LibraryRegistrationCubit>()) {
          return guestSettings;
        }
        return BlocProvider<LibraryRegistrationCubit>(
          create: (_) => sl<LibraryRegistrationCubit>(),
          child: LibraryRegistrationListener(child: guestSettings),
        );
      },
    );
  }
}
