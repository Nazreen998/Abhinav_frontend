// 📌 auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // MAIN BASE URL
  static const String baseApi =
      "https://abhinav-backend-4.onrender.com/api/auth";

  static String? token;
  static Map<String, dynamic>? currentUser;

  // -------------------------------------------------------
  // INIT (LOAD FROM STORAGE)
  // -------------------------------------------------------
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token");
    print("🔥 LOADED TOKEN = $token");

    final savedUser = prefs.getString("user");
    if (savedUser != null) {
      currentUser = jsonDecode(savedUser);
      print("🔥 LOADED USER = $currentUser");
    }
  }

  // -------------------------------------------------------
  // LOGIN
  // -------------------------------------------------------
  static Future<Map<String, dynamic>> login(
      String mobile, String password) async {
    try {
      final url = Uri.parse("$baseApi/login");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mobile": mobile.trim(),
          "password": password.trim(),
        }),
      );

      print("🔥 LOGIN RESPONSE = ${res.body}");

      final data = jsonDecode(res.body);

      if (data["status"] != "success") {
        return data; // return error to UI
      }

      // SAVE TOKEN + USER
      final prefs = await SharedPreferences.getInstance();

      token = data["token"];
      currentUser = data["user"];

      await prefs.setString("token", token!);
      await prefs.setString("user", jsonEncode(currentUser));

      print("🔥 TOKEN SAVED = $token");
      print("🔥 USER SAVED = $currentUser");

      return data;

    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // -------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------
  static Future<void> logout() async {
    try {
      if (currentUser != null) {
        final url = Uri.parse("$baseApi/logout");

        await http.post(url,
            headers: {
              "Content-Type": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
            body: jsonEncode({"user_id": currentUser!["user_id"]}));
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("user");

    token = null;
    currentUser = null;
  }
}
