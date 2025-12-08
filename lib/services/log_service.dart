import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/log_model.dart';

class LogService {
  static const String baseUrl =
      "https://backend-abhinav-tracking.onrender.com/api";

  // ---------------- SAVE VISIT LOG ----------------
  Future<bool> saveVisit(LogModel log) async {
    try {
      final url = Uri.parse("$baseUrl/visitShop"); // CORRECT ROUTE

      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AuthService.token}",
        },
        body: jsonEncode(log.toJson()),
      );

      print("SAVE VISIT RESPONSE = ${res.body}");

      return res.statusCode == 200;

    } catch (e) {
      print("Save Visit Error: $e");
      return false;
    }
  }

  // ---------------- FETCH LOGS ----------------
  Future<List<dynamic>> getLogs({
    required String role,
    required String userId,
    required String segment,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/logs/filter");

      final body = {
        "role": role,
        "user_id": userId,
        "segment": segment,
        "filterSegment": "All",
        "result": "All",
        "startDate": null,
        "endDate": null,
      };

      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AuthService.token}",
        },
        body: jsonEncode(body),
      );

      print("LOG RESPONSE = ${res.body}");

      if (res.statusCode != 200) return [];

      return jsonDecode(res.body);

    } catch (e) {
      print("Log Fetch Error: $e");
      return [];
    }
  }
  Future<String?> uploadPhoto(String base64, String filename) async {
  try {
    final url = Uri.parse("$baseUrl/uploadPhoto");

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${AuthService.token}",
      },
      body: jsonEncode({
        "image": base64,
        "filename": filename,
      }),
    );

    final data = jsonDecode(res.body);

    if (data["status"] == "success") return data["url"];
    return null;

  } catch (e) {
    print("Upload error: $e");
    return null;
  }
}

}
