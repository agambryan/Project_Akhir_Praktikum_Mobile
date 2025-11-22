import 'package:flutter/foundation.dart';
import '../models/earthquake_model.dart';
import '../services/bmkg_api_service.dart';
import '../services/local_storage_service.dart';

class EarthquakeProvider extends ChangeNotifier {
  final BmkgApiService _apiService = BmkgApiService();
  final LocalStorageService _storageService = LocalStorageService();

  // State
  List<EarthquakeModel> _latestEarthquakes = [];
  List<EarthquakeModel> _recentEarthquakes = [];
  List<EarthquakeModel> _feltEarthquakes = [];
  bool _isLoading = false;
  String? _error;
  String _selectedTab = 'latest'; // latest, recent, felt

  // Getters
  List<EarthquakeModel> get latestEarthquakes => _latestEarthquakes;
  List<EarthquakeModel> get recentEarthquakes => _recentEarthquakes;
  List<EarthquakeModel> get feltEarthquakes => _feltEarthquakes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedTab => _selectedTab;

  List<EarthquakeModel> get currentList {
    switch (_selectedTab) {
      case 'recent':
        return _recentEarthquakes;
      case 'felt':
        return _feltEarthquakes;
      default:
        return _latestEarthquakes;
    }
  }

  EarthquakeProvider() {
    _init();
  }

  /// Initialize provider
  Future<void> _init() async {
    await loadEarthquakes();
  }

  /// Load all earthquake data
  Future<void> loadEarthquakes({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!forceRefresh) {
        // Try to load from cache first
        final cachedEarthquakes = _storageService.getEarthquakesSorted();
        if (cachedEarthquakes.isNotEmpty) {
          _latestEarthquakes = cachedEarthquakes;
          _isLoading = false;
          notifyListeners();

          // Load in background
          _loadFromApi();
          return;
        }
      }

      await _loadFromApi();
    } catch (e) {
      _error = e.toString();

      // Try to load from cache on error
      final cachedEarthquakes = _storageService.getEarthquakesSorted();
      if (cachedEarthquakes.isNotEmpty) {
        _latestEarthquakes = cachedEarthquakes;
        _error = 'Using cached data. ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load data from API
  Future<void> _loadFromApi() async {
    // Load latest earthquake
    final latest = await _apiService.getLatestEarthquakes();
    if (latest.isNotEmpty) {
      _latestEarthquakes = latest;
      await _storageService.saveEarthquakes(latest);
    }

    // Load recent earthquakes (M≥5.0)
    final recent = await _apiService.getRecentEarthquakes();
    if (recent.isNotEmpty) {
      _recentEarthquakes = recent;
    }

    // Load felt earthquakes
    final felt = await _apiService.getFeltEarthquakes();
    if (felt.isNotEmpty) {
      _feltEarthquakes = felt;
    }

    notifyListeners();
  }

  /// Change selected tab
  void changeTab(String tab) {
    if (_selectedTab == tab) return;
    _selectedTab = tab;
    notifyListeners();
  }

  /// Refresh earthquake data
  Future<void> refresh() async {
    await loadEarthquakes(forceRefresh: true);
  }

  /// Filter earthquakes by minimum magnitude
  List<EarthquakeModel> filterByMagnitude(double minMagnitude) {
    return currentList.where((eq) {
      return eq.magnitude != null && eq.magnitude! >= minMagnitude;
    }).toList();
  }

  /// Filter earthquakes by region
  List<EarthquakeModel> filterByRegion(String region) {
    return currentList.where((eq) {
      if (eq.region == null) return false;
      return eq.region!.toLowerCase().contains(region.toLowerCase());
    }).toList();
  }

  /// Filter earthquakes by date range
  List<EarthquakeModel> filterByDateRange(DateTime start, DateTime end) {
    return currentList.where((eq) {
      if (eq.datetime == null) return false;
      return eq.datetime!.isAfter(start) && eq.datetime!.isBefore(end);
    }).toList();
  }

  /// Get earthquake statistics
  Map<String, dynamic> getStatistics() {
    if (currentList.isEmpty) {
      return {
        'total': 0,
        'averageMagnitude': 0.0,
        'maxMagnitude': 0.0,
        'minMagnitude': 0.0,
        'averageDepth': 0.0,
      };
    }

    final magnitudes = currentList
        .where((eq) => eq.magnitude != null)
        .map((eq) => eq.magnitude!)
        .toList();

    final depths = currentList
        .where((eq) => eq.depth != null)
        .map((eq) => eq.depth!.toDouble())
        .toList();

    return {
      'total': currentList.length,
      'averageMagnitude': magnitudes.isNotEmpty
          ? magnitudes.reduce((a, b) => a + b) / magnitudes.length
          : 0.0,
      'maxMagnitude': magnitudes.isNotEmpty
          ? magnitudes.reduce((a, b) => a > b ? a : b)
          : 0.0,
      'minMagnitude': magnitudes.isNotEmpty
          ? magnitudes.reduce((a, b) => a < b ? a : b)
          : 0.0,
      'averageDepth': depths.isNotEmpty
          ? depths.reduce((a, b) => a + b) / depths.length
          : 0.0,
    };
  }

  /// Get earthquakes by magnitude category
  Map<String, int> getEarthquakesByCategory() {
    final Map<String, int> categories = {
      'Mikro': 0,
      'Minor': 0,
      'Ringan': 0,
      'Sedang': 0,
      'Kuat': 0,
      'Mayor': 0,
      'Sangat Besar': 0,
    };

    for (var eq in currentList) {
      final category = eq.getMagnitudeCategory();
      categories[category] = (categories[category] ?? 0) + 1;
    }

    return categories;
  }

  /// Check if earthquake should trigger notification
  bool shouldNotify(EarthquakeModel earthquake) {
    // Implementasi logic notifikasi berdasarkan preferences
    // Contoh: hanya notif jika magnitude >= setting minimum
    return earthquake.magnitude != null && earthquake.magnitude! >= 5.0;
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _storageService.clearEarthquakes();
    _latestEarthquakes = [];
    _recentEarthquakes = [];
    _feltEarthquakes = [];
    notifyListeners();
  }
}
