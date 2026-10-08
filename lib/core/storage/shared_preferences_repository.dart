import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_repository.dart';

class SharedPreferencesRepository implements PreferencesRepository {
  static const _darkModeKey = 'smartlight.dark_mode';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<bool?> readDarkMode() {
    return _preferences.getBool(_darkModeKey);
  }

  @override
  Future<void> writeDarkMode(bool enabled) {
    return _preferences.setBool(_darkModeKey, enabled);
  }
}
