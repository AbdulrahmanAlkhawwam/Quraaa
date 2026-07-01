import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/notification_setting.dart';
import '../repositories/settings_repository.dart';

class UpdateNotificationSettingParams {
  const UpdateNotificationSettingParams({
    required this.id,
    required this.value,
  });

  final String id;
  final bool value;
}

class UpdateNotificationSettingUseCase
    extends UseCase<Result<List<NotificationSetting>>, UpdateNotificationSettingParams> {
  const UpdateNotificationSettingUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<List<NotificationSetting>>> call(
    UpdateNotificationSettingParams params,
  ) {
    return _repository.updateNotificationSetting(params.id, params.value);
  }
}
