import 'package:cloud_firestore/cloud_firestore.dart';

class SMSMessage {
  final String sender;
  final String body;
  final DateTime date;
  final String prediction;
  final String confidence;
  final String deviceId;

  SMSMessage({
    required this.sender,
    required this.body,
    required this.date,
    required this.prediction,
    required this.confidence,
    required this.deviceId,
  });

  // Convert SMSMessage to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "sender": sender,
      "body": body,
      "date": date.toIso8601String(),
      "prediction": prediction,
      "confidence": confidence,
      "deviceId": deviceId,
    };
  }

  // Convert Firestore Document to SMSMessage
  static SMSMessage fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SMSMessage(
      sender: data["sender"] ?? "Unknown",
      body: data["body"] ?? "",
      date: DateTime.parse(data["date"]),
      prediction: data["prediction"] ?? "Unknown",
      confidence: data["confidence"] ?? "0",
      deviceId: data["deviceId"] ?? "",
    );
  }
}
