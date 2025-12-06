import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = "http://your_api_url_here"; // <-- Change here

  static Future<List<dynamic>> fetchAssignedShops(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/assigned-shops/$userId"),
    );

    return jsonDecode(response.body)["shops"];
  }

  static Future<bool> unassignShop(String userId, String shopId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/unassign-shop"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "shopId": shopId}),
    );

    return jsonDecode(response.body)["success"];
  }
}
