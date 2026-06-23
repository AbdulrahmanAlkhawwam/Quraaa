import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/local_explorer_bloc.dart';
import '../widgets/local_explorer_view.dart';

class LocalExplorerPage extends StatelessWidget {
  const LocalExplorerPage({
    this.bloc,
    super.key,
  });

  final LocalExplorerBloc? bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocalExplorerBloc>(
      create: (BuildContext context) {
        return (bloc ?? sl<LocalExplorerBloc>())
          ..add(const LocalExplorerStarted());
      },
      child: const LocalExplorerView(),
    );
  }
}
