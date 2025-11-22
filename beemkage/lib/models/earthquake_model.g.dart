// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earthquake_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EarthquakeModelAdapter extends TypeAdapter<EarthquakeModel> {
  @override
  final int typeId = 2;

  @override
  EarthquakeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EarthquakeModel(
      date: fields[0] as String?,
      time: fields[1] as String?,
      datetime: fields[2] as DateTime?,
      magnitude: fields[3] as double?,
      depth: fields[4] as int?,
      region: fields[5] as String?,
      latitude: fields[6] as double?,
      longitude: fields[7] as double?,
      potential: fields[8] as String?,
      felt: fields[9] as String?,
      shakemapUrl: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EarthquakeModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.datetime)
      ..writeByte(3)
      ..write(obj.magnitude)
      ..writeByte(4)
      ..write(obj.depth)
      ..writeByte(5)
      ..write(obj.region)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude)
      ..writeByte(8)
      ..write(obj.potential)
      ..writeByte(9)
      ..write(obj.felt)
      ..writeByte(10)
      ..write(obj.shakemapUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EarthquakeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
