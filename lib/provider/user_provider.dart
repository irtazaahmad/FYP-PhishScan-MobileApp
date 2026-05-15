import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

class User {
  String id;
  String name;
  String username;

  User({required this.id, required this.name, required this.username});

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "username": username};
  }

  static User fromJson(Map<String, dynamic> json) {
    return User(id: json["id"], name: json["name"], username: json["username"]);
  }
}

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null) {
    _loadUserFromFirestore();
  }

  Future<String> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android Unique Device ID
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor!; // iOS Unique Device ID
    }
    return "unknown_device";
  }

  Future<void> _loadUserFromFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String deviceId = await _getDeviceId(); // Get Device ID

    var userDoc = await firestore.collection("users").doc(deviceId).get();

    if (userDoc.exists) {
      state = User.fromJson(userDoc.data()!);
    } else {
      state = User(id: deviceId, name: "No Name", username: "No Username");
      await saveUserToFirestore(state!);
    }
  }

  Future<void> saveUserToFirestore(User user) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection("users").doc(user.id).set(user.toJson());
    state = user;
  }

  Future<void> updateUser(String name, String username) async {
    String deviceId = await _getDeviceId();
    User updatedUser = User(id: deviceId, name: name, username: username);
    await saveUserToFirestore(updatedUser);
  }
}
