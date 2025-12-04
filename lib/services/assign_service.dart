import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AssignService {
  static const String baseUrl = "http://192.168.159.43:5000/api/assign";

  /// Assign shops
  Future<bool> assignShops({
    required String userId,
    required List<String> shopIds,
    required double lat,
    required double lng,
  }) async {
    final body = {
      "salesman_id": userId,
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

  /// Get ALL next shops sorted by distance
  Future<List<dynamic>> getNextShops(
      String userId, double lat, double lng) async {
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
    return data["shops"] ?? [];
  }
}
