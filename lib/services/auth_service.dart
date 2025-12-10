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
static Future<bool> login(String userId, String password) async {
  try {
    final url = Uri.parse("https://abhinav-backend-4.onrender.com/api/auth/login");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,       // ✔ IMPORTANT FIX
        "password": password,    // ✔ SAME
      }),
    );

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {
      currentUser = data["user"];
      return true;
    }

    print("LOGIN FAILED: ${data["message"]}");
    return false;

  } catch (e) {
    print("LOGIN ERROR: $e");
    return false;
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
