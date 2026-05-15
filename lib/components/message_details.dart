import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/sms_controller.dart';

final smsDetailsProvider =
    StateNotifierProvider<SmsDetailsController, SmsDetailsState>(
      (ref) => SmsDetailsController(),
    );

class SmsDetailsState {
  final String? id;
  final String messageContent;
  final String sender;
  final String time;
  final String prediction;

  SmsDetailsState({
    this.id,
    required this.messageContent,
    required this.sender,
    required this.time,
    required this.prediction,
  });

  // 🔹 Add copyWith method
  SmsDetailsState copyWith({
    String? id,
    String? messageContent,
    String? sender,
    String? time,
    String? prediction,
  }) {
    return SmsDetailsState(
      id: id ?? this.id,
      messageContent: messageContent ?? this.messageContent,
      sender: sender ?? this.sender,
      time: time ?? this.time,
      prediction: prediction ?? this.prediction,
    );
  }
}



class SmsDetailsController extends StateNotifier<SmsDetailsState> {
  SmsDetailsController()
      : super(SmsDetailsState(
    id: null,
    messageContent: "",
    sender: "",
    time: "",
    prediction: "",
  ));

  void updateSmsDetails(String? id, String messageContent, String sender, String time, String prediction) {
    if (id == null || id.isEmpty) {
      print("Error: Message ID is null or empty.");
      return;
    }

    print("Debug: updateSmsDetails called with ID = $id, Message = $messageContent");

    state = SmsDetailsState(
      id: id,
      messageContent: messageContent,
      sender: sender,
      time: time,
      prediction: prediction,
    );

    print("Debug: New state ID = ${state.id}");
  }

  Future<void> markAsSafe(WidgetRef ref) async {
    print("Debug: Message ID in markAsSafe = ${state.id}");

    if (state.prediction != "Phishing") return;

    if (state.id == null || state.id!.isEmpty) {
      print("Error: Message ID is null or empty.");
      return;
    }

    try {
      await ref.read(smsProvider.notifier).updateMessageStatus(state.id!, "Legitimate");

      // 🔹 Firestore Update ke baad State ko Refresh karein
      // await ref.read(smsProvider.notifier).fetchNewMessages();

      state = state.copyWith(prediction: "Legitimate");

      print("SMS marked as Safe successfully.");
    } catch (e) {
      print("Error in marking as safe: $e");
    }
  }
  Future<void> reportAsIncorrect(WidgetRef ref) async {
    print("🔹 Debug: Message ID in markAsSafe = ${state.id}");

    if (state.prediction != "Legitimate") return;

    if (state.id == null || state.id!.isEmpty) {
      print("Error: Message ID is null or empty.");
      return;
    }

    try {
      await ref.read(smsProvider.notifier).updateMessageStatus(state.id!, "Phishing");

      // await ref.read(smsProvider.notifier).fetchNewMessages();

      state = state.copyWith(prediction: "Phishing");

      print("SMS marked as Safe successfully.");
    } catch (e) {
      print("Error in marking as safe: $e");
    }
  }



  }



class SmsDetailsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smsDetails = ref.watch(smsDetailsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png",
              height: 30,
              color: Colors.black,
            ),
            const Text(
              'Phish Scan',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(
              width: 27,
            )
          ],
        ),
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.black),),
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Divider(color: Colors.grey)),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  child: Text("Message Details", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Text(
                  smsDetails.messageContent,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  smsDetails.sender,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  smsDetails.time,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                smsDetails.prediction == "Phishing" ?SizedBox(height: 16) : Container(height: 0,),
                smsDetails.prediction == "Phishing" ?
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Medium risk: Potential phishing attempt',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ) : Container(
                  height: 0,
                ),
                const SizedBox(height: 16),
                buildSectionTitle('Analysis results'),
                buildSectionContent(
                  smsDetails.prediction == "Phishing" ? 'This message is likely to be a phishing attempt.' : "The message is Safe",
                  Colors.black
                ),
                buildSectionTitle('Analysis'),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: smsDetails.prediction == "Phishing" ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: buildSectionContent(
                      smsDetails.prediction, Colors.white )),
                buildSectionTitle('Recommendation'),
                buildSectionContent(
                    smsDetails.prediction == "Phishing" ? 'We suggest that you do not click on any links in this message to avoid being redirected to harmful websites.' : "This message is secure now you can click on any links in this message.",
                  Colors.black
                ),
                const SizedBox(height: 40),

                smsDetails.prediction == "Phishing" ?
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: buildActionButton(
                    'Mark As Safe',
                    Colors.purple,
                    onTap: () {
                      final smsDetails = ref.read(smsDetailsProvider);

                      if (smsDetails.prediction == "Legitimate") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("This message is already marked as safe!"),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ref.read(smsDetailsProvider.notifier).markAsSafe(ref);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Message successfully marked as safe!"),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                ):
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: buildActionButton(
                      'Report As Incorrect', Colors.red,
                    onTap: () {
                      final smsDetails = ref.read(smsDetailsProvider);

                      if (smsDetails.prediction == "Phishing") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("This message is already marked as phishing!"),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ref.read(smsDetailsProvider.notifier).reportAsIncorrect(ref);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Message successfully marked as phishing!"),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),
      ),
    );
  }

  Widget buildSectionContent(String content, Color textColor) {
    return Text(content, style: TextStyle(fontSize: 14, color: textColor));
  }

  Widget buildActionButton(String text, Color color, {required void Function() onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
