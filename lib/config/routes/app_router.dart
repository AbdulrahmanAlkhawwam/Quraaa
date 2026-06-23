import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/local_explorer/presentation/pages/local_explorer_page.dart';
import '../../features/pdf_reader/presentation/pages/pdf_reader_page.dart';
import 'route_names.dart';

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: RouteNames.home,
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const LocalExplorerPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.explorer,
        builder: (context, state) => const LocalExplorerPage(),
      ),
      GoRoute(
        name: RouteNames.pdfReaderName,
        path: RouteNames.pdfReader,
        builder: (context, state) {
          final String? path = state.uri.queryParameters['path'];
          final String? name = state.uri.queryParameters['name'];

          return PdfReaderPage(
            path: path ?? '',
            name: name ?? 'PDF',
          );
        },
      ),
    ],
  );
}
