import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/notification_setting.dart';
import '../repositories/settings_repository.dart';

class GetNotificationSettingsUseCase
    extends UseCase<Result<List<NotificationSetting>>, NoParams> {
  const GetNotificationSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<List<NotificationSetting>>> call(NoParams params) {
    return _repository.getNotificationSettings();
  }
}
