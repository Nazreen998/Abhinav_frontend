import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AssignService {
  static const String baseUrl =
      "https://abhinav-backend-4.onrender.com/api/assign";

  /// Assign shops
  Future<bool> assignShops({
    required dynamic userId,
    required List<String> shopIds,
    required double lat,
    required double lng,
  }) async {
    final body = {
      "salesman_id": userId.toString(),
      "shops": shopIds,
      "salesman_lat": lat,
      "salesman_lng": lng,
    };

    final res = await http.post(
      Uri.parse("$baseUrl/assignShops"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      print("❌ Server Error ${res.statusCode}");
      return false;
    }

    final data = jsonDecode(res.body);
    return data["status"] == "success";
  }

  /// -----------------------------
  /// DELETE ASSIGNED SHOP (FIXED)
  /// -----------------------------
  Future<bool> deleteAssignedShop({
    required String shopId,
    required String salesmanId,
  }) async {
    final url = Uri.parse("$baseUrl/remove");

    final body = {
      "shopId": shopId,
      "salesmanId": salesmanId,
    };

    final res = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("DELETE ASSIGN RESPONSE: ${res.body}");

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body);
    return data["status"] == "success";
  }

  /// -----------------------------
  /// REASSIGN SHOP (FIXED)
  /// -----------------------------
  Future<bool> reassignShop({
    required String oldSalesmanId,
    required String newSalesmanId,
    required String shopId,
    required String assignedBy,
  }) async {
    final url = Uri.parse("$baseUrl/reassign");

    final body = {
      "oldSalesmanId": oldSalesmanId,
      "newSalesmanId": newSalesmanId,
      "shopId": shopId,
      "assignedBy": assignedBy,
    };

    final res = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("REASSIGN RESPONSE: ${res.body}");

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body);
    return data["status"] == "success";
  }

  /// -----------------------------
  /// NEXT SHOPS
  /// -----------------------------
  Future<List<dynamic>> getNextShops(
    String userId,
    double lat,
    double lng,
  ) async {
    final url = Uri.parse("$baseUrl/next/$userId?lat=$lat&lng=$lng");

    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer ${AuthService.token}"},
    );

    if (res.statusCode != 200) {
      print("❌ Next Shop Error ${res.statusCode}");
      return [];
    }

    final data = jsonDecode(res.body);
    final shops = data["shops"] ?? [];

    return shops.map((s) => {
          "shop_id": s["shop_id"],
          "shop_name": s["shop_name"] ?? "",
          "address": s["address"] ?? "",
          "lat": _safeDouble(s["lat"]),
          "lng": _safeDouble(s["lng"]),
          "sequence": s["sequence"],
        }).toList();
  }

  double _safeDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();

    String s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == "null") return 0.0;

    return double.tryParse(s) ?? 0.0;
  }
}
