import 'package:hive_flutter/hive_flutter.dart';
import '../models/weather_model.dart';
import '../models/earthquake_model.dart';
import '../models/weather_warning_model.dart';

class LocalStorageService {
  // Box names
  static const String weatherBox = 'weather_box';
  static const String earthquakeBox = 'earthquake_box';
  static const String warningBox = 'warning_box';
  static const String favoritesBox = 'favorites_box';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters (akan di-generate oleh build_runner)
    // Hive.registerAdapter(WeatherModelAdapter());
    // Hive.registerAdapter(WeatherDataAdapter());
    // Hive.registerAdapter(EarthquakeModelAdapter());
    // Hive.registerAdapter(WeatherWarningModelAdapter());

    // Open boxes
    await Hive.openBox<WeatherModel>(weatherBox);
    await Hive.openBox<EarthquakeModel>(earthquakeBox);
    await Hive.openBox<WeatherWarningModel>(warningBox);
    await Hive.openBox<String>(favoritesBox);
  }

  // ============ Weather Operations ============

  /// Save weather data
  Future<void> saveWeather(String key, WeatherModel weather) async {
    final box = Hive.box<WeatherModel>(weatherBox);
    await box.put(key, weather);
  }

  /// Get weather data
  WeatherModel? getWeather(String key) {
    final box = Hive.box<WeatherModel>(weatherBox);
    return box.get(key);
  }

  /// Get all weather data
  List<WeatherModel> getAllWeather() {
    final box = Hive.box<WeatherModel>(weatherBox);
    return box.values.toList();
  }

  /// Delete weather data
  Future<void> deleteWeather(String key) async {
    final box = Hive.box<WeatherModel>(weatherBox);
    await box.delete(key);
  }

  /// Clear all weather data
  Future<void> clearWeather() async {
    final box = Hive.box<WeatherModel>(weatherBox);
    await box.clear();
  }

  // ============ Earthquake Operations ============

  /// Save earthquake
  Future<void> saveEarthquake(EarthquakeModel earthquake) async {
    final box = Hive.box<EarthquakeModel>(earthquakeBox);
    final key = '${earthquake.date}_${earthquake.time}';
    await box.put(key, earthquake);
  }

  /// Save multiple earthquakes
  Future<void> saveEarthquakes(List<EarthquakeModel> earthquakes) async {
    final box = Hive.box<EarthquakeModel>(earthquakeBox);
    final Map<String, EarthquakeModel> dataMap = {};

    for (var eq in earthquakes) {
      final key = '${eq.date}_${eq.time}';
      dataMap[key] = eq;
    }

    await box.putAll(dataMap);
  }

  /// Get all earthquakes
  List<EarthquakeModel> getAllEarthquakes() {
    final box = Hive.box<EarthquakeModel>(earthquakeBox);
    return box.values.toList();
  }

  /// Get earthquakes sorted by date
  List<EarthquakeModel> getEarthquakesSorted() {
    final earthquakes = getAllEarthquakes();
    earthquakes.sort((a, b) {
      if (a.datetime == null || b.datetime == null) return 0;
      return b.datetime!.compareTo(a.datetime!);
    });
    return earthquakes;
  }

  /// Delete earthquake
  Future<void> deleteEarthquake(String key) async {
    final box = Hive.box<EarthquakeModel>(earthquakeBox);
    await box.delete(key);
  }

  /// Clear all earthquakes
  Future<void> clearEarthquakes() async {
    final box = Hive.box<EarthquakeModel>(earthquakeBox);
    await box.clear();
  }

  // ============ Warning Operations ============

  /// Save warning
  Future<void> saveWarning(WeatherWarningModel warning) async {
    final box = Hive.box<WeatherWarningModel>(warningBox);
    await box.put(warning.id, warning);
  }

  /// Save multiple warnings
  Future<void> saveWarnings(List<WeatherWarningModel> warnings) async {
    final box = Hive.box<WeatherWarningModel>(warningBox);
    final Map<String, WeatherWarningModel> dataMap = {};

    for (var warning in warnings) {
      if (warning.id != null) {
        dataMap[warning.id!] = warning;
      }
    }

    await box.putAll(dataMap);
  }

  /// Get all warnings
  List<WeatherWarningModel> getAllWarnings() {
    final box = Hive.box<WeatherWarningModel>(warningBox);
    return box.values.toList();
  }

  /// Get active warnings only
  List<WeatherWarningModel> getActiveWarnings() {
    final warnings = getAllWarnings();
    return warnings.where((w) => w.isActive).toList();
  }

  /// Delete warning
  Future<void> deleteWarning(String id) async {
    final box = Hive.box<WeatherWarningModel>(warningBox);
    await box.delete(id);
  }

  /// Clear all warnings
  Future<void> clearWarnings() async {
    final box = Hive.box<WeatherWarningModel>(warningBox);
    await box.clear();
  }

  // ============ Favorites Operations ============

  /// Add favorite location
  Future<void> addFavorite(String location) async {
    final box = Hive.box<String>(favoritesBox);
    if (!box.values.contains(location)) {
      await box.add(location);
    }
  }

  /// Remove favorite location
  Future<void> removeFavorite(String location) async {
    final box = Hive.box<String>(favoritesBox);
    final key = box.keys.firstWhere(
      (k) => box.get(k) == location,
      orElse: () => null,
    );
    if (key != null) {
      await box.delete(key);
    }
  }

  /// Get all favorites
  List<String> getFavorites() {
    final box = Hive.box<String>(favoritesBox);
    return box.values.toList();
  }

  /// Check if location is favorite
  bool isFavorite(String location) {
    final box = Hive.box<String>(favoritesBox);
    return box.values.contains(location);
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    final box = Hive.box<String>(favoritesBox);
    await box.clear();
  }

  // ============ Utility Operations ============

  /// Clear all data
  Future<void> clearAll() async {
    await clearWeather();
    await clearEarthquakes();
    await clearWarnings();
    await clearFavorites();
  }

  /// Get total data count
  Map<String, int> getDataCount() {
    return {
      'weather': Hive.box<WeatherModel>(weatherBox).length,
      'earthquake': Hive.box<EarthquakeModel>(earthquakeBox).length,
      'warning': Hive.box<WeatherWarningModel>(warningBox).length,
      'favorites': Hive.box<String>(favoritesBox).length,
    };
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }
}
