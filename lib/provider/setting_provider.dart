import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final notificationSwitchProvider = StateProvider<bool>((ref) => false);

Future<void> updateNotificationSetting(bool value) async {
  await FirebaseFirestore.instance
      .collection("settings")
      .doc("notifications")
      .set({"enabled": value});
}

Future<bool> fetchNotificationSetting() async {
  var doc = await FirebaseFirestore.instance
      .collection("settings")
      .doc("notifications")
      .get();

  return doc.exists ? (doc["enabled"] as bool) : false;
}
