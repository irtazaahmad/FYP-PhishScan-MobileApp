import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.43.6:5000";

  // Send a message for analysis
  Future<Map<String, dynamic>> predictMessage(String message) async {
    final response = await http.post(
      Uri.parse("$baseUrl/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": message}),
    );
    print(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get response");
    }
  }
}
