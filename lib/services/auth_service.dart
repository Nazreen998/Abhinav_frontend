import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      "https://abhinav-backend-4.onrender.com/api/auth";

  static String? token;
  static Map<String, dynamic>? currentUser;

  // -------------------------------------------------------
  // LOAD SAVED USER + TOKEN
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
  // LOGIN (WITH SINGLE-DEVICE SECURITY)
  // -------------------------------------------------------
  static Future<bool> login(String mobile, String password) async {
    try {
      final url = Uri.parse("$baseUrl/login");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mobile": mobile,
          "password": password,
        }),
      );

      print("LOGIN RESPONSE: ${res.body}");

      if (res.statusCode != 200) return false;

      final data = jsonDecode(res.body);

      // MULTI LOGIN BLOCK (BACKEND ERROR MESSAGE)
      if (data["status"] != "success") {
        print("LOGIN ERROR: ${data["message"]}");
        return false;
      }

      // SAVE DATA
      token = data["token"];
      currentUser = data["user"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token!);
      await prefs.setString("user", jsonEncode(currentUser));

      return true;

    } catch (e) {
      print("LOGIN EXCEPTION: $e");
      return false;
    }
  }

  // -------------------------------------------------------
  // LOGOUT (RELEASE ACTIVE SESSION FROM BACKEND)
  // -------------------------------------------------------
  static Future<void> logout() async {
    try {
      if (currentUser == null) return;

      final url = Uri.parse("$baseUrl/logout");

      await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "user_id": currentUser!["user_id"],
        }),
      );

    } catch (e) {
      print("LOGOUT ERROR: $e");
    }

    // CLEAR LOCAL STORAGE ALWAYS
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("user");

    token = null;
    currentUser = null;
  }
}
