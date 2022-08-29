// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GalleryLevelAdapter extends TypeAdapter<GalleryLevel> {
  @override
  final int typeId = 1;

  @override
  GalleryLevel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GalleryLevel(
      level: fields[0] as int,
      expirationTime: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GalleryLevel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.level)
      ..writeByte(1)
      ..write(obj.expirationTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
