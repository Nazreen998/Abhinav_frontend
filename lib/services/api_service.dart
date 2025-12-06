import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl =
      "https://backend-abhinav-tracking.onrender.com/api";

  // ================================================================
  // GET ASSIGNED SHOPS LIST
  // ================================================================
  static Future<List> fetchAssignedShops(String userId) async {
    try {
      final url = Uri.parse("$baseUrl/assign/list/$userId");

      final res = await http.get(
        url,
        headers: {"Authorization": "Bearer ${AuthService.token}"},
      );

      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);
      return data["assigned"] ?? [];
    } catch (e) {
      print("FETCH ASSIGNED ERROR: $e");
      return [];
    }
  }

  // ================================================================
  // REMOVE ONE SHOP (MASTER / MANAGER)
  // ================================================================
  static Future<bool> unassignShop(String userId, String shopId) async {
    try {
      final url = Uri.parse("$baseUrl/assign/remove/$userId/$shopId");

      final res = await http.delete(
        url,
        headers: {"Authorization": "Bearer ${AuthService.token}"},
      );

      return res.statusCode == 200;
    } catch (e) {
      print("UNASSIGN ERROR: $e");
      return false;
    }
  }

  // ================================================================
  // REMOVE ALL ASSIGNED SHOPS
  // ================================================================
  static Future<bool> deleteAllAssigned(String userId) async {
    try {
      final url = Uri.parse("$baseUrl/assign/removeAll/$userId");

      final res = await http.delete(
        url,
        headers: {"Authorization": "Bearer ${AuthService.token}"},
      );

      return res.statusCode == 200;
    } catch (e) {
      print("DELETE ALL ERROR: $e");
      return false;
    }
  }

  // ================================================================
  // GET ALL SHOPS FOR MODIFY PAGE
  // ================================================================
  static Future<List> getAllShops() async {
    try {
      final url = Uri.parse("$baseUrl/assign/allShops");

      final res = await http.get(
        url,
        headers: {"Authorization": "Bearer ${AuthService.token}"},
      );

      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);
      return data["shops"] ?? [];
    } catch (e) {
      print("ALL SHOPS ERROR: $e");
      return [];
    }
  }

  // ================================================================
  // ASSIGN SHOPS (USED IN MODIFY PAGE)
  // ================================================================
  static Future<bool> assignShops(String userId, List shopIds) async {
    try {
      final url = Uri.parse("$baseUrl/assign/assignShops");

      final body = {
        "salesman_id": userId,
        "shops": shopIds,
        "salesman_lat": 0,
        "salesman_lng": 0,
      };

      final res = await http.post(
        url,
        headers: {
          "Authorization": "Bearer ${AuthService.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      return res.statusCode == 200;
    } catch (e) {
      print("ASSIGN ERROR: $e");
      return false;
    }
  }
}
