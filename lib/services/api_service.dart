// ------------------------------------------------------------
// API SERVICE (MATCHED TO YOUR NODE BACKEND)
// ------------------------------------------------------------

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart' as auth;

class ApiService {
  static const String baseUrl = "https://abhinav-backend-5.onrender.com/api";

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
  // GET ALL SHOPS
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
  // GET ASSIGNED SHOPS
  // --------------------------------------------------------
  static Future<List<dynamic>> getAssignedShops(String salesmanId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/assigned/$salesmanId"),
      headers: headers,
    );

    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body);
    return body["shops"] ?? [];
  }

  // --------------------------------------------------------
  // ASSIGN SHOP
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

    final data = jsonDecode(res.body);
    return data["status"] == "success";
  }

  // --------------------------------------------------------
  // UPDATE SHOP
  // --------------------------------------------------------
  static Future<bool> updateShop(Map data) async {
    final url = "$baseUrl/shop/update/${data["shop_id"]}";

    final res = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({
        "shop_name": data["shop_name"],
        "address": data["address"],
        "segment": data["segment"],
      }),
    );

    return res.statusCode == 200;
  }

  // --------------------------------------------------------
  // DELETE SHOP
  // --------------------------------------------------------
  static Future<bool> deleteShop(String shopId) async {
    final url = "$baseUrl/shop/delete/$shopId";

    final res = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    return res.statusCode == 200;
  }
  // --------------------------------------------------------
// GET VISIT LOGS
// --------------------------------------------------------
static Future<List<dynamic>> getLogs() async {
  try {
    final res = await http.get(
      Uri.parse("$baseUrl/logs"),
      headers: headers,
    );

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    return data["logs"] ?? [];
  } catch (e) {
    print("LOG ERROR: $e");
    return [];
  }
}
// --------------------------------------------------------
// REMOVE ASSIGNED SHOP
// --------------------------------------------------------
static Future<bool> removeAssignedShop(String shopId, String salesmanId) async {
  final res = await http.post(
    Uri.parse("$baseUrl/assign/remove"),
    headers: headers,
    body: jsonEncode({
      "shopId": shopId,
      "salesmanId": salesmanId,
    }),
  );

  if (res.statusCode != 200) return false;

  final body = jsonDecode(res.body);
  return body["status"] == "success";
}

}
