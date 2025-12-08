import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class VisitService {
  static const baseUrl =
      "https://abhinav-backend-production.up.railway.app/api/visit";

  /// ---------------------------------------------------------
  /// 1. UPLOAD PHOTO (base64 → URL)
  /// ---------------------------------------------------------
  Future<String?> uploadPhoto(String base64, String filename) async {
    try {
      final url = Uri.parse("$baseUrl/uploadPhoto");

      final res = await http.post(
        url,
        headers: {
          "Authorization": "Bearer ${AuthService.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "image": base64,
          "filename": filename,
        }),
      );

      if (res.statusCode != 200) {
        print("UPLOAD FAILED: ${res.body}");
        return null;
      }

      return jsonDecode(res.body)["url"];
    } catch (e) {
      print("UPLOAD ERROR: $e");
      return null;
    }
  }

  /// ---------------------------------------------------------
  /// 2. SAVE VISIT LOG
  /// ---------------------------------------------------------
  Future<bool> visitShop(Map<String, dynamic> payload) async {
    try {
      final url = Uri.parse("$baseUrl/visitShop");

      final res = await http.post(
        url,
        headers: {
          "Authorization": "Bearer ${AuthService.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      return res.statusCode == 200;
    } catch (e) {
      print("VISIT ERROR: $e");
      return false;
    }
  }
}
