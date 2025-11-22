import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferences? _preferences;

  // Keys
  static const String keyLanguage = 'language';
  static const String keyNotifications = 'notifications';
  static const String keyAutoRefresh = 'auto_refresh';
  static const String keyRefreshInterval = 'refresh_interval';
  static const String keyTemperatureUnit = 'temperature_unit';
  static const String keyDefaultLocation = 'default_location';
  static const String keyLastUpdate = 'last_update';
  static const String keyThemeMode = 'theme_mode';
  static const String keyShowEarthquakeNotif = 'show_earthquake_notif';
  static const String keyMinMagnitude = 'min_magnitude';
  static const String keyUseGPS = 'use_gps';

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get instance {
    if (_preferences == null) {
      throw Exception('PreferencesService not initialized. Call init() first.');
    }
    return _preferences!;
  }

  // ============ Language Settings ============

  /// Set language (id/en)
  static Future<bool> setLanguage(String language) async {
    return await instance.setString(keyLanguage, language);
  }

  /// Get language
  static String getLanguage() {
    return instance.getString(keyLanguage) ?? 'id';
  }

  // ============ Notification Settings ============

  /// Set notifications enabled
  static Future<bool> setNotificationsEnabled(bool enabled) async {
    return await instance.setBool(keyNotifications, enabled);
  }

  /// Get notifications enabled
  static bool getNotificationsEnabled() {
    return instance.getBool(keyNotifications) ?? true;
  }

  /// Set earthquake notifications enabled
  static Future<bool> setEarthquakeNotificationsEnabled(bool enabled) async {
    return await instance.setBool(keyShowEarthquakeNotif, enabled);
  }

  /// Get earthquake notifications enabled
  static bool getEarthquakeNotificationsEnabled() {
    return instance.getBool(keyShowEarthquakeNotif) ?? true;
  }

  /// Set minimum magnitude for earthquake notifications
  static Future<bool> setMinMagnitude(double magnitude) async {
    return await instance.setDouble(keyMinMagnitude, magnitude);
  }

  /// Get minimum magnitude for earthquake notifications
  static double getMinMagnitude() {
    return instance.getDouble(keyMinMagnitude) ?? 5.0;
  }

  // ============ Refresh Settings ============

  /// Set auto refresh enabled
  static Future<bool> setAutoRefreshEnabled(bool enabled) async {
    return await instance.setBool(keyAutoRefresh, enabled);
  }

  /// Get auto refresh enabled
  static bool getAutoRefreshEnabled() {
    return instance.getBool(keyAutoRefresh) ?? true;
  }

  /// Set refresh interval in minutes
  static Future<bool> setRefreshInterval(int minutes) async {
    return await instance.setInt(keyRefreshInterval, minutes);
  }

  /// Get refresh interval in minutes
  static int getRefreshInterval() {
    return instance.getInt(keyRefreshInterval) ?? 30;
  }

  // ============ Display Settings ============

  /// Set temperature unit (C/F)
  static Future<bool> setTemperatureUnit(String unit) async {
    return await instance.setString(keyTemperatureUnit, unit);
  }

  /// Get temperature unit
  static String getTemperatureUnit() {
    return instance.getString(keyTemperatureUnit) ?? 'C';
  }

  /// Set theme mode (light/dark/system)
  static Future<bool> setThemeMode(String mode) async {
    return await instance.setString(keyThemeMode, mode);
  }

  /// Get theme mode
  static String getThemeMode() {
    return instance.getString(keyThemeMode) ?? 'system';
  }

  // ============ Location Settings ============

  /// Set default location
  static Future<bool> setDefaultLocation(String location) async {
    return await instance.setString(keyDefaultLocation, location);
  }

  /// Get default location
  static String getDefaultLocation() {
    return instance.getString(keyDefaultLocation) ?? 'Yogyakarta';
  }

  /// Set use GPS
  static Future<bool> setUseGPS(bool use) async {
    return await instance.setBool(keyUseGPS, use);
  }

  /// Get use GPS
  static bool getUseGPS() {
    return instance.getBool(keyUseGPS) ?? false;
  }

  // ============ Cache Management ============

  /// Set last update time
  static Future<bool> setLastUpdate(DateTime time) async {
    return await instance.setString(keyLastUpdate, time.toIso8601String());
  }

  /// Get last update time
  static DateTime? getLastUpdate() {
    final timeStr = instance.getString(keyLastUpdate);
    if (timeStr != null) {
      return DateTime.tryParse(timeStr);
    }
    return null;
  }

  /// Check if data is stale (older than refresh interval)
  static bool isDataStale() {
    final lastUpdate = getLastUpdate();
    if (lastUpdate == null) return true;

    final refreshInterval = getRefreshInterval();
    final staleDuration = Duration(minutes: refreshInterval);

    return DateTime.now().difference(lastUpdate) > staleDuration;
  }

  // ============ Utility Methods ============

  /// Clear all preferences
  static Future<bool> clearAll() async {
    return await instance.clear();
  }

  /// Remove specific key
  static Future<bool> remove(String key) async {
    return await instance.remove(key);
  }

  /// Check if key exists
  static bool containsKey(String key) {
    return instance.containsKey(key);
  }

  /// Get all keys
  static Set<String> getKeys() {
    return instance.getKeys();
  }

  /// Get all settings as map
  static Map<String, dynamic> getAllSettings() {
    return {
      'language': getLanguage(),
      'notifications': getNotificationsEnabled(),
      'earthquakeNotifications': getEarthquakeNotificationsEnabled(),
      'autoRefresh': getAutoRefreshEnabled(),
      'refreshInterval': getRefreshInterval(),
      'temperatureUnit': getTemperatureUnit(),
      'themeMode': getThemeMode(),
      'defaultLocation': getDefaultLocation(),
      'useGPS': getUseGPS(),
      'minMagnitude': getMinMagnitude(),
      'lastUpdate': getLastUpdate()?.toIso8601String(),
    };
  }

  /// Reset to default settings
  static Future<void> resetToDefaults() async {
    await clearAll();
    await setLanguage('id');
    await setNotificationsEnabled(true);
    await setEarthquakeNotificationsEnabled(true);
    await setAutoRefreshEnabled(true);
    await setRefreshInterval(30);
    await setTemperatureUnit('C');
    await setThemeMode('system');
    await setDefaultLocation('Yogyakarta');
    await setUseGPS(false);
    await setMinMagnitude(5.0);
  }
}
