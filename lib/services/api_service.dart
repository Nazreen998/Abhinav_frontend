// ------------------------------------------------------------
// API SERVICE (FULLY SYNCED WITH YOUR BACKEND) - ERROR FREE
// ------------------------------------------------------------

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart' as auth;

class ApiService {
  static const String baseUrl =
      "https://abhinav-backend-5.onrender.com/api";
    // --------------------------------------------------------
  // GET ALL USERS (MASTER ONLY)
  // --------------------------------------------------------
  static Future<List<dynamic>> getUsers() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/users/all"),
        headers: headers,
      );

      if (res.statusCode != 200) return [];

      final body = jsonDecode(res.body);
      return body["users"] ?? [];
    } catch (e) {
      return [];
    }
  }

  // --------------------------------------------------------
  // ADD USER
  // --------------------------------------------------------
  static Future<bool> addUser(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/users/add"),
        headers: headers,
        body: jsonEncode(data),
      );

      final body = jsonDecode(res.body);
      return body["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // --------------------------------------------------------
  // UPDATE USER
  // --------------------------------------------------------
  static Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/users/update/$id"),
        headers: headers,
        body: jsonEncode(data),
      );

      final body = jsonDecode(res.body);
      return body["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // --------------------------------------------------------
  // DELETE USER
  // --------------------------------------------------------
  static Future<bool> deleteUser(String id) async {
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/users/delete/$id"),
        headers: headers,
      );

      final body = jsonDecode(res.body);
      return body["success"] == true;
    } catch (e) {
      return false;
    }
  }
  // --------------------------------------------------------
  // COMMON HEADERS
  // --------------------------------------------------------
  static Map<String, String> get headers => {
        "Content-Type": "application/json",
        if (auth.AuthService.token != null)
          "Authorization": "Bearer ${auth.AuthService.token}",
      };

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
  // GET ALL SHOPS
  // --------------------------------------------------------
  static Future<List<dynamic>> getShops() async {
    final res = await http.get(
      Uri.parse("$baseUrl/shops/list"),
      headers: headers,
    );

    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body);
    return body["shops"] ?? [];
  }

  // --------------------------------------------------------
  // GET ASSIGNED SHOPS
  // --------------------------------------------------------
  static Future<List<dynamic>> getAssignedShops() async {
    final res = await http.get(
      Uri.parse("$baseUrl/assigned/list"),
      headers: headers,
    );

    if (res.statusCode != 200) return [];

    return jsonDecode(res.body);
  }

  // --------------------------------------------------------
  // ASSIGN SHOP
  // --------------------------------------------------------
  static Future<bool> assignShop(
    String shopId,
    String salesmanId,
    String assignerId,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/assigned/assign"),
      headers: headers,
      body: jsonEncode({
        "shopId": shopId,
        "salesmanId": salesmanId,
        "assignerId": assignerId,
      }),
    );

    final body = jsonDecode(res.body);
    return body["success"] == true;
  }

  // --------------------------------------------------------
  // REMOVE ASSIGNED SHOP  ✅ FIXED
  // --------------------------------------------------------
  static Future<bool> removeAssignedShop(
    String shopId,
    String salesmanId,
  ) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/assigned/remove"),
        headers: headers,
        body: jsonEncode({
          "shopId": shopId,
          "salesmanId": salesmanId,
        }),
      );

      final data = jsonDecode(res.body);
      return data["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // --------------------------------------------------------
  // UPDATE SHOP
  // --------------------------------------------------------
  static Future<bool> updateShop(Map data) async {
    final res = await http.put(
      Uri.parse("$baseUrl/shops/update/${data["_id"]}"),
      headers: headers,
      body: jsonEncode({
        "shopName": data["shop_name"],
        "shopAddress": data["address"],
        "segment": data["segment"],
      }),
    );

    if (res.statusCode != 200) return false;

    final body = jsonDecode(res.body);
    return body["success"] == true;
  }

  // --------------------------------------------------------
  // DELETE SHOP
  // --------------------------------------------------------
  static Future<bool> deleteShop(String id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/shops/delete/$id"),
      headers: headers,
    );

    if (res.statusCode != 200) return false;

    final body = jsonDecode(res.body);
    return body["success"] == true;
  }

  // --------------------------------------------------------
  // GET LOG HISTORY
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
      return [];
    }
  }
}
