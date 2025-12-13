import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ✔ Backend base URL
  static const String baseApi =
      "https://abhinav-backend-5.onrender.com/api/users";

  static String? token;
  static Map<String, dynamic>? currentUser;

  // ---------------------------------------------------------
  // INIT → LOAD TOKEN & USER AT APP START
  // ---------------------------------------------------------
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token");

    final savedUser = prefs.getString("user");
    if (savedUser != null) {
      currentUser = jsonDecode(savedUser);
    }
  }

  // ---------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------
  static Future<Map<String, dynamic>> login(
      String phone, String password) async {
    try {
      final url = Uri.parse("$baseApi/login");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone.trim(),
          "password": password.trim(),
        }),
      );

      final data = jsonDecode(res.body);

      // ❌ Login failed
      if (data["success"] != true) {
        return data;
      }

      // -----------------------------------------------------
      // SAVE TOKEN + USER (IMPORTANT)
      // -----------------------------------------------------
      final prefs = await SharedPreferences.getInstance();

      token = data["token"];
      currentUser = data["user"];

      // 🔥 MUST AWAIT
      await prefs.setString("token", token!);
      await prefs.setString("user", jsonEncode(currentUser));

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": "Network error",
        "error": e.toString(),
      };
    }
  }

  // ---------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");
    await prefs.remove("user");

    token = null;
    currentUser = null;
  }

  // ---------------------------------------------------------
  // COMMON AUTH HEADER
  // ---------------------------------------------------------
  static Map<String, String> get authHeader => {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };
}
