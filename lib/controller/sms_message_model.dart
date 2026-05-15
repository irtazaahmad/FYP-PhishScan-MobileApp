import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'sms_message_model.g.dart';


@HiveType(typeId: 0) // Unique ID for Hive Model
class SMSMessage {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sender;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String prediction;

  @HiveField(5)
  final String confidence;

  @HiveField(6)
  final String deviceId;

  SMSMessage({
    this.id = "",
    required this.sender,
    required this.body,
    required this.date,
    this.prediction = '',
    this.confidence = '',
    required this.deviceId,
  });

  /// 🔹 Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sender": sender,
      "body": body,
      "date": date.toIso8601String(),
      "prediction": prediction,
      "confidence": confidence,
      "deviceId": deviceId,
    };
  }

  /// 🔹 Create Object from JSON
  factory SMSMessage.fromJson(Map<String, dynamic> json) {
    return SMSMessage(
      id: json['id'] ?? '',
      sender: json['sender'] ?? '',
      body: json['body'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      prediction: json['prediction'] ?? '',
      confidence: json['confidence'] ?? '',
      deviceId: json['deviceId'] ?? '',
    );
  }

  /// 🔹 CopyWith for Safe Updates
  SMSMessage copyWith({
    String? id,
    String? sender,
    String? body,
    DateTime? date,
    String? prediction,
    String? confidence,
    String? deviceId,
  }) {
    return SMSMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      body: body ?? this.body,
      date: date ?? this.date,
      prediction: prediction ?? this.prediction,
      confidence: confidence ?? this.confidence,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  /// 🔹 Convert Firestore Document to SMSMessage
  factory SMSMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SMSMessage(
      id: doc.id,
      sender: data['sender'] ?? '',
      body: data['body'] ?? '',
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      prediction: data['prediction'] ?? '',
      confidence: data['confidence'] ?? '',
      deviceId: data['deviceId'] ?? '',
    );
  }
}
