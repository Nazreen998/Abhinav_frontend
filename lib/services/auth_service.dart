import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseApi =
      "https://abhinav-backend-5.onrender.com/api/users";  // ✅ FIXED

  static String? token;
  static Map<String, dynamic>? currentUser;

  // LOAD TOKEN + USER
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token");
    final savedUser = prefs.getString("user");

    if (savedUser != null) {
      currentUser = jsonDecode(savedUser);
    }
  }

  // LOGIN ✔ FIXED ✔ CORRECT BODY ✔ CORRECT URL
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final url = Uri.parse("$baseApi/login");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone.trim(),       // ✅ FIXED
          "password": password.trim(), // backend expects this
        }),
      );

      final data = jsonDecode(res.body);

      if (data["success"] != true) return data;

      final prefs = await SharedPreferences.getInstance();

      token = data["token"];
      currentUser = data["user"];

      prefs.setString("token", token!);
      prefs.setString("user", jsonEncode(currentUser));

      return data;

    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("user");

    token = null;
    currentUser = null;
  }
}
