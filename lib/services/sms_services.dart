import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:telephony/telephony.dart';

import '../controller/sms_message_model.dart';


Future<void> backgroundMessageHandler(SmsMessage message) async {
  final String deviceId = await getDeviceId(); // 📌 Ensure `getDeviceId` is defined

  SMSMessage newMessage = SMSMessage(
    sender: message.address ?? "Unknown",
    body: message.body ?? "",
    date: DateTime.now(),
    prediction: "Unknown",
    confidence: "0%",
    deviceId: deviceId,
  );

  await FirebaseFirestore.instance.collection("messages").add(newMessage.toJson());
  print("📩 Background SMS Saved Successfully!");
}


void startListeningForSMS() async {
  final Telephony telephony = Telephony.instance;
  bool? permissionsGranted = await telephony.requestSmsPermissions;

  if (permissionsGranted == true) {
    telephony.listenIncomingSms(
      onBackgroundMessage: backgroundMessageHandler, // ✅ Runs Even If App is Closed
      onNewMessage: (SmsMessage message) {
        backgroundMessageHandler(message);
      },
    );
  }
}
Future<void> fetchAndSaveOldSms() async {
  final Telephony telephony = Telephony.instance;
  List<SmsMessage> messages = await telephony.getInboxSms(
    columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
  );

  final String deviceId = await getDeviceId();

  for (var sms in messages) {
    SMSMessage message = SMSMessage(
      sender: sms.address ?? "Unknown",
      body: sms.body ?? "",
      date: DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0),
      prediction: "Unknown",
      confidence: "0%",
      deviceId: deviceId,
    );

    await FirebaseFirestore.instance.collection("messages").add(message.toJson());
  }

  print("✅ Periodic SMS Fetch Completed");
}


Future<String> getDeviceId() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return androidInfo.id; // ✅ Returns Unique Device ID
}
