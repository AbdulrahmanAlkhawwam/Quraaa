import 'package:equatable/equatable.dart';

/// Describes how a settings section behaves when tapped.
enum SettingsSectionAction {
  /// Opens a detail page (placeholder).
  navigate,

  /// Opens a bottom sheet.
  bottomSheet,

  /// Triggers a one-off action (placeholder).
  action,
}

/// Represents a single row inside a tab's settings list.
class SettingsSection extends Equatable {
  const SettingsSection({
    required this.id,
    required this.labelKey,
    required this.action,
    this.target,
  });

  final String id;
  final String labelKey;
  final SettingsSectionAction action;

  /// Optional identifier used to decide which bottom sheet / route to open.
  final String? target;

  @override
  List<Object?> get props => <Object?>[id, labelKey, action, target];
}
