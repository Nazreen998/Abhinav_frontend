import 'dart:convert';
import 'package:http/http.dart' as http;

class LogService {
  static const String baseUrl = "https://backend-abhinav-tracking.onrender.com/api/logs";

  Future<bool> addLog(Map<String, dynamic> logData) async {
    try {
      final url = Uri.parse("$baseUrl/add");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(logData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Log Add Error: $e");
      return false;
    }
  }

  Future<List<dynamic>> getLogs() async {
    try {
      final url = Uri.parse("$baseUrl/all");
      final res = await http.get(url);

      if (res.statusCode != 200) return [];

      return jsonDecode(res.body);
    } catch (e) {
      print("Error fetching logs: $e");
      return [];
    }
  }
}
