// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SMSMessageAdapter extends TypeAdapter<SMSMessage> {
  @override
  final int typeId = 0;

  @override
  SMSMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SMSMessage(
      id: fields[0] as String,
      sender: fields[1] as String,
      body: fields[2] as String,
      date: fields[3] as DateTime,
      prediction: fields[4] as String,
      confidence: fields[5] as String,
      deviceId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SMSMessage obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sender)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.prediction)
      ..writeByte(5)
      ..write(obj.confidence)
      ..writeByte(6)
      ..write(obj.deviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SMSMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
