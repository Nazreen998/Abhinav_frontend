// ------------------------------------------------------------
// API SERVICE (SYNCED WITH BACKEND) - FINAL ERROR FREE VERSION
// ------------------------------------------------------------

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart' as auth;

class ApiService {
  static const String baseUrl = "https://abhinav-backend.onrender.com/api";

  // --------------------------------------------------------
  // COMMON HEADERS
  // --------------------------------------------------------
  static Map<String, String> get headers {
    final token = auth.AuthService.token;

    if (token == null) {
      print("❌ API HEADER ERROR: TOKEN IS NULL");
    } else {
      print("✅ API HEADER TOKEN => $token");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // --------------------------------------------------------
  // LOGIN
  // --------------------------------------------------------
  static Future<Map<String, dynamic>> login(
      String phone, String password) async {
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
  // USERS
  // --------------------------------------------------------
  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(
      Uri.parse("$baseUrl/users/all"),
      headers: headers,
    );
    if (res.statusCode != 200) return [];
    return jsonDecode(res.body)["users"] ?? [];
  }

  static Future<bool> addUser(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/users/add"),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  static Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse("$baseUrl/users/update/$id"),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  static Future<bool> deleteUser(String id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/users/delete/$id"),
      headers: headers,
    );
    return jsonDecode(res.body)["success"] == true;
  }

  // --------------------------------------------------------
  // SHOPS
  // --------------------------------------------------------
  static Future<List<dynamic>> getShops() async {
    final res = await http.get(
      Uri.parse("$baseUrl/shops/list"),
      headers: headers,
    );

    print("SHOP STATUS => ${res.statusCode}");
    print("SHOP RESPONSE => ${res.body}");

    if (res.statusCode != 200) return [];
    return jsonDecode(res.body)["shops"] ?? [];
  }

  static Future<bool> updateShop(Map data) async {
    final res = await http.put(
      Uri.parse("$baseUrl/shops/update/${data["shop_id"]}"),
      headers: headers,
      body: jsonEncode({
        "shop_name": data["shop_name"], // ✅ FIX
        "address": data["address"], // ✅ FIX
        "segment": data["segment"],
      }),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  static Future<bool> deleteShop(String id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/shops/$id"),
      headers: headers,
    );
    return jsonDecode(res.body)["success"] == true;
  }

  // --------------------------------------------------------
  // ASSIGNED SHOPS
  // --------------------------------------------------------
  static Future<List<dynamic>> getAssignedShops(String salesmanId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/assigned/list"),
      headers: headers,
    );
    // 🔥 ADD THIS PRINT HERE
    print("ASSIGNED STATUS => ${res.statusCode}");
    print("ASSIGNED RAW RESPONSE => ${res.body}");

    if (res.statusCode != 200) return [];
    return jsonDecode(res.body)["assigned"] ?? [];
  }

  // --------------------------------------------------------
  // ASSIGN SHOP (MASTER / MANAGER)
  // --------------------------------------------------------
  static Future<bool> assignShops(
    String salesmanId,
    String salesmanName,
    List<Map<String, dynamic>> shops,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/assigned/reset-assign"),
      headers: headers,
      body: jsonEncode({
        "salesmanId": salesmanId,
        "salesmanName": salesmanName,
        "shops": shops,
      }),
    );

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode != 200) return false;

    final body = jsonDecode(res.body);
    return body["success"] == true;
  }

  // --------------------------------------------------------
  // REMOVE ASSIGNED SHOP (BY assign_id)
  // --------------------------------------------------------
  static Future<bool> removeAssignedShop(
    String salesmanId,
    String sk,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/assigned/remove"),
      headers: headers,
      body: jsonEncode({
        "salesmanId": salesmanId,
        "sk": sk,
      }),
    );

    return jsonDecode(res.body)["success"] == true;
  }

  // --------------------------------------------------------
  // REORDER ASSIGNED SHOPS
  // --------------------------------------------------------
  static Future<bool> reorderAssignedShops(
    String salesmanId,
    List<String> orderSkList,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/assigned/reorder"),
      headers: headers,
      body: jsonEncode({
        "salesmanId": salesmanId,
        "order": orderSkList,
      }),
    );

    return jsonDecode(res.body)["success"] == true;
  }

//reset assigned shop
  static Future<bool> resetAndAssign(
    String salesmanId,
    String salesmanName,
    List<dynamic> shops,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/assigned/reset-assign"),
      headers: headers,
      body: jsonEncode({
        "salesmanId": salesmanId,
        "salesmanName": salesmanName,
        "shops": shops,
      }),
    );

    return jsonDecode(res.body)["success"] == true;
  }

//Next shop for salesman
  static Future<Map<String, dynamic>> getNextShops() async {
    final url = Uri.parse("$baseUrl/nextshop/next");

    final res = await http.get(url, headers: headers);

    if (res.statusCode != 200) {
      throw Exception("Failed to load next shops");
    }

    return jsonDecode(res.body);
  }

  // --------------------------------------------------------
  // SALESMAN TODAY / COMPLETED / PENDING
  // --------------------------------------------------------
  static Future<Map<String, dynamic>> getSalesmanToday() async {
    final res = await http.get(
      Uri.parse("$baseUrl/assigned/salesman/today"),
      headers: headers,
    );
    if (res.statusCode != 200) return {};
    return jsonDecode(res.body);
  }

// ================= HISTORY LOGS =================
  static Future<List<dynamic>> getLogs() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/visit/list"),
        headers: {
          "Authorization": "Bearer ${auth.AuthService.token}",
        },
      );

      print("📜 LOG STATUS => ${res.statusCode}");
      print("📜 LOG BODY => ${res.body}");

      if (res.statusCode != 200) {
        return [];
      }

      final body = jsonDecode(res.body);

      // 🔥 BACKEND RETURNS "visits"
      return body["visits"] ?? [];
    } catch (e) {
      print("❌ GET LOGS ERROR: $e");
      return [];
    }
  }
}
