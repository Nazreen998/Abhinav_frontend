// ------------------------------------------------------------
// API SERVICE (FULLY MATCHED TO YOUR NODE BACKEND)
// ------------------------------------------------------------

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart' as auth;

class ApiService {
  static const String baseUrl = "https://abhinav-backend-4.onrender.com";


  // COMMON HEADERS
  static Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (auth.AuthService.token != null)
          "Authorization": "Bearer ${auth.AuthService.token}"
      };


  // --------------------------------------------------------
  // LOGIN
  // --------------------------------------------------------
  static Future<Map<String, dynamic>> login(String mobile, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mobile": mobile, "password": password}),
    );
    return jsonDecode(res.body);
  }

  // --------------------------------------------------------
  // GET ALL SHOPS  ✔ Backend route = /api/shop/all
  // --------------------------------------------------------
  static Future<List<dynamic>> getShops(String role, String segment) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/shop/all"),
      headers: headers,
    );

    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body);
    return body["shops"] ?? [];
  }

  // --------------------------------------------------------
  // GET ASSIGNED SHOPS ✔ Backend route = /api/assigned/list/:salesmanId
  // --------------------------------------------------------
  static Future<List<dynamic>> getAssignedShops(
      String role, String segment, String salesmanId) async {

    final res = await http.get(
      Uri.parse("$baseUrl/api/assigned/list/$salesmanId"),
      headers: headers,
    );

    if (res.statusCode != 200) return [];

    final body = jsonDecode(res.body);
    return body["assigned"] ?? [];
  }

  // --------------------------------------------------------
  // REMOVE ASSIGNED SHOP ✔ Backend expects (shopId, salesmanId)
  // --------------------------------------------------------
  static Future<Map<String, dynamic>> removeAssignedShop(
      String shopId, String salesmanId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/assign/remove"),
      headers: headers,
      body: jsonEncode({
        "shopId": shopId,
        "salesmanId": salesmanId,
      }),
    );

    return jsonDecode(res.body);
  }

  // --------------------------------------------------------
  // GET LOGS ✔ Backend route = /api/logs
  // --------------------------------------------------------
  static Future<List<dynamic>> getLogs(
      String role, String segment, String userId) async {

    final res = await http.get(
      Uri.parse("$baseUrl/api/logs"),
      headers: headers,
    );

    if (res.statusCode != 200) return [];

    final json = jsonDecode(res.body);
    return json["logs"] ?? [];
  }
  // --------------------------------------------------------
// ASSIGN SHOP TO SALESMAN
// --------------------------------------------------------
static Future<bool> assignShop(
    String shopId, String salesmanId, String assignedBy) async {
  
  final url = Uri.parse("$baseUrl/api/assign/add");

  final res = await http.post(
    url,
    headers: headers,
    body: jsonEncode({
      "shopId": shopId,
      "salesmanId": salesmanId,
      "assignedBy": assignedBy,
    }),
  );

  print("ASSIGN SHOP RESPONSE = ${res.body}");

  return res.statusCode == 200;
}

}
