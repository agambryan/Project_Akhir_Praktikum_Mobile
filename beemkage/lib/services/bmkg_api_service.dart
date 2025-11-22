import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/earthquake_model.dart';
import '../models/weather_warning_model.dart';

class BmkgApiService {
  // Base URLs - sesuaikan dengan API BMKG yang tersedia
  static const String baseUrl = 'https://data.bmkg.go.id';
  static const String weatherApiUrl = 'https://api.bmkg.go.id/publik';
  static const String warningApiUrl = 'https://www.bmkg.go.id/alerts/nowcast';
  static const String earthquakeUrl = '$baseUrl/DataMKG/TEWS';

  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 30);

  /// Fetch weather forecast for specific area using BMKG API
  Future<WeatherModel?> getWeatherForecast(String areaCode) async {
    try {
      const url = '$weatherApiUrl/prakiraan-cuaca';
      final uri = Uri.parse(url).replace(queryParameters: {'adm4': areaCode});

      final response = await http.get(uri).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching weather: $e', name: 'BmkgApiService');
      return _createDummyWeatherData();
    }
  }

  /// Fetch latest earthquakes
  Future<List<EarthquakeModel>> getLatestEarthquakes() async {
    try {
      const url = '$earthquakeUrl/autogempa.json';

      final response = await http.get(Uri.parse(url)).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['Infogempa'] != null && data['Infogempa']['gempa'] != null) {
          final gempaData = data['Infogempa']['gempa'];

          final List<dynamic> gempaList =
              gempaData is List ? gempaData : [gempaData];

          return gempaList.map((e) => EarthquakeModel.fromJson(e)).toList();
        }

        return [];
      } else {
        throw Exception(
            'Failed to load earthquake data: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching earthquakes: $e', name: 'BmkgApiService');
      return _createDummyEarthquakeData();
    }
  }

  /// Fetch recent earthquakes (M≥5.0)
  Future<List<EarthquakeModel>> getRecentEarthquakes() async {
    try {
      const url = '$earthquakeUrl/gempaterkini.json';

      final response = await http.get(Uri.parse(url)).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['Infogempa'] != null && data['Infogempa']['gempa'] != null) {
          final gempaList = data['Infogempa']['gempa'] as List;

          return gempaList.map((e) => EarthquakeModel.fromJson(e)).toList();
        }

        return [];
      } else {
        throw Exception(
            'Failed to load earthquake data: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching recent earthquakes: $e',
          name: 'BmkgApiService');
      return [];
    }
  }

  /// Fetch felt earthquakes
  Future<List<EarthquakeModel>> getFeltEarthquakes() async {
    try {
      const url = '$earthquakeUrl/gempadirasakan.json';

      final response = await http.get(Uri.parse(url)).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['Infogempa'] != null && data['Infogempa']['gempa'] != null) {
          final gempaList = data['Infogempa']['gempa'] as List;

          return gempaList.map((e) => EarthquakeModel.fromJson(e)).toList();
        }

        return [];
      } else {
        throw Exception(
            'Failed to load felt earthquake data: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching felt earthquakes: $e',
          name: 'BmkgApiService');
      return [];
    }
  }

  /// Fetch weather warnings from BMKG nowcast API
  Future<List<WeatherWarningModel>> getWeatherWarnings() async {
    try {
      const url = '$warningApiUrl/id';

      final response = await http.get(Uri.parse(url)).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['warnings'] != null) {
          final warningList = data['warnings'] as List;

          return warningList
              .map((e) => WeatherWarningModel.fromJson(e))
              .toList();
        }

        return [];
      } else {
        throw Exception('Failed to load warnings: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching warnings: $e', name: 'BmkgApiService');
      return _createDummyWarningData();
    }
  }

  /// Create dummy weather data for testing
  WeatherModel _createDummyWeatherData() {
    return WeatherModel(
      area: 'Yogyakarta',
      province: 'DI Yogyakarta',
      lastUpdate: DateTime.now(),
      forecasts: List.generate(24, (index) {
        final time = DateTime.now().add(Duration(hours: index));
        return WeatherData(
          datetime: time,
          temperature: 24 + (index % 6),
          humidity: 70 + (index % 15),
          weather: index % 3 == 0 ? 'Cerah Berawan' : 'Berawan',
          weatherDesc: 'Cuaca cerah berawan',
          windSpeed: 10 + (index % 5).toDouble(),
          windDirection: 'Tenggara',
        );
      }),
    );
  }

  /// Create dummy earthquake data for testing
  List<EarthquakeModel> _createDummyEarthquakeData() {
    return [
      EarthquakeModel(
        date: '21 November 2025',
        time: '12:15:59 WIB',
        datetime: DateTime.now(),
        magnitude: 4.4,
        depth: 25,
        region: 'Pusat gempa berada di laut 37 km barat daya Pesisir Selatan',
        latitude: -2.09,
        longitude: 100.60,
        potential: 'Tidak berpotensi tsunami',
        felt: 'III-IV Pesisir Selatan, II-III Tua Pejat, II-III Solok Selatan',
      ),
    ];
  }

  /// Create dummy warning data for testing
  List<WeatherWarningModel> _createDummyWarningData() {
    return [
      WeatherWarningModel(
        id: '1',
        title: 'Peringatan Cuaca Ekstrem',
        description: 'Potensi hujan lebat disertai petir dan angin kencang',
        level: 'Kuning',
        area: 'Yogyakarta',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 6)),
        phenomenon: 'Hujan Lebat',
        instructions: 'Waspadai genangan air dan pohon tumbang',
      ),
    ];
  }
}
