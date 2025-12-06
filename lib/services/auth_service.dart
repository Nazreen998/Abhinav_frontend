import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      "https://backend-abhinav-tracking.onrender.com/api";

  static String? token;
  static Map<String, dynamic>? currentUser;

  // Load token at app start
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    final userJson = prefs.getString("user");

    if (userJson != null) {
      currentUser = jsonDecode(userJson);
    }
  }

  static Future<bool> login(String mobile, String password) async {
  try {
    final url = Uri.parse("$baseUrl/auth/login");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobile": mobile,
        "password": password,
      }),
    );

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body);

    if (data["status"] != "success") return false;

    token = data["token"];
    currentUser = data["user"];

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token!);
    await prefs.setString("user", jsonEncode(currentUser));

    return true;

  } catch (e) {
    print("LOGIN ERROR: $e");
    return false;
  }
}

  // LOGOUT BLOCK - DO NOT DELETE TOKEN
  static Future<void> logout() async {
    // token should NOT be removed
    final prefs = await SharedPreferences.getInstance();
    // Comment below line:
    // await prefs.remove("currentUser");
  }
}
