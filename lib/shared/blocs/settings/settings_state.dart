import 'package:equatable/equatable.dart';

/// Immutable state for the settings preference toggles.
///
/// Holds the persisted UI preferences shown on the settings screen:
/// dark mode and Telegram notifications.
class SettingsState extends Equatable {
  /// Whether dark mode is enabled.
  final bool darkMode;

  /// Whether Telegram notifications are enabled.
  final bool notificationsEnabled;

  /// Creates a [SettingsState].
  const SettingsState({
    this.darkMode = false,
    this.notificationsEnabled = true,
  });

  /// Returns a copy of this state with optional field overrides.
  SettingsState copyWith({bool? darkMode, bool? notificationsEnabled}) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [darkMode, notificationsEnabled];
}
