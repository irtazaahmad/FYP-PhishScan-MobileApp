import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:phishscan/fcm/fcm.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../main.dart';
import 'sms_message_model.dart';

/// Riverpod Provider
final smsProvider =
    StateNotifierProvider<SMSController, AsyncValue<List<SMSMessage>>>(
  (ref) => SMSController(),
);

class SMSController extends StateNotifier<AsyncValue<List<SMSMessage>>> {
  final Telephony telephony = Telephony.instance;
  List<SMSMessage> _cachedMessages = [];
  String _deviceId = "";
  Timer? _fetchTimer;

  bool _notificationsEnabled = true;


  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;

    // Save the preference to Hive
    var box = await Hive.openBox('settings');
    await box.put('notificationsEnabled', enabled);

    print("🔔 Notifications ${enabled ? "enabled" : "disabled"}");
  }

  bool get notificationsEnabled => _notificationsEnabled;

  /// Constructor
  SMSController() : super(const AsyncValue.loading()) {
    _initialize();
  }


  Future<void> _initialize() async {
    _deviceId = await getDeviceId();
    var box = await Hive.openBox('settings');
    _notificationsEnabled = box.get('notificationsEnabled', defaultValue: true);

    // Load cached messages
    await loadCachedMessages();

    // Fetch messages from Firestore
    await fetchMessagesFromFirestore();

    // Start real-time fetching and listening
    listenForIncomingMessages();
    startRealTimeFetching();
  }

  Future<void> loadCachedMessages() async {
    var box = await Hive.openBox<SMSMessage>('sms_cache');
    if (box.isNotEmpty) {
      _cachedMessages = box.values.toList();
      state = AsyncValue.data(_cachedMessages);
    } else {
      state = AsyncValue.data([]);
    }
  }

  Future<void> fetchMessagesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("messages")
          .where("deviceId", isEqualTo: _deviceId)
          .get();

      final messages = snapshot.docs.map((doc) => SMSMessage.fromFirestore(doc)).toList();

      // Merge with local cache
      for (var msg in messages) {
        if (!_cachedMessages.any((m) => m.id == msg.id)) {
          _cachedMessages.add(msg);
        }
      }

      state = AsyncValue.data(_cachedMessages);
    } catch (e) {
      print("Error fetching messages from Firestore: $e");
    }
  }

  Future<bool> isMessageDuplicate(String body, DateTime date) async {
    // Check local cache
    bool existsInCache = _cachedMessages.any((msg) => msg.body == body && msg.date == date);
    if (existsInCache) return true;

    // Check Firestore
    QuerySnapshot existingMessages = await FirebaseFirestore.instance
        .collection("messages")
        .where("body", isEqualTo: body)
        .where("date", isEqualTo: date.toIso8601String())
        .get();

    return existingMessages.docs.isNotEmpty;
  }


  Future<void> saveMessagesToFirestore(List<SMSMessage> messages) async {
    var batch = FirebaseFirestore.instance.batch();

    for (var msg in messages) {
      var docRef = FirebaseFirestore.instance.collection("messages").doc();
      batch.set(docRef, msg.toJson());
    }

    await batch.commit();
    print("✅ Messages saved to Firestore: ${messages.length}");
  }


  Future<void> processIncomingMessage(SmsMessage sms) async {
    String sender = sms.address ?? "Unknown";
    String body = sms.body ?? "";
    DateTime date = DateTime.now();

    // Skip duplicates
    if (await isMessageDuplicate(body, date)) {
      print("⚠️ Duplicate incoming message found, skipping...");
      return;
    }

    // Analyze message with AI
    var aiResult = await analyzeMessageWithAI(body);

    SMSMessage newMessage = SMSMessage(
      sender: sender,
      body: body,
      date: date,
      prediction: aiResult["prediction"],
      confidence: aiResult["confidence"],
      deviceId: _deviceId,
    );

    // Save to Firestore and update UI
    await saveMessagesToFirestore([newMessage]);
    addMessageToState(newMessage);

    // Show notification if necessary
    if (newMessage.prediction == "Legitimate" && _notificationsEnabled) {
      showLocalNotification(sender, newMessage.body);
    }
  }

  void addMessageToState(SMSMessage newMessage) {
    _cachedMessages.add(newMessage);
    state = AsyncValue.data([..._cachedMessages]);
    print("✅ New message added to state: ${newMessage.body}");
  }








  // Future<void> _initialize() async {
  //   _deviceId = await getDeviceId();
  //   var box = await Hive.openBox('settings');
  //   _notificationsEnabled = box.get('notificationsEnabled', defaultValue: true);
  //
  //   // 🔹 UI update before loading messages
  //   state = const AsyncValue.loading();
  //
  //   // 🔹 Load Cached Messages
  //   await loadCachedMessages();
  //
  //   // 🔹 If no cached messages, fetch from device
  //   if (_cachedMessages.isEmpty) {
  //     print("No cached messages, fetching from device...");
  //     await fetchNewMessages();
  //   } else {
  //     print("Using cached messages, skipping fetch...");
  //     state = AsyncValue.data(_cachedMessages);
  //   }
  //
  //   listenForIncomingMessages();
  //   startRealTimeFetching();
  // }
  //
  // Future<void> loadCachedMessages() async {
  //   var box =
  //       await Hive.openBox<SMSMessage>('sms_cache'); // ✅ Ensure Box is Open
  //
  //   print("📂 Checking cache size: ${box.length}");
  //
  //   if (box.isNotEmpty) {
  //     _cachedMessages = box.values.toList();
  //     print(
  //         "📂 Cached messages loaded successfully: ${_cachedMessages.length}");
  //     state = AsyncValue.data(_cachedMessages);
  //   } else {
  //     print("⚠️ No cached messages found in Hive.");
  //     state = AsyncValue.data([]); // Ensure UI updates properly
  //   }
  // }

  /// 🔹 Save Messages to Hive for Caching
  Future<void> saveMessagesToCache(List<SMSMessage> messages) async {
    var box =
        await Hive.openBox<SMSMessage>('sms_cache'); // ✅ Ensure Box is Open

    print("🛠 Saving new messages to cache...");

    for (var msg in messages) {
      await box.put(msg.id, msg);
      print("✅ Message cached: ${msg.id} -> ${msg.body}");
    }

    print("✅ Messages cached successfully. Total: ${box.length}");
  }

  /// 🔹 Start Periodic SMS Fetching
  void startRealTimeFetching() {
    _fetchTimer?.cancel(); // Cancel any existing timer
    _fetchTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      print("🔄 Checking for new messages...");
      await fetchNewMessages();
    });
  }

  void listenForIncomingMessages() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        print("📩 New SMS received: ${message.body}");
        await processIncomingMessage(message);
      },
      onBackgroundMessage: backgroundMessageHandler,
    );
  }

  Future<void> requestPermissionAndFetchMessages() async {
    state = AsyncValue.loading();
    var status = await Permission.sms.status;

    if (!status.isGranted) {
      status = await Permission.sms.request();
      if (!status.isGranted) {
        print("❌ SMS Permission Denied");
        state = AsyncValue.error("SMS Permission Denied", StackTrace.current);
        return;
      }
    }

    // 🔹 Check if messages were previously fetched
    if (_cachedMessages.isEmpty) {
      print("📩 Fetching messages for the first time...");
      await fetchStoredMessages();
    } else {
      print("🔄 Using cached messages...");
      state = AsyncValue.data(_cachedMessages);
    }
  }

  Future<void> fetchStoredMessages() async {
    try {
      List<SmsMessage> messages = await telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      );

      List<SMSMessage> fetchedMessages = [];

      for (var sms in messages) {
        String sender = sms.address ?? "Unknown";
        String body = sms.body ?? "";
        DateTime date = DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0);

        // 🔹 Firebase se check karein
        QuerySnapshot existingMessages = await FirebaseFirestore.instance
            .collection("messages")
            .where("body", isEqualTo: body)
            .where("date", isEqualTo: date.toIso8601String())
            .get();

        if (existingMessages.docs.isNotEmpty) {
          print("⚠️ Duplicate message found in Firebase, skipping...");
          continue; // Skip if already exists
        }

        var aiResult = await analyzeMessageWithAI(body);

        SMSMessage newMessage = SMSMessage(
          sender: sender,
          body: body,
          date: date,
          prediction: aiResult["prediction"],
          confidence: aiResult["confidence"],
          deviceId: _deviceId,
        );

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection("messages")
            .add(newMessage.toJson());

        await docRef.update({"id": docRef.id});
        DocumentSnapshot doc = await docRef.get();
        SMSMessage messageWithId = SMSMessage.fromFirestore(doc);

        fetchedMessages.add(messageWithId);
      }

      // 🔹 Local cache update karein
      _cachedMessages = fetchedMessages;
      state = AsyncValue.data(fetchedMessages);
      print("✅ Messages fetched and stored successfully.");
    } catch (e) {
      print("❌ Error fetching messages: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }


  // Future<void> processIncomingMessage(SmsMessage sms) async {
  //   String sender = sms.address ?? "Unknown";
  //   String body = sms.body ?? "";
  //   DateTime date = DateTime.now();
  //
  //   // 🔹 Duplicate check in Firebase
  //   QuerySnapshot existingMessages = await FirebaseFirestore.instance
  //       .collection("messages")
  //       .where("body", isEqualTo: body)
  //       .where("date", isEqualTo: date.toIso8601String())
  //       .get();
  //
  //   if (existingMessages.docs.isNotEmpty) {
  //     print("⚠️ Duplicate incoming message found, skipping...");
  //     return;
  //   }
  //
  //   var aiResult = await analyzeMessageWithAI(body);
  //
  //   SMSMessage newMessage = SMSMessage(
  //     sender: sender,
  //     body: body,
  //     date: date,
  //     prediction: aiResult["prediction"],
  //     confidence: aiResult["confidence"],
  //     deviceId: _deviceId,
  //   );
  //
  //   DocumentReference docRef = await FirebaseFirestore.instance
  //       .collection("messages")
  //       .add(newMessage.toJson());
  //   await docRef.update({"id": docRef.id});
  //
  //   _cachedMessages.add(newMessage);
  //   state = AsyncValue.data([..._cachedMessages]);
  // }


  Future<Map<String, dynamic>> analyzeMessageWithAI(String message) async {
    try {
      final Uri url = Uri.parse("http://192.168.43.6:5000/predict");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"prediction": "Error", "confidence": "0%"};
      }
    } catch (e) {
      return {"prediction": "Error", "confidence": "0%"};
    }
  }

  Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  }

  static Future<void> backgroundMessageHandler(SmsMessage message) async {
    print("Background SMS received: ${message.body}");
  }

  Future<void> updateMessageStatus(String? messageId, String newStatus) async {
    if (messageId == null || messageId.isEmpty) {
      print("❌ Error: Message ID is null or empty.");
      return;
    }

    try {
      // 🔹 Update Firestore
      await FirebaseFirestore.instance
          .collection("messages")
          .doc(messageId)
          .update({"prediction": newStatus});

      print("✅ Message updated in Firestore: $messageId");

      // 🔹 Update local cache
      _cachedMessages = _cachedMessages.map((msg) {
        if (msg.id == messageId) {
          return msg.copyWith(prediction: newStatus);
        }
        return msg;
      }).toList();

      // 🔹 Refresh UI
      state = AsyncValue.data(_cachedMessages);
      print("✅ Message prediction updated successfully.");
    } catch (e) {
      print("❌ Firebase Update Error: $e");
    }
  }

  Future<void> refreshMessages() async {
    try {
      state = AsyncValue.loading(); // Show loading state

      final snapshot = await FirebaseFirestore.instance
          .collection("messages")
          .where("deviceId", isEqualTo: _deviceId)
          .get();

      final messages = snapshot.docs.map((doc) {
        return SMSMessage.fromFirestore(doc);
      }).toList();

      _cachedMessages = messages;
      state = AsyncValue.data(messages);

      print("Messages refreshed successfully. Total: ${messages.length}");
    } catch (e) {
      print("Error refreshing messages: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> fetchCachedMessages() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("messages")
          .where("deviceId", isEqualTo: _deviceId)
          .get();

      final messages = snapshot.docs.map((doc) {
        final msg = SMSMessage.fromFirestore(doc);
        print("Debug: Fetched message ID = ${msg.id}");
        return msg;
      }).toList();

      print("Debug: Total Messages = ${messages.length}");
      print(
          "Debug: First Message ID = ${messages.isNotEmpty ? messages.first.id : 'No Messages'}");

      _cachedMessages = messages;
      state = AsyncValue.data(messages);
    } catch (e) {
      print("Error fetching messages: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  bool _isFetching = false;

  Future<void> fetchNewMessages() async {

    var status = await Permission.sms.status;
      if (!status.isGranted) {
        status = await Permission.sms.request();
        if (!status.isGranted) {
          print("SMS Permission Denied");
          return;
        }
      }

    if (_isFetching) {
      print("⚠️ Fetch already in progress, skipping...");
      return;
    }
    _isFetching = true;

    try {
      List<SmsMessage> messages = await telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      );

      List<SMSMessage> newMessages = [];

      for (var sms in messages) {
        String sender = sms.address ?? "Unknown";
        String body = sms.body ?? "";
        DateTime date = DateTime.fromMillisecondsSinceEpoch(sms.date ?? 0);

        bool existsInCache = _cachedMessages.any(
              (msg) => msg.body == body && msg.date == date,
        );

        QuerySnapshot existingMessages = await FirebaseFirestore.instance
            .collection("messages")
            .where("body", isEqualTo: body)
            .where("date", isEqualTo: date.toIso8601String())
            .get();

        if (existsInCache || existingMessages.docs.isNotEmpty) {
          print("⚠️ Duplicate message found, skipping...");
          continue;
        }



        var aiResult = await analyzeMessageWithAI(body);

        SMSMessage tempMessage = SMSMessage(
          sender: sender,
          body: body,
          date: date,
          prediction: aiResult["prediction"],
          confidence: aiResult["confidence"],
          deviceId: _deviceId,
        );

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection("messages")
            .add(tempMessage.toJson());

        await docRef.update({"id": docRef.id});
        DocumentSnapshot doc = await docRef.get();
        SMSMessage messageWithId = SMSMessage.fromFirestore(doc);

        newMessages.add(messageWithId);
        _cachedMessages.add(messageWithId);

        if (messageWithId.prediction == "Legitimate" && _notificationsEnabled) {
          showLocalNotification(sender, messageWithId.body);
        }
      }

      await saveMessagesToCache(newMessages);
      state = AsyncValue.data(_cachedMessages);
      print("✅ New messages fetched: ${newMessages.length}");
    } catch (e) {
      print("❌ Error fetching messages: $e");
    } finally {
      _isFetching = false;
    }
  }


  void showLocalNotification(String sender, String message) async {
    if (!_notificationsEnabled) {
      print("🔕 Notifications are disabled, skipping...");
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'sms_channel', // Channel ID
      'New SMS', // Channel Name
      channelDescription: 'Shows notifications when new SMS is received',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Phishing Detected Message',
      "${message}",
      platformChannelSpecifics,
      payload: 'new_sms',
    );
  }

  Future<void> searchMessages(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(_cachedMessages);
      return;
    }

    List<SMSMessage> filteredMessages = _cachedMessages.where((msg) {
      return msg.sender.toLowerCase().contains(query.toLowerCase()) ||
          msg.body.toLowerCase().contains(query.toLowerCase()) ||
          msg.date.toIso8601String().contains(query);
    }).toList();

    print("🔍 Search Results: ${filteredMessages.length} messages found.");
    state = AsyncValue.data(filteredMessages);
  }

}
