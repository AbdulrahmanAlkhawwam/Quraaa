import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  registerCoreDependencies();
  registerFeatureDependencies();
}

void registerCoreDependencies() {}

void registerFeatureDependencies() {}

void registerTestDependencies() {}
