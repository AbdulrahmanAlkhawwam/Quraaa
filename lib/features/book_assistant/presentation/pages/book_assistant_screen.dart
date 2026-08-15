import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../settings/settings.dart';
import '../bloc/book_assistant_bloc.dart';
import '../models/book_assistant_navigation_data.dart';
import '../widgets/book_assistant_view.dart';

class BookAssistantScreen extends StatelessWidget {
  const BookAssistantScreen({super.key, this.data});

  final BookAssistantNavigationData? data;

  @override
  Widget build(BuildContext context) {
    final Widget assistant = BlocProvider<BookAssistantBloc>(
      create: (_) => sl<BookAssistantBloc>()..add(BookAssistantStarted(data)),
      child: const BookAssistantView(),
    );
    if (!sl.isRegistered<LibraryRegistrationCubit>()) return assistant;

    return BlocProvider<LibraryRegistrationCubit>(
      create: (_) => sl<LibraryRegistrationCubit>(),
      child: LibraryRegistrationListener(child: assistant),
    );
  }
}
