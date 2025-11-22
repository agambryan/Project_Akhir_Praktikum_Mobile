import 'package:hive/hive.dart';

part 'weather_warning_model.g.dart';

@HiveType(typeId: 3)
class WeatherWarningModel extends HiveObject {
  @HiveField(0)
  final String? id;
  
  @HiveField(1)
  final String? title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final String? level;
  
  @HiveField(4)
  final String? area;
  
  @HiveField(5)
  final DateTime? startTime;
  
  @HiveField(6)
  final DateTime? endTime;
  
  @HiveField(7)
  final String? phenomenon;
  
  @HiveField(8)
  final String? instructions;

  WeatherWarningModel({
    this.id,
    this.title,
    this.description,
    this.level,
    this.area,
    this.startTime,
    this.endTime,
    this.phenomenon,
    this.instructions,
  });

  factory WeatherWarningModel.fromJson(Map<String, dynamic> json) {
    return WeatherWarningModel(
      id: json['id'],
      title: json['judul'] ?? json['title'],
      description: json['deskripsi'] ?? json['description'],
      level: json['level'] ?? json['tingkat'],
      area: json['wilayah'] ?? json['area'],
      startTime: json['waktuMulai'] != null 
          ? DateTime.tryParse(json['waktuMulai']) 
          : null,
      endTime: json['waktuSelesai'] != null 
          ? DateTime.tryParse(json['waktuSelesai']) 
          : null,
      phenomenon: json['fenomena'] ?? json['phenomenon'],
      instructions: json['instruksi'] ?? json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'area': area,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'phenomenon': phenomenon,
      'instructions': instructions,
    };
  }

  String getLevelColor() {
    if (level == null) return '#2196F3';
    
    final l = level!.toLowerCase();
    if (l.contains('hijau') || l.contains('rendah')) return '#4CAF50';
    if (l.contains('kuning') || l.contains('sedang')) return '#FFC107';
    if (l.contains('oranye') || l.contains('tinggi')) return '#FF9800';
    if (l.contains('merah') || l.contains('ekstrem')) return '#F44336';
    
    return '#2196F3';
  }

  String getLevelIcon() {
    if (level == null) return 'ℹ️';
    
    final l = level!.toLowerCase();
    if (l.contains('hijau') || l.contains('rendah')) return '✅';
    if (l.contains('kuning') || l.contains('sedang')) return '⚠️';
    if (l.contains('oranye') || l.contains('tinggi')) return '🔶';
    if (l.contains('merah') || l.contains('ekstrem')) return '🚨';
    
    return 'ℹ️';
  }

  bool get isActive {
    if (startTime == null || endTime == null) return false;
    final now = DateTime.now();
    return now.isAfter(startTime!) && now.isBefore(endTime!);
  }
}