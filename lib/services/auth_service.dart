// 📌 auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
  });
}

class AuthService {
  // 🔥 BASE URL (CHANGE THIS ONLY)
  static const String baseApi = "https://abhinav-backend-4.onrender.com/api";
  // Local testing:
  // static const String baseApi = "http://192.168.1.2:5000/api";

  static String? token;
  static Map<String, dynamic>? currentUser;

  // -------------------------------------------------------
  // INIT (LOAD SESSION)
  // -------------------------------------------------------
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token");

    final savedUser = prefs.getString("user");
    if (savedUser != null) {
      currentUser = jsonDecode(savedUser);
    }
  }

  // -------------------------------------------------------
  // LOGIN
  // -------------------------------------------------------
static Future<Map<String, dynamic>> login(String mobile, String password) async {
  try {
    final url = Uri.parse("https://abhinav-backend-4.onrender.com/api/auth/login");

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "mobile": mobile.trim(),
        "password": password.trim(),
      }),
    );

    print("🔥 LOGIN REQUEST SENT = $mobile / $password");
    print("🔥 LOGIN RAW RESPONSE = ${res.body}");

    return jsonDecode(res.body);

  } catch (e) {
    print("🔥 LOGIN ERROR: $e");
    return {"status": "error", "message": e.toString()};
  }
}

  // -------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------
  static Future<void> logout() async {
    try {
      if (currentUser != null) {
        final url = Uri.parse("$baseApi/auth/logout");

        await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "user_id": currentUser!["user_id"],
          }),
        );
      }
    } catch (_) {}

    // CLEAR LOCAL STORAGE
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("user");

    token = null;
    currentUser = null;
  }
}
