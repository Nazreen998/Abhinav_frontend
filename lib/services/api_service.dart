// ------------------------------------------------------------
// API SERVICE (SYNCED WITH BACKEND) - ERROR FREE VERSION
// ------------------------------------------------------------

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart' as auth;

class ApiService {
  static const String baseUrl =
      "https://abhinav-backend-5.onrender.com/api";

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
    if (res.statusCode != 200) return [];
    return jsonDecode(res.body)["shops"] ?? [];
  }

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
    return jsonDecode(res.body)["success"] == true;
  }

  static Future<bool> deleteShop(String id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/shops/delete/$id"),
      headers: headers,
    );
    return jsonDecode(res.body)["success"] == true;
  }

  // --------------------------------------------------------
  // ASSIGNED SHOPS
  // --------------------------------------------------------
  static Future<List<dynamic>> getAssignedShops() async {
    final res = await http.get(
      Uri.parse("$baseUrl/assigned/list"),
      headers: headers,
    );
    return jsonDecode(res.body)["assigned"] ?? [];
  }

// --------------------------------------------------------
// ASSIGN SHOP (NAME BASED – FINAL)
// --------------------------------------------------------
static Future<bool> assignShop(
  String shopName,
  String salesmanName,
  String segment,
) async {
  final res = await http.post(
    Uri.parse("$baseUrl/assigned/assign"),
    headers: headers,
    body: jsonEncode({
      "shop_name": shopName,
      "salesman_name": salesmanName,
      "segment": segment,
    }),
  );

  if (res.statusCode != 200) return false;

  final body = jsonDecode(res.body);
  return body["success"] == true;
}

  // REMOVE
  static Future<bool> removeAssignedShop(
    String shopName,
    String salesmanName,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/assigned/remove"),
      headers: headers,
      body: jsonEncode({
        "shop_name": shopName,
        "salesman_name": salesmanName,
      }),
    );
    return jsonDecode(res.body)["success"] == true;
  }

  // REORDER
  static Future<bool> reorderAssignedShops(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/assigned/reorder"),
      headers: headers,
      body: jsonEncode(data),
    );
    return jsonDecode(res.body)["success"] == true;
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

  // --------------------------------------------------------
  // LOG HISTORY
  // --------------------------------------------------------
  static Future<List<dynamic>> getLogs() async {
    final res = await http.get(
      Uri.parse("$baseUrl/history"),
      headers: headers,
    );
    if (res.statusCode != 200) return [];
    return jsonDecode(res.body);
  }
}
