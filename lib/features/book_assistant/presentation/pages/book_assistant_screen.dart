import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/book_assistant_bloc.dart';
import '../widgets/book_assistant_view.dart';

class BookAssistantScreen extends StatelessWidget {
  const BookAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookAssistantBloc>(
      create: (_) => sl<BookAssistantBloc>()..add(const BookAssistantStarted()),
      child: const BookAssistantView(),
    );
  }
}
