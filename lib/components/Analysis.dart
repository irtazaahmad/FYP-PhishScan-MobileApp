import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/providers.dart';
import 'Bottom.dart';

class MessageAnalysisPage extends ConsumerStatefulWidget {
  const MessageAnalysisPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MessageAnalysisPage> createState() => _MessageAnalysisPageState();
}

class _MessageAnalysisPageState extends ConsumerState<MessageAnalysisPage> {
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final predictionState = ref.watch(predictionProvider);

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png", height: 30,color: Colors.black,),
            const Text(
              'Phish Scan',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(width: 27,)
          ],
        ),
        elevation: 0,
        leading: Container(),
        centerTitle: true,
        bottom: PreferredSize( preferredSize: const Size.fromHeight(0),
            child: Divider(
                color: Colors.grey
            )),
        toolbarHeight: 70,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: Text("Manual Editor", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter message for analysis...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: predictionState.isLoading
                    ? null
                    : () async {
                  final message = messageController.text.trim();
                  if (message.isNotEmpty) {
                    await ref.read(predictionProvider.notifier).fetchPrediction(message);
                    // TextField will retain the text, no need to reset it.
                    _showAnalysisDialog(context, ref.read(predictionProvider));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a message to analyze.")),
                    );
                  }
                },
                child: predictionState.isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                  "Submit For Analysis",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStaticChart() {
    final Map<String, double> staticData = {
      "02": 0.9,
      "04": 0.5,
      "05": 0.8,
      "06": 0.4,
      "01": 0.3,
    };

    return Column(
      children:
      staticData.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LinearProgressIndicator(
                  value: entry.value,
                  color: _getColor(entry.key),
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColor(String key) {
    switch (key) {
      case "02":
        return Colors.purple;
      case "04":
        return Colors.blue;
      case "05":
        return Colors.amber;
      case "06":
        return Colors.green;
      case "01":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  void _showAnalysisDialog(BuildContext context, PredictionState state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Phishing Check Result",style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold
          ),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Prediction: ", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),),
                  Text("${state.prediction}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: state.prediction == "phishing"
                              ? Colors.red
                              : Colors.green)),
                ],
              ),
              Row(
                children: [
                  Text("Confidence: ", style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                  ),),
                  Text("${state.confidence}",style: TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold
                  ),),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

}
