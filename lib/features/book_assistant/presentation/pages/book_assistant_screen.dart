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
