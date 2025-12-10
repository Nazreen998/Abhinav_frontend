// 📌 auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      "https://abhinav-backend-4.onrender.com/api/auth";

  static String? token;
  static Map<String, dynamic>? currentUser;

  // -------------------------------------------------------
  // INIT (LOAD SAVED SESSION)
  // -------------------------------------------------------
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token");

    final userJson = prefs.getString("user");
    if (userJson != null) {
      currentUser = jsonDecode(userJson);
    }
  }

  // -------------------------------------------------------
  // LOGIN
  // -------------------------------------------------------
  static Future<bool> login(String mobile, String password) async {
    try {
      final url = Uri.parse("$baseUrl/login");

      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "mobile": mobile,
          "password": password,
        }),
      );

      print("LOGIN RESPONSE: ${res.body}");

      if (res.statusCode != 200) return false;

      final data = jsonDecode(res.body);

      if (data["status"] != "success") {
        print("LOGIN ERROR: ${data["message"]}");
        return false;
      }

      // Save token + user
      token = data["token"];
      currentUser = data["user"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token ?? "");
      await prefs.setString("user", jsonEncode(currentUser));

      return true;

    } catch (e) {
      print("LOGIN EXCEPTION: $e");
      return false;
    }
  }

  // -------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------
  static Future<void> logout() async {
    try {
      if (currentUser == null) return;

      final url = Uri.parse("$baseUrl/logout");

      await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "user_id": currentUser!["user_id"],
        }),
      );
    } catch (e) {
      print("LOGOUT ERROR: $e");
    }

    // CLEAR LOCAL STORAGE
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("user");

    token = null;
    currentUser = null;
  }
}
