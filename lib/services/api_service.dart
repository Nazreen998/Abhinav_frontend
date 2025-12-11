// ------------------------------------------------------------
// API SERVICE (FIXED FOR YOUR BACKEND ROUTES)
// ------------------------------------------------------------

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart' as auth;

class ApiService {
  static const String baseUrl = "https://abhinav-backend-5.onrender.com/api";

  // COMMON HEADERS
  static Map<String, String> get headers => {
        "Content-Type": "application/json",
        if (auth.AuthService.token != null)
          "Authorization": "Bearer ${auth.AuthService.token}",
      };

  // --------------------------------------------------------
  // LOGIN ✔ Correct backend route + correct body
  // --------------------------------------------------------
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/users/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "password": password,
      }),
    );

    return jsonDecode(res.body);
  }

  // --------------------------------------------------------
  // GET ALL SHOPS ✔ CORRECT ROUTE (/shops/list)
  // --------------------------------------------------------
  static Future<List<dynamic>> getShops() async {
    final res = await http.get(
      Uri.parse("$baseUrl/shops/list"),   // ✔ FIXED
      headers: headers,
    );

    if (res.statusCode != 200) return [];

    return jsonDecode(res.body);         // backend returns array directly
  }

  // --------------------------------------------------------
  // GET ASSIGNED SHOPS ✔ MUST USE /assigned/list
  // --------------------------------------------------------
  static Future<List<dynamic>> getAssignedShops() async {
    final res = await http.get(
      Uri.parse("$baseUrl/assigned/list"),   // ✔ FIXED
      headers: headers,
    );

    if (res.statusCode != 200) return [];

    return jsonDecode(res.body);
  }

  // --------------------------------------------------------
  // ASSIGN SHOP ✔ backend uses /assigned/assign
  // --------------------------------------------------------
  static Future<bool> assignShop(
      String shopId, String salesmanId, String sequence) async {
    final res = await http.post(
      Uri.parse("$baseUrl/assigned/assign"),   // ✔ FIXED
      headers: headers,
      body: jsonEncode({
        "shop_id": shopId,
        "user_id": salesmanId,
        "sequence": sequence,
      }),
    );

    final data = jsonDecode(res.body);
    return data["success"] == true;
  }

  // --------------------------------------------------------
  // UPDATE SHOP ❌ Your backend DOES NOT have update route
  // --------------------------------------------------------
  static Future<bool> updateShop(Map data) async {
    // TEMP: update disabled because backend has NO update route
    print("⚠ WARNING: /shops/update not available in backend");
    return false;
  }

  // --------------------------------------------------------
  // DELETE SHOP ✔ /shops/delete/:id
  // --------------------------------------------------------
  static Future<bool> deleteShop(String shopId) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/shops/delete/$shopId"),
      headers: headers,
    );

    return res.statusCode == 200;
  }

  // --------------------------------------------------------
  // GET LOGS ✔ /history
  // --------------------------------------------------------
  static Future<List<dynamic>> getLogs() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/history"),
        headers: headers,
      );

      if (res.statusCode != 200) return [];

      return jsonDecode(res.body);
    } catch (e) {
      print("LOG ERROR: $e");
      return [];
    }
  }

  // --------------------------------------------------------
  // REMOVE ASSIGNED SHOP ❌ backend has NO /assigned/remove route
  // --------------------------------------------------------
  static Future<bool> removeAssignedShop(String shopId, String salesmanId) async {
    print("⚠ WARNING: removeAssignedShop is NOT supported by backend.");
    return false;
  }
}
