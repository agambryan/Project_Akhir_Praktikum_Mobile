import 'package:hive/hive.dart';

part 'earthquake_model.g.dart';

@HiveType(typeId: 2)
class EarthquakeModel extends HiveObject {
  @HiveField(0)
  final String? date;
  
  @HiveField(1)
  final String? time;
  
  @HiveField(2)
  final DateTime? datetime;
  
  @HiveField(3)
  final double? magnitude;
  
  @HiveField(4)
  final int? depth;
  
  @HiveField(5)
  final String? region;
  
  @HiveField(6)
  final double? latitude;
  
  @HiveField(7)
  final double? longitude;
  
  @HiveField(8)
  final String? potential;
  
  @HiveField(9)
  final String? felt;
  
  @HiveField(10)
  final String? shakemapUrl;

  EarthquakeModel({
    this.date,
    this.time,
    this.datetime,
    this.magnitude,
    this.depth,
    this.region,
    this.latitude,
    this.longitude,
    this.potential,
    this.felt,
    this.shakemapUrl,
  });

  factory EarthquakeModel.fromJson(Map<String, dynamic> json) {
    // Parse coordinates from string like "2.09 LS,100.60 BT"
    double? lat;
    double? lon;
    
    if (json['coordinates'] != null) {
      final coords = json['coordinates'].toString().split(',');
      if (coords.length == 2) {
        // Parse latitude (LS = South, LU = North)
        final latStr = coords[0].trim();
        final latValue = double.tryParse(latStr.replaceAll(RegExp(r'[^0-9.]'), ''));
        lat = latStr.contains('LS') ? -(latValue ?? 0) : latValue;
        
        // Parse longitude (BT = East, BB = West)
        final lonStr = coords[1].trim();
        final lonValue = double.tryParse(lonStr.replaceAll(RegExp(r'[^0-9.]'), ''));
        lon = lonStr.contains('BB') ? -(lonValue ?? 0) : lonValue;
      }
    }

    // Parse datetime
    DateTime? dt;
    if (json['tanggal'] != null && json['jam'] != null) {
      try {
        final dateStr = json['tanggal'].toString();
        final timeStr = json['jam'].toString();
        dt = DateTime.parse('$dateStr $timeStr');
      } catch (e) {
        dt = DateTime.now();
      }
    }

    return EarthquakeModel(
      date: json['tanggal'],
      time: json['jam'],
      datetime: dt,
      magnitude: json['magnitude']?.toDouble(),
      depth: json['kedalaman']?.toInt() ?? 
             int.tryParse(json['kedalaman']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '0'),
      region: json['wilayah'] ?? json['area'],
      latitude: lat,
      longitude: lon,
      potential: json['potensi'],
      felt: json['dirasakan'],
      shakemapUrl: json['shakemap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'datetime': datetime?.toIso8601String(),
      'magnitude': magnitude,
      'depth': depth,
      'region': region,
      'latitude': latitude,
      'longitude': longitude,
      'potential': potential,
      'felt': felt,
      'shakemapUrl': shakemapUrl,
    };
  }

  String getMagnitudeCategory() {
    if (magnitude == null) return 'Tidak Diketahui';
    
    if (magnitude! < 3.0) return 'Mikro';
    if (magnitude! < 4.0) return 'Minor';
    if (magnitude! < 5.0) return 'Ringan';
    if (magnitude! < 6.0) return 'Sedang';
    if (magnitude! < 7.0) return 'Kuat';
    if (magnitude! < 8.0) return 'Mayor';
    return 'Sangat Besar';
  }

  String getMagnitudeColor() {
    if (magnitude == null) return '#9E9E9E';
    
    if (magnitude! < 3.0) return '#4CAF50';
    if (magnitude! < 4.0) return '#8BC34A';
    if (magnitude! < 5.0) return '#FFC107';
    if (magnitude! < 6.0) return '#FF9800';
    if (magnitude! < 7.0) return '#FF5722';
    return '#F44336';
  }
}