import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AssignService {
  static const String baseUrl = "https://backend-abhinav-tracking.onrender.com/api/assign";

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

    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<List<dynamic>> getNextShops(String userId, double lat, double lng) async {
    final url = Uri.parse("$baseUrl/next/$userId?lat=$lat&lng=$lng");

    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer ${AuthService.token}"},
    );

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);
    return data["shops"] ?? [];
  }
}
