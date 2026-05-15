import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as ref show read;
import 'package:intl/intl.dart';
import 'package:phishscan/components/message_screen.dart';
import 'package:phishscan/controller/sms_controller.dart';
import 'package:phishscan/controller/sms_message_model.dart';

import '../provider/providers.dart';
import 'Analysis.dart';
import 'Bottom.dart';
import 'message_details.dart';

final navigationProvider = StateNotifierProvider<NavigationController, bool>(
  (ref) => NavigationController(),
);

class NavigationController extends StateNotifier<bool> {
  NavigationController() : super(false);

  void navigateAnalyzeMessage(BuildContext context) {
    // Reset state before navigation to avoid getting stuck
    state = false;
    if (!state) {
      state = true;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MessageAnalysisPage()),
      ).then((_) {
        // Ensure state is reset when coming back
        state = false;
      });
    }
  }

  void navigatePhishingMessage(BuildContext context) {
    // Reset state before navigation to avoid getting stuck
    state = false;
    if (!state) {
      state = true;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MessageScreen()),
      ).then((_) {
        // Ensure state is reset when coming back
        state = false;
      });
    }
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final predictionState = ref.watch(predictionProvider);
    final sms = ref.watch(smsProvider);

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
      appBar: AppBar(
        toolbarHeight: 70,

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
        leading: Container(),
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Divider(color: Colors.grey)),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                child: Text("DashBoard",
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child:  GestureDetector(
                      onTap: () => ref.read(navigationProvider.notifier).navigatePhishingMessage(context),
                      child: _buildStats(
                        'Phishing Message',
                        sms.when(
                            data: (messages) => messages
                                .where((sms) => sms.prediction == "Phishing")
                                .length
                                .toString(),
                            error: (error, stackTrace) => "0",
                            loading: () => "0"),
                        Colors.orange,
                        Icon(
                          Icons.crisis_alert_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child:  GestureDetector(
                      onTap: () => ref.read(navigationProvider.notifier).navigatePhishingMessage(context),
                      child: _buildStats(
                          'Message Scanned',
                          sms.when(
                              data: (messages) => messages.length.toString(),
                              error: (error, stackTrace) => "0",
                              loading: () => "0"),
                          Colors.green,
                          Icon(
                            Icons.message_outlined,
                            color: Colors.white,
                            size: 30,
                          )),
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Recent Messages',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              sms.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return const Text("No Recent Messages");
                  }
                  messages.sort((a, b) => b.date.compareTo(a.date));
                  final latestMessages = messages.take(3).toList();
                  return Column(
                    children: latestMessages
                        .map((message) => _buildMessageCard(message))
                        .toList(),
                  );
                },
                error: (error, stackTrace) => Text("Error loading messages"),
                loading: () => CircularProgressIndicator(),
              ),
              SizedBox(
                height: 10,
              ),
              _buildButton(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(String title, String value, Color color, Widget? icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        // height: 150,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16.0),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon ??
                Icon(
                  Icons.message_outlined,
                  color: Colors.white,
                  size: 35,
                ),
            SizedBox(
              height: 10,
            ),
            Text(
              textAlign: TextAlign.center,
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: () => ref
            .read(navigationProvider.notifier)
            .navigateAnalyzeMessage(context),
        icon: const Icon(Icons.edit, color: Colors.white, size: 18),
        label: const Text(
          'Manual Edit',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(SMSMessage message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          message.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(message.sender),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('yyyy-MM-dd').format(message.date),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: message.prediction == "Legitimate"
                    ? Colors.green
                    : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.prediction,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
