import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://backend-abhinav-tracking.onrender.com/api";

  static String? token;
  static Map<String, dynamic>? currentUser;

  static Future<bool> login(String mobile, String password) async {
    try {
      final url = Uri.parse("$baseUrl/auth/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mobile": mobile,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == "success") {
        token = data["token"];
        currentUser = data["user"];
        return true;
      } else {
        print("SERVER RESPONSE: ${response.body}");
      }

      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }
}
