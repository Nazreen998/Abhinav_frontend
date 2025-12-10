// ------------------------------------------------------------
// API SERVICE (MATCHED EXACTLY TO YOUR NODE BACKEND)
// ------------------------------------------------------------

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart' as auth;

class ApiService {
  static const String baseUrl = "https://abhinav-backend-4.onrender.com/api";
  // LOCAL TESTING:
  // static const String baseUrl = "http://192.168.1.2:5000/api";

  // --------------------------------------------------------
  // COMMON HEADERS
  // --------------------------------------------------------
  static Map<String, String> get headers => {
        "Content-Type": "application/json",
        if (auth.AuthService.token != null)
          "Authorization": "Bearer ${auth.AuthService.token}",
      };

  // --------------------------------------------------------
  // LOGIN (BACKEND EXPECTS user_id + password)
  // --------------------------------------------------------
  static Future<Map<String, dynamic>> login(String userId, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "password": password,
      }),
    );

    return jsonDecode(res.body);
  }

  // --------------------------------------------------------
  // GET ALL SHOPS ✔ Correct backend path: /api/shop/all
  // --------------------------------------------------------
  static Future<List<dynamic>> getShops() async {
    final res = await http.get(
      Uri.parse("$baseUrl/shop/all"),
      headers: headers,
    );

    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body);
    return body["shops"] ?? [];
  }

  // --------------------------------------------------------
  // GET ASSIGNED SHOPS ✔ Correct backend path: /api/assigned/:salesmanId
  // --------------------------------------------------------
  static Future<List<dynamic>> getAssignedShops(String salesmanId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/assigned/$salesmanId"),
      headers: headers,
    );

    print("ASSIGNED RESPONSE = ${res.body}");

    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body);

    return body["shops"] ?? []; // ✔ matches updated backend
  }

  // --------------------------------------------------------
  // REMOVE ASSIGNED SHOP ❗ NEEDS CORRECT BACKEND ROUTE
  // --------------------------------------------------------
  static Future<Map<String, dynamic>> removeAssignedShop(
      String shopId, String salesmanId) async {

    final url = Uri.parse("$baseUrl/assign/remove"); // ❗ backend missing this route

    final res = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        "shopId": shopId,
        "salesmanId": salesmanId,
      }),
    );

    print("REMOVE ASSIGN RESPONSE = ${res.body}");
    return jsonDecode(res.body);
  }

  // --------------------------------------------------------
  // GET VISIT LOGS ✔ CORRECTED: /api/visit/logs (from VisitLog.js)
  // --------------------------------------------------------
  static Future<List<dynamic>> getLogs() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/visit/logs"), // ← FIXED HERE
        headers: headers,
      );

      print("LOG RESPONSE = ${res.body}");

      if (res.statusCode != 200) return [];

      final json = jsonDecode(res.body);
      return json["logs"] ?? [];
    } catch (e) {
      print("VISIT LOG ERROR: $e");
      return [];
    }
  }

  // --------------------------------------------------------
  // ASSIGN SHOP ✔ Backend path: /api/assign/add
  // --------------------------------------------------------
  static Future<bool> assignShop(
      String shopId, String salesmanId, String assignedBy) async {
    final res = await http.post(
      Uri.parse("$baseUrl/assign/add"),
      headers: headers,
      body: jsonEncode({
        "shopId": shopId,
        "salesmanId": salesmanId,
        "assignedBy": assignedBy,
      }),
    );

    print("ASSIGN SHOP RESPONSE = ${res.body}");

    final data = jsonDecode(res.body);
    return data["status"] == "success";
  }
}
