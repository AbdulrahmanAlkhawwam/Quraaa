import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/extensions/app_context.dart';
import '../../domain/entities/library_registration.dart';
import '../cubit/library_registration_cubit.dart';

class LibraryRegistrationListener extends StatelessWidget {
  const LibraryRegistrationListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LibraryRegistrationCubit, LibraryRegistrationState>(
      listener: _handleRegistrationState,
      child: child,
    );
  }

  void _handleRegistrationState(
    BuildContext context,
    LibraryRegistrationState state,
  ) {
    final LibraryRegistrationCubit cubit =
        context.read<LibraryRegistrationCubit>();
    switch (state) {
      case LibraryRegistrationReady(registration: final registration):
        unawaited(
          _openRegistrationUrl(context, registration).whenComplete(() {
            if (!cubit.isClosed) cubit.reset();
          }),
        );
      case LibraryRegistrationFailure(error: final error):
        context.showResolvedErrorSnackBar(error);
        cubit.reset();
      case LibraryRegistrationInitial() || LibraryRegistrationLoading():
        break;
    }
  }

  Future<void> _openRegistrationUrl(
    BuildContext context,
    LibraryRegistration registration,
  ) async {
    final Uri? uri = Uri.tryParse(registration.registrationUrl);
    final bool isWebUrl =
        uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
    bool opened = false;
    if (isWebUrl) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
    if (!opened && context.mounted) {
      context.showResolvedErrorSnackBar(
        LocalizationConstants.settingsAccountTypeLibraryOpenFailedKey.tr(),
      );
    }
  }
}
