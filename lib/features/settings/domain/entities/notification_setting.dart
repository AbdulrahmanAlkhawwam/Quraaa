import 'package:equatable/equatable.dart';

/// Represents a single notification toggle in the settings screen.
class NotificationSetting extends Equatable {
  const NotificationSetting({
    required this.id,
    required this.labelKey,
    required this.value,
  });

  final String id;
  final String labelKey;
  final bool value;

  NotificationSetting copyWith({bool? value}) {
    return NotificationSetting(
      id: id,
      labelKey: labelKey,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, labelKey, value];
}
