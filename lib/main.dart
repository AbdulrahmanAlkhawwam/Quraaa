import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/injection_container.dart';
import 'core/localization/localization_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.ensureInitialized();
  await configureDependencies();
  runApp(LocalizationService.wrap(child: const QuraaaApp()));
}
