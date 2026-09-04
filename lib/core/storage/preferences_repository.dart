abstract interface class PreferencesRepository {
  Future<bool?> readDarkMode();

  Future<void> writeDarkMode(bool enabled);
}
