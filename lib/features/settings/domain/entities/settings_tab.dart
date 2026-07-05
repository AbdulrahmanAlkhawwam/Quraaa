import 'package:equatable/equatable.dart';

/// Represents a tab inside the unified settings screen.
class SettingsTab extends Equatable {
  const SettingsTab({
    required this.id,
    required this.labelKey,
    required this.iconKey,
  });

  final String id;
  final String labelKey;
  final String iconKey;

  @override
  List<Object?> get props => <Object?>[id, labelKey, iconKey];
}
