import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../shared/widgets/app_shell.dart';
import 'route_names.dart';

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: RouteNames.login,
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const AppShell(),
      ),
    ],
  );
}
