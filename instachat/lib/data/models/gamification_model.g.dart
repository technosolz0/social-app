// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GamificationModelAdapter extends TypeAdapter<GamificationModel> {
  @override
  final int typeId = 1;

  @override
  GamificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GamificationModel(
      totalPoints: fields[0] as int,
      currentLevel: fields[1] as int,
      currentStreak: fields[2] as int,
      badges: (fields[3] as List).cast<BadgeModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, GamificationModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalPoints)
      ..writeByte(1)
      ..write(obj.currentLevel)
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.badges);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BadgeModelAdapter extends TypeAdapter<BadgeModel> {
  @override
  final int typeId = 2;

  @override
  BadgeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BadgeModel(
      id: fields[0] as String,
      name: fields[1] as String,
      iconUrl: fields[2] as String,
      rarity: fields[3] as String,
      earnedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BadgeModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconUrl)
      ..writeByte(3)
      ..write(obj.rarity)
      ..writeByte(4)
      ..write(obj.earnedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
