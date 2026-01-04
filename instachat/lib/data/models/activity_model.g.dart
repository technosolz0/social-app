// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityModelAdapter extends TypeAdapter<ActivityModel> {
  @override
  final int typeId = 0;

  @override
  ActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      activityType: fields[2] as String,
      metadata: (fields[3] as Map?)?.cast<String, dynamic>(),
      timestamp: fields[4] as DateTime,
      postId: fields[5] as String?,
      storyId: fields[6] as String?,
      targetUserId: fields[7] as String?,
      username: fields[8] as String?,
      userAvatar: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.activityType)
      ..writeByte(3)
      ..write(obj.metadata)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.postId)
      ..writeByte(6)
      ..write(obj.storyId)
      ..writeByte(7)
      ..write(obj.targetUserId)
      ..writeByte(8)
      ..write(obj.username)
      ..writeByte(9)
      ..write(obj.userAvatar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
