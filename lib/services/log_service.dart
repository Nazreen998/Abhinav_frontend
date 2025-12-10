import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class LogService {
  static const String baseUrl =
      "https://abhinav-backend-4.onrender.com/api";

  // ---------------- UPLOAD PHOTO ----------------
  Future<String?> uploadPhoto(String base64, String filename) async {
    final res = await http.post(
      Uri.parse("$baseUrl/uploadPhoto"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${AuthService.token}",
      },
      body: jsonEncode({
        "image": base64,
        "filename": filename,
      }),
    );

    final json = jsonDecode(res.body);
    return json["url"]; // {status, url}
  }

  // ---------------- SAVE VISIT ----------------
  Future<bool> saveVisit(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse("$baseUrl/visit"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${AuthService.token}",
      },
      body: jsonEncode(payload),
    );

    return res.statusCode == 200;
  }
}
