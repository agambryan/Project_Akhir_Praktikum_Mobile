// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_warning_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeatherWarningModelAdapter extends TypeAdapter<WeatherWarningModel> {
  @override
  final int typeId = 3;

  @override
  WeatherWarningModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherWarningModel(
      id: fields[0] as String?,
      title: fields[1] as String?,
      description: fields[2] as String?,
      level: fields[3] as String?,
      area: fields[4] as String?,
      startTime: fields[5] as DateTime?,
      endTime: fields[6] as DateTime?,
      phenomenon: fields[7] as String?,
      instructions: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WeatherWarningModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.area)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.phenomenon)
      ..writeByte(8)
      ..write(obj.instructions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherWarningModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
