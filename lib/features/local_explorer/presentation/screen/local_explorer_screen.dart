import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../logic/local_explorer_bloc.dart';
import '../widget/local_explorer_view.dart';

class LocalExplorerScreen extends StatelessWidget {
  const LocalExplorerScreen({
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
