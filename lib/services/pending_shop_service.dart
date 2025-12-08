import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class PendingShopService {
  static const String base =
      "https://abhinav-backend-production.up.railway.app/api";

  /// Get all pending shops for a user
  Future<List<dynamic>> getPendingShops() async {
  final url = Uri.parse("$base/pending/all");

  final res = await http.get(
    url,
    headers: {
      "Authorization": "Bearer ${AuthService.token}",
    },
  );

  final data = jsonDecode(res.body);

  if (data["status"] == "success") {
    return data["shops"];
  }

  return [];
}


  /// Approve shop
  Future<bool> approveShop(String id) async {
    final res = await http.post(
      Uri.parse("$base/pending/approve/$id"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
      },
    );

    return res.statusCode == 200;
  }

  /// Reject shop
  Future<bool> rejectShop(String id) async {
    final res = await http.delete(
      Uri.parse("$base/pending/reject/$id"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
      },
    );

    return res.statusCode == 200;
  }
}
