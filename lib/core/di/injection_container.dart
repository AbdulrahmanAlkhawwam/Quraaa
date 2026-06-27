import 'package:get_it/get_it.dart';

import '../services/services.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  registerCoreDependencies();
  registerFeatureDependencies();
  await initializeNotificationDependencies();
}

void registerCoreDependencies() {
  sl
    ..registerLazySingleton<NotificationService>(NotificationService.new)
    ..registerLazySingleton<FirebaseMessagingService>(
      () => FirebaseMessagingService(
        notificationService: sl<NotificationService>(),
      ),
    );
}

void registerFeatureDependencies() {}

void registerTestDependencies() {
  // Register test doubles here when needed.
}

/// Initializes notifications and FCM after Firebase has been set up.
Future<void> initializeNotificationDependencies() async {
  final notificationService = sl<NotificationService>();
  final messagingService = sl<FirebaseMessagingService>();

  await notificationService.initialize(requestPermission: true);
  await messagingService.requestPermissions();
  await messagingService.subscribeToDefaultTopic();
  messagingService.listenToForegroundMessages();
  await messagingService.logDeviceToken();
}
