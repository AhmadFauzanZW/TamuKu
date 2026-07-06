import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import 'settings_state.dart';

/// Cubit managing the settings screen preference toggles.
///
/// Replaces `setState` on the settings screen (BLoC-only rule). The
/// dark mode flag is persisted to [SharedPreferences] under
/// [AppConstants.keyDarkMode]; the notification toggle is held in
/// memory for the MVP.
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  /// Creates a [SettingsCubit] and hydrates state from [prefs].
  SettingsCubit({required SharedPreferences prefs})
    : _prefs = prefs,
      super(
        SettingsState(
          darkMode: prefs.getBool(AppConstants.keyDarkMode) ?? false,
        ),
      );

  /// Toggles dark mode and persists the new value.
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(AppConstants.keyDarkMode, value);
    emit(state.copyWith(darkMode: value));
  }

  /// Toggles the Telegram notification preference (in-memory for MVP).
  void setNotifications(bool value) {
    emit(state.copyWith(notificationsEnabled: value));
  }
}
