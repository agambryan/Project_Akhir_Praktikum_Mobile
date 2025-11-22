import 'package:hive/hive.dart';

part 'weather_model.g.dart';

@HiveType(typeId: 0)
class WeatherModel extends HiveObject {
  @HiveField(0)
  final String? area;
  
  @HiveField(1)
  final String? province;
  
  @HiveField(2)
  final List<WeatherData>? forecasts;
  
  @HiveField(3)
  final DateTime? lastUpdate;

  WeatherModel({
    this.area,
    this.province,
    this.forecasts,
    this.lastUpdate,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    List<WeatherData> forecasts = [];
    
    if (json['data'] != null && json['data'] is List) {
      forecasts = (json['data'] as List)
          .map((e) => WeatherData.fromJson(e))
          .toList();
    }

    return WeatherModel(
      area: json['lokasi']?['desa'] ?? json['lokasi']?['kota'],
      province: json['lokasi']?['provinsi'],
      forecasts: forecasts,
      lastUpdate: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'province': province,
      'forecasts': forecasts?.map((e) => e.toJson()).toList(),
      'lastUpdate': lastUpdate?.toIso8601String(),
    };
  }
}

@HiveType(typeId: 1)
class WeatherData extends HiveObject {
  @HiveField(0)
  final DateTime? datetime;
  
  @HiveField(1)
  final double? temperature;
  
  @HiveField(2)
  final int? humidity;
  
  @HiveField(3)
  final String? weather;
  
  @HiveField(4)
  final String? weatherDesc;
  
  @HiveField(5)
  final double? windSpeed;
  
  @HiveField(6)
  final String? windDirection;

  WeatherData({
    this.datetime,
    this.temperature,
    this.humidity,
    this.weather,
    this.weatherDesc,
    this.windSpeed,
    this.windDirection,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      datetime: json['jamCuaca'] != null 
          ? DateTime.tryParse(json['jamCuaca']) 
          : null,
      temperature: json['t']?.toDouble() ?? json['tempC']?.toDouble(),
      humidity: json['hu']?.toInt() ?? json['humidity']?.toInt(),
      weather: json['cuaca'] ?? json['weather'],
      weatherDesc: json['cuacaDesc'] ?? json['weatherDesc'],
      windSpeed: json['ws']?.toDouble() ?? json['windSpeed']?.toDouble(),
      windDirection: json['wd'] ?? json['windDirection'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime?.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
      'weather': weather,
      'weatherDesc': weatherDesc,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
    };
  }

  String getWeatherIcon() {
    if (weather == null) return '☁️';
    
    final w = weather!.toLowerCase();
    if (w.contains('cerah')) return '☀️';
    if (w.contains('berawan')) return '⛅';
    if (w.contains('hujan')) return '🌧️';
    if (w.contains('petir')) return '⛈️';
    if (w.contains('kabut')) return '🌫️';
    
    return '☁️';
  }
}