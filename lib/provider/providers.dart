import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_services.dart';

class PredictionState {
  final String prediction;
  final String confidence;
  final String phishing;
  final String legitimate;
  final bool isLoading;

  PredictionState({
    this.prediction = "",
    this.confidence = "",
    this.phishing = "",
    this.legitimate = "",
    this.isLoading = false,
  });

  PredictionState copyWith({
    String? prediction,
    String? confidence,
    String? phishing,
    String? legitimate,
    bool? isLoading,
  }) {
    return PredictionState(
      prediction: prediction ?? this.prediction,
      confidence: confidence ?? this.confidence,
      phishing: phishing ?? this.phishing,
      legitimate: legitimate ?? this.legitimate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PredictionController extends StateNotifier<PredictionState> {
  PredictionController() : super(PredictionState());

  final ApiService _apiService = ApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor!;
    }
    return "unknown_device";
  }

  Future<void> fetchPrediction(String message) async {
    try {
      state = state.copyWith(isLoading: true); // 🔹 Start Loading

      final String deviceId = await getDeviceId();

      var aiResponse = await _apiService.predictMessage(message);

      String prediction = aiResponse["prediction"] ?? "Error";
      String confidence = aiResponse["confidence"] ?? "0";
      String phishing = aiResponse["phishing"] ?? "0";
      String legitimate = aiResponse["legitimate"] ?? "0";

      await _firestore.collection("analyzed_messages").add({
        "message": message,
        "prediction": prediction,
        "confidence": confidence,
        "phishing": phishing,
        "legitimate": legitimate,
        "deviceId": deviceId,
        "timestamp": FieldValue.serverTimestamp(),
      });

      state = state.copyWith(
        prediction: prediction,
        confidence: confidence,
        phishing: phishing,
        legitimate: legitimate,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print("Error fetching prediction: $e");
    }
  }
}

final predictionProvider =
StateNotifierProvider<PredictionController, PredictionState>(
        (ref) => PredictionController());
