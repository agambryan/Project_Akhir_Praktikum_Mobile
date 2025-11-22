import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../services/bmkg_api_service.dart';
import '../services/local_storage_service.dart';
import '../services/preferences_service.dart';

class WeatherProvider extends ChangeNotifier {
  final BmkgApiService _apiService = BmkgApiService();
  final LocalStorageService _storageService = LocalStorageService();

  // State
  WeatherModel? _currentWeather;
  bool _isLoading = false;
  String? _error;
  String _selectedLocation = 'Yogyakarta';

  // Getters
  WeatherModel? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedLocation => _selectedLocation;

  WeatherProvider() {
    _init();
  }

  /// Initialize provider
  Future<void> _init() async {
    _selectedLocation = PreferencesService.getDefaultLocation();
    await loadWeather();
  }

  /// Load weather data
  Future<void> loadWeather({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if we need to refresh
      if (!forceRefresh && !PreferencesService.isDataStale()) {
        // Load from local storage
        final cachedWeather = _storageService.getWeather(_selectedLocation);
        if (cachedWeather != null) {
          _currentWeather = cachedWeather;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Fetch from API
      final weather = await _apiService.getWeatherForecast(
        _getProvinceId(_selectedLocation),
      );

      if (weather != null) {
        _currentWeather = weather;

        // Save to local storage
        await _storageService.saveWeather(_selectedLocation, weather);

        // Update last update time
        await PreferencesService.setLastUpdate(DateTime.now());
      } else {
        _error = 'Failed to load weather data';
      }
    } catch (e) {
      _error = e.toString();

      // Try to load from cache on error
      final cachedWeather = _storageService.getWeather(_selectedLocation);
      if (cachedWeather != null) {
        _currentWeather = cachedWeather;
        _error = 'Using cached data. ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change selected location
  Future<void> changeLocation(String location) async {
    if (_selectedLocation == location) return;

    _selectedLocation = location;
    await PreferencesService.setDefaultLocation(location);
    await loadWeather(forceRefresh: true);
  }

  /// Refresh weather data
  Future<void> refresh() async {
    await loadWeather(forceRefresh: true);
  }

  /// Get temperature in preferred unit
  double? getTemperature(double? celsius) {
    if (celsius == null) return null;

    final unit = PreferencesService.getTemperatureUnit();
    if (unit == 'F') {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  /// Get temperature unit symbol
  String getTemperatureUnit() {
    return PreferencesService.getTemperatureUnit();
  }

  /// Get hourly forecast for today
  List<WeatherData> getTodayForecast() {
    if (_currentWeather?.forecasts == null) return [];

    final now = DateTime.now();
    return _currentWeather!.forecasts!.where((forecast) {
      if (forecast.datetime == null) return false;
      return forecast.datetime!.year == now.year &&
          forecast.datetime!.month == now.month &&
          forecast.datetime!.day == now.day;
    }).toList();
  }

  /// Get forecast for next 7 days
  List<WeatherData> getWeeklyForecast() {
    if (_currentWeather?.forecasts == null) return [];

    final Map<String, WeatherData> dailyMap = {};

    for (var forecast in _currentWeather!.forecasts!) {
      if (forecast.datetime == null) continue;

      final dateKey =
          '${forecast.datetime!.year}-${forecast.datetime!.month}-${forecast.datetime!.day}';

      // Keep only the forecast at noon (12:00) for each day
      if (forecast.datetime!.hour == 12) {
        dailyMap[dateKey] = forecast;
      }
    }

    return dailyMap.values.take(7).toList();
  }

  /// Get current temperature
  double? getCurrentTemperature() {
    final todayForecasts = getTodayForecast();
    if (todayForecasts.isEmpty) return null;

    return getTemperature(todayForecasts.first.temperature);
  }

  /// Get current weather condition
  String? getCurrentWeatherCondition() {
    final todayForecasts = getTodayForecast();
    if (todayForecasts.isEmpty) return null;

    return todayForecasts.first.weather;
  }

  /// Map location to province ID
  String _getProvinceId(String location) {
    // Mapping lokasi ke ID provinsi untuk API BMKG
    final Map<String, String> provinceMap = {
      'Jakarta': 'DKIJakarta',
      'Yogyakarta': 'DIYogyakarta',
      'Bandung': 'JawaBarat',
      'Surabaya': 'JawaTimur',
      'Semarang': 'JawaTengah',
      'Medan': 'SumateraUtara',
      'Palembang': 'SumateraSelatan',
      'Makassar': 'SulawesiSelatan',
      'Denpasar': 'Bali',
      'Malang': 'JawaTimur',
    };

    return provinceMap[location] ?? 'DIYogyakarta';
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _storageService.clearWeather();
    _currentWeather = null;
    notifyListeners();
  }
}
