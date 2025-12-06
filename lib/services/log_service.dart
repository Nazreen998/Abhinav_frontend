import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class LogService {
  static const String baseUrl =
      "https://backend-abhinav-tracking.onrender.com/api/logs";

  Future<List<dynamic>> getLogs({
    required String role,
    required String userId,
    required String segment,
  }) async {
    try {
      // MASTER → get all logs
      if (role == "master") {
        final url = Uri.parse("$baseUrl/all");
        final res = await http.get(
          url,
          headers: {"Authorization": "Bearer ${AuthService.token}"},
        );
        if (res.statusCode != 200) return [];
        return jsonDecode(res.body);
      }

      // MANAGER / SALESMAN → filtered logs
      final url = Uri.parse("$baseUrl/filter");

      final body = {
        "role": role,
        "user_id": userId,
        "segment": segment,
      };

      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AuthService.token}",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode != 200) return [];
      return jsonDecode(res.body);

    } catch (e) {
      print("Log Fetch Error: $e");
      return [];
    }
  }
}
